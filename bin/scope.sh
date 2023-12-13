#!/usr/bin/env bash
# shellcheck source=/home/jim/bin/libs/globals.sh
. ~/bin/libs/globals.sh

# Setup and Config {{{
set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

# If the option `use_preview_script` is set to `true`,
# then this script will be called and its output will be displayed in ranger.
# ANSI colour codes are supported.
# STDIN is disabled, so interactive scripts won't work properly

# Script arguments
FILE_PATH="${1}"             # Full path of the highlighted file
PV_WIDTH="${2}"              # Width of the preview pane (number of fitting characters)
# PV_HEIGHT="${3}"             # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH_JPG="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.

if [[ -v RANGER_LEVEL ]]; then
    NOT_IN_RANGER=false
else
    NOT_IN_RANGER=true
fi

# Meanings of exit codes:   code | meaning    | action of ranger
#                           -----+------------+---------------------------------------------------------------------.
# STAT_SHOW_STDOUT=0        # 0    | success    | Display STDOUT as preview
STAT_NO_PREVIEW=1         # 1    | no preview | Display no preview at all, default fallback if all else fails.
# STAT_PLAIN_TEXT=2         # 2    | plain text | Display the plain content of the file
# STAT_FIX_WIDTH=3          # 3    | fix width  | Don't reload when width changes
# STAT_FIX_HEIGHT=4         # 4    | fix height | Don't reload when height changes
STAT_FIX_BOTH=5           # 5    | fix both   | Don't ever reload
STAT_SHOW_CACHED_IMAGE=6  # 6    | image      | Display the image `$IMAGE_CACHE_PATH_JPG` points to as an image preview
STAT_SHOW_IMAGE=7         # 7    | image      | Display the file directly as an image

# Useful file bits.
# FILE_NAME="$(basename $FILE_PATH)"
FILE_EXTENSION="${FILE_PATH##*.}"
FILE_NAME_NO_EXTENSION="$(basename $FILE_PATH $FILE_EXTENSION)"
FILE_EXTENSION_LOWER="${FILE_EXTENSION,,}"
IMAGE_CACHE_PATH_PNG="$(basename "${IMAGE_CACHE_PATH_JPG}" jpg)png"

# Settings
# JQ_COLORS="1;33:4;33:0;33:0;33:0;32:1;37:1;37"
# HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_SIZE_MAX=26214300
HIGHLIGHT_TABWIDTH=${HIGHLIGHT_TABWIDTH:-8}
HIGHLIGHT_STYLE=${HIGHLIGHT_STYLE:-zenburn}
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE=${PYGMENTIZE_STYLE:-zenburn}
MAGICK="/opt/AppImages/magick"
# OPENSCAD_IMGSIZE=${RNGR_OPENSCAD_IMGSIZE:-1000,1000}
# OPENSCAD_COLORSCHEME=${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}
DEFAULT_SIZE="500x500"
COLS=$(tput cols)
COLS=$((COLS - 1))
# TABLE_GRID_STYLE=fancy_grid
TABLE_GRID_STYLE=grid
TAB="\t"
C=$(printf '\033[90m') # Table Colour 90=grey
H=$(printf '\033[33;1m') # Heading Colour 33=yellow
# H=$(printf '\033[38;2;255;82;197;48;2;155;106;0m')
R=$(printf '\033[0m')  # Reset
#}}}

# Pretty Table {{{
prettyTab() {
    if [[ $TABLE_GRID_STYLE == "fancy_grid" ]]; then
        # Can't cut as lines are unicode, 2 chars!
        tabulate -1 -f ${TABLE_GRID_STYLE} -s ${TAB} | grep -v "├.*┼.*┤" | sed -e 's/^\(│[ ]*\)"/\1 /' -e 's/"\([ ]*│\)$/ \1/'
    else
        tabulate -1 -f ${TABLE_GRID_STYLE} -s ${TAB} \
            | grep -v "^+-.*+.*+" \
            | sed -e 's/^\(|[ ]*\)"/\1 /' -e 's/"\([ ]*|\)$/ \1/' \
            | cut -c 1-${COLS} \
            | sed \
                    -e "1s/| /| ${H}/g" \
                    -e "s/=+=/=╪=/g" \
                    -e "s/==/══/g" \
                    -e "s/=╪/═╪/g" \
                    -e "s/^+/${C}╞/" \
                    -e "s/=+\$/═╡${R}/" \
                    -e "s/═+\$/═╡${R}/" \
                    -e "s/^| /${C}│${R} /g" \
                    -e "s/ |\$/ ${C}│${R}/g" \
                    -e "s/ | / ${C}│${R} /g" \
                    -e "s/=\$/═${R}/"
    fi
}
#}}}

# Previewers {{{

# Show Image in Kitty? {{{2
tryCachedImage() {
    # If cached image exists and is newer than file, use it!
    if [[ -f $IMAGE_CACHE_PATH_JPG ]] && [[ $IMAGE_CACHE_PATH_JPG -nt $FILE_PATH ]]; then
        if $INFO_VERBOSE; then
            outnonl $green "Information: "
            info=$(identify -format "t:%m w:%wpx h:%hpx\n" $FILE_PATH)
            outnl $yellow "$info"
        fi

        if $NOT_IN_RANGER; then
            kitty +kitten icat $FILE_PATH
        fi

        exit $STAT_SHOW_CACHED_IMAGE
    fi
}
#}}}2

# Preview Text files with Syntax highlighting and line numbers {{{2
previewTxtFile() {
    if [[ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
        handle_fallback
    fi

    # -c 'lua lvim.builtin.which_key.active=false' \
    # --cmd 'let no_plugin_maps = 1' \
    # nvim \
        # --cmd "set runtimepath+=$HOME/.local/share/lunarvim/lvim" \
        # -c 'runtime! macros/less.vim' \
        # -c 'set norelativenumber' \
        # -c 'set nocursorcolumn' \
        # -c 'set nocursorline' \
        # -c 'set nofoldenable' \
        # -c 'set laststatus=0' \
        # -c 'highlight IncSearch NONE' \
        # --noplugin \
        # -u $HOME/.local/share/lunarvim/lvim/init.lua \
        # "${FILE_PATH}" \
        # && exit $STAT_FIX_BOTH

    env COLORTERM=8bit \
        \bat -P \
        --color=always \
        --theme=jimburn \
        --style="numbers,changes" \
        -- "${FILE_PATH}" && exit $STAT_FIX_BOTH

    local pygmentize_format='terminal'
    local highlight_format='ansi'

    if [[ "$( tput colors )" -ge 256 ]]; then
        pygmentize_format='terminal256'
        highlight_format='xterm256'
    fi

    env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" \
        highlight \
            --line-numbers \
            --out-format="${highlight_format}" \
            --force -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
    pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}"\
        -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
    cat "${FILE_PATH}" && exit $STAT_FIX_BOTH
}
#}}}2

# Preview Media Information {{{2
previewMedia() {
    mediainfo "${FILE_PATH}" && exit $STAT_FIX_BOTH
    exiftool "${FILE_PATH}" && exit $STAT_FIX_BOTH
    exit $STAT_NO_PREVIEW
}
#}}}2

# Preview Video {{{2
previewVideo() {
    tryCachedImage
    ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH_JPG}" -s 0
    tryCachedImage
}
#}}}2

# Preview Images {{{2
previewImage() {
    tryCachedImage
    $MAGICK "${FILE_PATH}[0]" \
        -auto-orient \
        -set option:origsize "%wx%h" \
        \( -size '%[origsize]' tile:pattern:checkerboard -brightness-contrast 50,10 \) \
        -resize "${DEFAULT_SIZE}>" \
        +repage \
        +swap \
        -compose over \
        -composite \
        "${IMAGE_CACHE_PATH_JPG}" > /dev/null 2>&1
    tryCachedImage

    ## If orientation data is present and the image actually
    ## needs rotating ("1" means no rotation)...
    # local orientation="$( identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" > /dev/null 2>&1 )"

    # if [[ -n "$orientation" && "$orientation" != 1 ]]; then
        ## ...auto-rotate the image according to the EXIF data.
        # convert -- "${FILE_PATH}[0]" -auto-orient "${IMAGE_CACHE_PATH_JPG}" >/dev/null 2>&1 && exit $STAT_SHOW_CACHED_IMAGE
    # fi

    # convert -- "${FILE_PATH}[0]" "${IMAGE_CACHE_PATH_JPG}" >/dev/null 2>&1 && exit $STAT_SHOW_CACHED_IMAGE
    exit $STAT_NO_PREVIEW
}
#}}}2

# Preview Font {{{2
previewFont() {
    tryCachedImage

    if fontimage -o "${IMAGE_CACHE_PATH_PNG}" \
        --pixelsize "60" \
        --fontname \
        --pixelsize "40" \
        --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
        --text "  abcdefghijklmnopqrstuvwxyz  " \
        --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
        --text "  The quick brown fox jumps over the lazy dog.  " \
        "${FILE_PATH}" > /dev/null 2>&1;
    then
        convert -- "${IMAGE_CACHE_PATH_PNG}" "${IMAGE_CACHE_PATH_JPG}" >/dev/null 2>&1 \
            && rm "${IMAGE_CACHE_PATH_PNG}"
        tryCachedImage
    fi

    exit $STAT_NO_PREVIEW
}
#}}}2

# Preview Spreadsheets, CSV and TSV files {{{2
# Tab and comma separated files preview.
# See: https://csvkit.readthedocs.io/en/latest/
#     sudo pip install csvkit
#     sudo apt install xlsx2csv
previewSpreadsheet() {
    local file_type="$1"

    case "${file_type}" in
        tsv | csv)
            csvformat -T "${FILE_PATH}" | prettyTab && exit $STAT_FIX_BOTH
            ;;

        xlsx)
            q=$(in2csv -H "${FILE_PATH}" | sed -e '1d' -e '3,$d' -e 's/,.*//')
            n=1

            in2csv -n "${FILE_PATH}" | while IFS= read -r sheet
            do
                outnl $yellow "Sheet $n : $sheet"
                n=$((n+1))

                if [[ $q == "Query:" ]]; then
                    # in2csv --sheet "$sheet" -H "${FILE_PATH}" | sed -e '1d' -e '4,$d' -e 's/,*$//' -e 's/:,/:\t/'
                    # echo

                    if [[ "$sheet" =~ \=0$ ]]; then
                        outnl $red "No data found"
                    else
                        in2csv --sheet "$sheet" -K 4 "${FILE_PATH}" | csvformat -T | prettyTab
                    fi
                else
                    in2csv --sheet "$sheet" "${FILE_PATH}" | csvformat -T | prettyTab
                fi

                echo
            done

            exit $STAT_FIX_BOTH
            ;;

        xls)
            xls2csv "${FILE_PATH}" | csvformat -T | prettyTab && exit $STAT_FIX_BOTH
            ;;
    esac
}
#}}}2

# Preview Office Documents NOT Spreadsheets {{{2
previewOffice() {
    tryCachedImage

    /opt/libreoffice/program/soffice --convert-to jpg --outdir "${IMAGE_CACHE_PATH_JPG}xxx.jpg" "${FILE_PATH}" > /dev/null 2>&1 \
        && convert "${IMAGE_CACHE_PATH_JPG}xxx.jpg/${FILE_NAME_NO_EXTENSION}jpg" -resize "${DEFAULT_SIZE}>" +repage "${IMAGE_CACHE_PATH_JPG}" >/dev/null 2>&1 \
        && rm "${IMAGE_CACHE_PATH_JPG}xxx.jpg/${FILE_NAME_NO_EXTENSION}jpg" \
        && rmdir "${IMAGE_CACHE_PATH_JPG}xxx.jpg"

    tryCachedImage

    ## Preview as text conversion
    odt2txt "${FILE_PATH}" && exit $STAT_FIX_BOTH
    ## Preview as markdown conversion
    pandoc -s -t markdown -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
}
#}}}2

#}}}

# handle_extension {{{
handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        ## Markdown
        md)
            catmd "${FILE_PATH}" && exit $STAT_FIX_BOTH
            # glow -s ~/bin/glowStyle.json "${FILE_PATH}" && exit $STAT_FIX_BOTH
            # glow -s dark "${FILE_PATH}" && exit $STAT_FIX_BOTH
            # nd "${FILE_PATH}" && exit $STAT_FIX_BOTH
            # msee "${FILE_PATH}" && exit $STAT_FIX_BOTH
            # mdcat "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        ## Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tz|tzo|war|xpi|xz|z|zip)
            atool --list -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            bsdtar --list --file "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        rar)
            ## Avoid password prompt by providing empty password
            unrar lt -p- -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        7z)
            ## Avoid password prompt by providing empty password
            7z l -p -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        ## Font
        ttf)
            previewFont
            ;;

        ## BitTorrent
        torrent)
            transmission-show -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        ## Text
        txt | edi | properties | gradle | sql | java | sh)
            if [[ $FILE_NAME_NO_EXTENSION =~ der2_* ]]; then
                previewSpreadsheet "tsv"
                exit 1
            fi

            previewTxtFile
            ;;

        tsv | csv | xlsx | xls)
            previewSpreadsheet "$FILE_EXTENSION_LOWER"
            ;;

        ## OpenDocument
        odt|ods|odp|sxw|docx|ppt|pptx|doc|rtf|odg)
            previewOffice
            ;;

        ## Image
        bmp|eps|ps|gif|tif|tiff|jpg|jpeg|pdf|png|fax|ai)
            previewImage
            ;;

        ## HTML
        htm|html|xhtml)
            if $INFO_VERBOSE; then
                outnl $yellow "Preview HTML as webpage, if blank use real cat as the file could be empty"
                outhr
            else
                echo "Preview HTML as webpage, if blank use real cat as the file could be empty"
            fi

            w3m -dump "${FILE_PATH}" && outhr && exit $STAT_FIX_BOTH
            lynx -dump -- "${FILE_PATH}" && outhr && exit $STAT_FIX_BOTH
            elinks -dump "${FILE_PATH}" && outhr && exit $STAT_FIX_BOTH
            pandoc -s -t markdown -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;

        json)
            env COLORTERM=8bit \
                jq --color-output . "${FILE_PATH}" | \
                    bat --color=always \
                        --theme=jimburn \
                        --paging never \
                        --style="numbers,changes" \
                            && exit $STAT_FIX_BOTH
            ;;

        ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected by file(1).
        dff|dsf|wv|wvc)
            previewMedia
            ;;
    esac
}
#}}}

# handle_mime {{{
handle_mime() {
    local mimetype="$(file --dereference --brief --mime-type -- "${FILE_PATH}" 2>&1)"

    case "${mimetype}" in
        ## DjVu
        image/vnd.djvu)
            ddjvu -format=tiff -quality=90 -page=1 -size="${DEFAULT_SIZE}" \
                  - "${IMAGE_CACHE_PATH_JPG}" < "${FILE_PATH}" \
                  && exit $STAT_SHOW_CACHED_IMAGE
            ## Preview as text conversion (requires djvulibre)
            djvutxt "${FILE_PATH}" | fmt -w "${PV_WIDTH}" && exit $STAT_FIX_BOTH
            previewMedia
            exit $STAT_NO_PREVIEW;;


        image/*)
            previewImage
            exit $STAT_SHOW_IMAGE;;

        audio/*)
            previewMedia
            exit $STAT_NO_PREVIEW;;

        video/*)
            previewVideo
            previewMedia
            exit $STAT_NO_PREVIEW;;


        application/json)
            env COLORTERM=8bit \
                jq --color-output . "${FILE_PATH}" | \
                    bat --color=always \
                        --theme=jimburn \
                        --paging never \
                        --style="numbers,changes" \
                            && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;

        ## ePub, MOBI, FB2 (using Calibre)
        application/epub+zip|application/x-mobipocket-ebook|application/x-fictionbook+xml)
            ## ePub (using https://github.com/marianosimone/epub-thumbnailer)
            epub-thumbnailer "${FILE_PATH}" "${IMAGE_CACHE_PATH_JPG}" \
                "${DEFAULT_SIZE%x*}" && exit $STAT_SHOW_CACHED_IMAGE
            ebook-meta --get-cover="${IMAGE_CACHE_PATH_JPG}" -- "${FILE_PATH}" \
                >/dev/null && exit $STAT_SHOW_CACHED_IMAGE
            exit $STAT_NO_PREVIEW;;

        ## Font
        application/font*|application/*opentype)
            previewFont
            exit $STAT_NO_PREVIEW;;

        ## RTF and DOC
        text/rtf|*msword)
            ## Preview as text conversion
            ## note: catdoc does not always work for .doc files
            ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
            catdoc -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;

        ## DOCX, ePub, FB2 (using markdown)
        ## You might want to remove "|epub" and/or "|fb2" below if you have
        ## uncommented other methods to preview those formats
        *wordprocessingml.document|*/epub+zip|*/x-fictionbook+xml)
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;

        ## XLS
        *ms-excel)
            previewSpreadsheet "xls"
            exit $STAT_NO_PREVIEW;;

        ## Text
        text/* | */xml)
            previewTxtFile
            exit $STAT_NO_PREVIEW;;

    ## Preview archives using the first image inside.
    ## (Very useful for comic book collections for example.)
    # application/zip|application/x-rar|application/x-7z-compressed|\
    #     application/x-xz|application/x-bzip2|application/x-gzip|application/x-tar)
    #     local fn=""; local fe=""
    #     local zip=""; local rar=""; local tar=""; local bsd=""
    #     case "${mimetype}" in
    #         application/zip) zip=1 ;;
    #         application/x-rar) rar=1 ;;
    #         application/x-7z-compressed) ;;
    #         *) tar=1 ;;
    #     esac
    #     { [ "$tar" ] && fn=$(tar --list --file "${FILE_PATH}"); } || \
    #     { fn=$(bsdtar --list --file "${FILE_PATH}") && bsd=1 && tar=""; } || \
    #     { [ "$rar" ] && fn=$(unrar lb -p- -- "${FILE_PATH}"); } || \
    #     { [ "$zip" ] && fn=$(zipinfo -1 -- "${FILE_PATH}"); } || return
    #
    #     fn=$(echo "$fn" | python -c "import sys; import mimetypes as m; \
    #             [ print(l, end='') for l in sys.stdin if \
    #               (m.guess_type(l[:-1])[0] or '').startswith('image/') ]" |\
    #         sort -V | head -n 1)
    #     [ "$fn" = "" ] && return
    #     [ "$bsd" ] && fn=$(printf '%b' "$fn")
    #
    #     [ "$tar" ] && tar --extract --to-stdout \
    #         --file "${FILE_PATH}" -- "$fn" > "${IMAGE_CACHE_PATH_JPG}" && exit $STAT_SHOW_CACHED_IMAGE
    #     fe=$(echo -n "$fn" | sed 's/[][*?\]/\\\0/g')
    #     [ "$bsd" ] && bsdtar --extract --to-stdout \
    #         --file "${FILE_PATH}" -- "$fe" > "${IMAGE_CACHE_PATH_JPG}" && exit $STAT_SHOW_CACHED_IMAGE
    #     [ "$bsd" ] || [ "$tar" ] && rm -- "${IMAGE_CACHE_PATH_JPG}"
    #     [ "$rar" ] && unrar p -p- -inul -- "${FILE_PATH}" "$fn" > \
    #         "${IMAGE_CACHE_PATH_JPG}" && exit $STAT_SHOW_CACHED_IMAGE
    #     [ "$zip" ] && unzip -pP "" -- "${FILE_PATH}" "$fe" > \
    #         "${IMAGE_CACHE_PATH_JPG}" && exit $STAT_SHOW_CACHED_IMAGE
    #     [ "$rar" ] || [ "$zip" ] && rm -- "${IMAGE_CACHE_PATH_JPG}"
    #     ;;
    # openscad_image() {
    #     TMPPNG="$(mktemp -t XXXXXX.png)"
    #     openscad --colorscheme="${OPENSCAD_COLORSCHEME}" \
    #         --imgsize="${OPENSCAD_IMGSIZE/x/,}" \
    #         -o "${TMPPNG}" "${1}"
    #     mv "${TMPPNG}" "${IMAGE_CACHE_PATH_JPG}"
    # }
    # case "${FILE_EXTENSION_LOWER}" in
    #     ## 3D models
    #     ## OpenSCAD only supports png image output, and ${IMAGE_CACHE_PATH_JPG}
    #     ## is hardcoded as jpeg. So we make a tempfile.png and just
    #     ## move/rename it to jpg. This works because image libraries are
    #     ## smart enough to handle it.
    #     csg|scad)
    #         openscad_image "${FILE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
    #         ;;
    #     3mf|amf|dxf|off|stl)
    #         openscad_image <(echo "import(\"${FILE_PATH}\");") && exit $STAT_SHOW_CACHED_IMAGE
    #         ;;
    esac
}
#}}}

# handle_mime {{{
handle_fallback() {
    local mimetype="$(file --dereference --brief --mime-type -- "${FILE_PATH}" 2>&1)"
    local mime=$(file --dereference --brief -- "${FILE_PATH}" | tr -dc '[[:print:]]')

    echo -n "Mime info:"
    outnl $yellow "  $mime"
    echo -n "          "
    outnl $yellow "  $mimetype"
    echo

    echo -n "ls -l:      "
    while read -r line; do
        echo "$line"
        echo -n "            "
    done<<<$(eza --colour=always -F --git --group-directories-first --icons -l -h "${FILE_PATH}")
    echo

    echo "Contents:"
    cat "${FILE_PATH}"
    echo

    exit $STAT_FIX_BOTH
}
#}}}

# Main {{{
if [[ -d "$FILE_PATH" ]]; then
    handle_fallback
fi

handle_extension
handle_mime
handle_fallback
#}}}

exit $STAT_NO_PREVIEW

