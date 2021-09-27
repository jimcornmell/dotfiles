#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:    code | meaning    | action of ranger
##                            -----+------------+-------------------------------------------
STAT_SUCCESS=0             ## 0    | success    | Display stdout as preview
STAT_NO_PREVIEW=1          ## 1    | no preview | Display no preview at all
STAT_PLAIN_TEXT=2          ## 2    | plain text | Display the plain content of the file
STAT_FIX_WIDTH=3           ## 3    | fix width  | Don't reload when width changes
STAT_FIX_HEIGHT=4          ## 4    | fix height | Don't reload when height changes
STAT_FIX_BOTH=5            ## 5    | fix both   | Don't ever reload
STAT_SHOW_CACHED_IMAGE=6   ## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
STAT_SHOW_IMAGE=7          ## 7    | image      | Display the file directly as an image

## Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file
PV_WIDTH="${2}"          # Width of the preview pane (number of fitting characters)
PV_HEIGHT="${3}"         # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.
DEFAULT_SIZE="750x750"

if [[ $# -ge 6 ]]; then
    KITTY="${6}"         # 'True' if in kitty terminal.
else
    KITTY="False"
fi

if [[ $# -ge 7 ]]; then
    LESS="${7}"          # Pass text through less.
else
    LESS="False"
fi

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_NAME="$(basename $FILE_PATH)"
FILE_NAME_NO_EXTENSION="$(basename $FILE_PATH $FILE_EXTENSION)"
FILE_EXTENSION_LOWER="${FILE_EXTENSION,,}"

JQ_COLORS="1;33:4;33:0;33:0;33:0;32:1;37:1;37"

## Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH=${HIGHLIGHT_TABWIDTH:-8}
HIGHLIGHT_STYLE=${HIGHLIGHT_STYLE:-zenburn}
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE=${PYGMENTIZE_STYLE:-zenburn}
OPENSCAD_IMGSIZE=${RNGR_OPENSCAD_IMGSIZE:-1000,1000}
OPENSCAD_COLORSCHEME=${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}

KITTY_SHOW() {
    f="$*"

    if [[ -e "$f" ]]; then
        kitty +kitten icat "$f"
    else
        f="${IMAGE_CACHE_PATH}$(basename $* .png)-0.png"
        kitty +kitten icat "$f"
    fi
}

showFileSyntax() {
    # -c 'lua lvim.builtin.which_key.active=false' \
    # --cmd 'let no_plugin_maps = 1' \
    nvim \
        --cmd "set runtimepath+=$HOME/.local/share/lunarvim/lvim" \
        -c 'runtime! macros/less.vim' \
        -c 'set norelativenumber' \
        -c 'set nocursorcolumn' \
        -c 'set nocursorline' \
        -c 'set nofoldenable' \
        -c 'set laststatus=0' \
        -c 'highlight IncSearch NONE' \
        --noplugin \
        -u $HOME/.local/share/lunarvim/lvim/init.lua \
        "${FILE_PATH}" \
    && exit $STAT_FIX_BOTH
}

previewTxtFile() {
    if [[ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
        exit $STAT_PLAIN_TEXT
    fi

    if [[ "${KITTY}" == 'True' ]]; then
        showFileSyntax "${FILE_PATH}"
    fi

    if [[ "${LESS}" == 'True' ]]; then
        env COLORTERM=8bit \
            bat \
                --color=always \
                --theme=jimburn \
                --style="numbers,changes" \
                -- "${FILE_PATH}"
        exit $STAT_FIX_BOTH
    else
        env COLORTERM=8bit \
            bat -P \
                --color=always \
                --theme=jimburn \
                --style="numbers,changes" \
                -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
    fi

    cat "${FILE_PATH}" && exit $STAT_FIX_BOTH

    if [[ "$( tput colors )" -ge 256 ]]; then
        local pygmentize_format='terminal256'
        local highlight_format='xterm256'
    else
        local pygmentize_format='terminal'
        local highlight_format='ansi'
    fi

    env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" \
        highlight \
            --line-numbers \
            --out-format="${highlight_format}" \
            --force -- "${FILE_PATH}" && exit $STAT_FIX_BOTH

    pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}"\
        -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
}

previewImage() {
    if [[ "${KITTY}" == 'True' ]]; then
        convert "${FILE_PATH}" -resize $DEFAULT_SIZE +repage -auto-orient "${IMAGE_CACHE_PATH}${FILE_NAME}.png" >/dev/null 2>&1 \
            && KITTY_SHOW "${IMAGE_CACHE_PATH}${FILE_NAME}.png" \
            && exit $STAT_SHOW_IMAGE
    fi

    local orientation
    orientation="$( identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" > /dev/null 2>&1 )"

    ## If orientation data is present and the image actually
    ## needs rotating ("1" means no rotation)...
    if [[ -n "$orientation" && "$orientation" != 1 ]]; then
        ## ...auto-rotate the image according to the EXIF data.
        convert -- "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
    fi

    convert -- "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
    exit $STAT_SHOW_IMAGE
}

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        ## Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tz|tzo|war|xpi|xz|z|zip)
            atool --list -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            bsdtar --list --file "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        rar)
            ## Avoid password prompt by providing empty password
            unrar lt -p- -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        7z)
            ## Avoid password prompt by providing empty password
            7z l -p -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        ## Font
        ttf)
            preview_png="/tmp/$(basename "${IMAGE_CACHE_PATH%.*}").png"
            if fontimage -o "${preview_png}" \
                         --pixelsize "120" \
                         --fontname \
                         --pixelsize "80" \
                         --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
                         --text "  abcdefghijklmnopqrstuvwxyz  " \
                         --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
                         --text "  The quick brown fox jumps over the lazy dog.  " \
                         "${FILE_PATH}" > /dev/null 2>&1;
            then
                convert -- "${preview_png}" "${IMAGE_CACHE_PATH}" > /dev/null 2>&1 \
                    && rm "${preview_png}" \
                    && exit $STAT_SHOW_CACHED_IMAGE
            fi

            if [[ "${KITTY}" == 'True' ]]; then
                mv "$preview_png" "${IMAGE_CACHE_PATH}${FILE_NAME}.png"
                KITTY_SHOW "${IMAGE_CACHE_PATH}${FILE_NAME}.png" \
                    && exit $STAT_SHOW_IMAGE
            fi

            exit $STAT_NO_PREVIEW
            ;;

        ## BitTorrent
        torrent)
            transmission-show -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        ## Text
        txt | edi | properties | gradle | sql | java | sh | md)
            previewTxtFile
            exit $STAT_PLAIN_TEXT
            ;;
        ## Tab and comma separated files preview.
        # See: https://csvkit.readthedocs.io/en/latest/
        tsv | csv)
            csvformat -T "${FILE_PATH}" | tabulate -1 -f fancy_grid && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        xlsx)
            xlsx2csv "${FILE_PATH}" | csvformat -T | tabulate -1 -f fancy_grid && exit $STAT_FIX_BOTH
            ;;
        xls)
            xls2csv "${FILE_PATH}" | csvformat -T | tabulate -1 -f fancy_grid && exit $STAT_FIX_BOTH
            ;;
        ## OpenDocument
        odt|ods|odp|sxw|docx|ppt|pptx|doc|docx|rtf)
            if [[ "${KITTY}" == 'True' ]]; then
                /opt/libreoffice/program/soffice --convert-to jpg --outdir "${IMAGE_CACHE_PATH}" "${FILE_PATH}" > /dev/null 2>&1 \
                    && KITTY_SHOW "${IMAGE_CACHE_PATH}${FILE_NAME_NO_EXTENSION}jpg"
                exit $STAT_SHOW_IMAGE
            else
                /opt/libreoffice/program/soffice --convert-to jpg --outdir "${IMAGE_CACHE_PATH}" "${FILE_PATH}" \
                    && mv "${IMAGE_CACHE_PATH}" "${IMAGE_CACHE_PATH}xxx" \
                    && mv "${IMAGE_CACHE_PATH}xxx/${FILE_NAME%.*}.jpg" "${IMAGE_CACHE_PATH}" \
                    && rmdir "${IMAGE_CACHE_PATH}xxx" \
                    && exit $STAT_SHOW_CACHED_IMAGE
            fi

            ## Preview as text conversion
            odt2txt "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW
            ;;
        ## Image
        bmp|eps|ps|gif|tif|tiff|jpg|jpeg|png|fax|pdf)
            previewImage
            exit $STAT_SHOW_IMAGE
            ;;
        ## HTML
        htm|html|xhtml)
            ## Preview as text conversion
            w3m -dump "${FILE_PATH}" && exit $STAT_FIX_BOTH
            lynx -dump -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            elinks -dump "${FILE_PATH}" && exit $STAT_FIX_BOTH
            pandoc -s -t markdown -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;
        ## JSON
        json)
            # echo a
            # jq --color-output . example.json | bat
            # exit $STAT_FIX_BOTH
            env COLORTERM=8bit \
                jq --color-output . "${FILE_PATH}" \
                && exit $STAT_FIX_BOTH
            env COLORTERM=8bit \
                jq --color-output . "${FILE_PATH}" | \
                bat \
                    --color=always \
                    --theme=jimburn \
                    --style="numbers,changes" \
                        && exit $STAT_FIX_BOTH
            # echo b
            # python -m json.tool -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;;
        ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
        ## by file(1).
        dff|dsf|wv|wvc)
            mediainfo "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exiftool "${FILE_PATH}" && exit $STAT_FIX_BOTH
            ;; # Continue with next handler on failure
    esac
}

handle_image() {
    ## Size of the preview if there are multiple options or it has to be
    ## rendered from vector graphics. If the conversion program allows
    ## specifying only one dimension while keeping the aspect ratio, the width
    ## will be used.

    local mimetype="${1}"
    case "${mimetype}" in
        ## DjVu
        image/vnd.djvu)
            ddjvu -format=tiff -quality=90 -page=1 -size="${DEFAULT_SIZE}" \
                  - "${IMAGE_CACHE_PATH}" < "${FILE_PATH}" \
                  && exit $STAT_SHOW_CACHED_IMAGE || exit $STAT_NO_PREVIEW;;

        ## Image
        image/*)
            previewImage
            exit $STAT_SHOW_IMAGE
            ;;

        ## Video
        video/*)
            # Thumbnail
            if [[ "${KITTY}" == 'True' ]]; then
                ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}${FILE_NAME_NO_EXTENSION}png" -s 0 \
                    && KITTY_SHOW "${IMAGE_CACHE_PATH}${FILE_NAME_NO_EXTENSION}png" && exit $STAT_SHOW_IMAGE \
                    && exit $STAT_SHOW_CACHED_IMAGE
            else
                ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" -s 0 && exit $STAT_SHOW_CACHED_IMAGE
            fi

            exit $STAT_NO_PREVIEW;;

        ## ePub, MOBI, FB2 (using Calibre)
        application/epub+zip|application/x-mobipocket-ebook|\
        application/x-fictionbook+xml)
            ## ePub (using https://github.com/marianosimone/epub-thumbnailer)
            epub-thumbnailer "${FILE_PATH}" "${IMAGE_CACHE_PATH}" \
                "${DEFAULT_SIZE%x*}" && exit $STAT_SHOW_CACHED_IMAGE
            ebook-meta --get-cover="${IMAGE_CACHE_PATH}" -- "${FILE_PATH}" \
                >/dev/null && exit $STAT_SHOW_CACHED_IMAGE
            exit $STAT_NO_PREVIEW;;

        ## Font
        application/font*|application/*opentype)
            preview_png="/tmp/$(basename "${IMAGE_CACHE_PATH%.*}").png"
            if fontimage -o "${preview_png}" \
                         --pixelsize "120" \
                         --fontname \
                         --pixelsize "80" \
                         --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
                         --text "  abcdefghijklmnopqrstuvwxyz  " \
                         --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
                         --text "  The quick brown fox jumps over the lazy dog.  " \
                         "${FILE_PATH}";
            then
                convert -- "${preview_png}" "${IMAGE_CACHE_PATH}" \
                    && rm "${preview_png}" \
                    && exit $STAT_SHOW_CACHED_IMAGE
            else
                exit $STAT_NO_PREVIEW
            fi
            ;;

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
        #         --file "${FILE_PATH}" -- "$fn" > "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
        #     fe=$(echo -n "$fn" | sed 's/[][*?\]/\\\0/g')
        #     [ "$bsd" ] && bsdtar --extract --to-stdout \
        #         --file "${FILE_PATH}" -- "$fe" > "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
        #     [ "$bsd" ] || [ "$tar" ] && rm -- "${IMAGE_CACHE_PATH}"
        #     [ "$rar" ] && unrar p -p- -inul -- "${FILE_PATH}" "$fn" > \
        #         "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
        #     [ "$zip" ] && unzip -pP "" -- "${FILE_PATH}" "$fe" > \
        #         "${IMAGE_CACHE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
        #     [ "$rar" ] || [ "$zip" ] && rm -- "${IMAGE_CACHE_PATH}"
        #     ;;
    esac

    # openscad_image() {
    #     TMPPNG="$(mktemp -t XXXXXX.png)"
    #     openscad --colorscheme="${OPENSCAD_COLORSCHEME}" \
    #         --imgsize="${OPENSCAD_IMGSIZE/x/,}" \
    #         -o "${TMPPNG}" "${1}"
    #     mv "${TMPPNG}" "${IMAGE_CACHE_PATH}"
    # }

    # case "${FILE_EXTENSION_LOWER}" in
    #     ## 3D models
    #     ## OpenSCAD only supports png image output, and ${IMAGE_CACHE_PATH}
    #     ## is hardcoded as jpeg. So we make a tempfile.png and just
    #     ## move/rename it to jpg. This works because image libraries are
    #     ## smart enough to handle it.
    #     csg|scad)
    #         openscad_image "${FILE_PATH}" && exit $STAT_SHOW_CACHED_IMAGE
    #         ;;
    #     3mf|amf|dxf|off|stl)
    #         openscad_image <(echo "import(\"${FILE_PATH}\");") && exit $STAT_SHOW_CACHED_IMAGE
    #         ;;
    # esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
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
            ## Preview as csv conversion
            ## xls2csv comes with catdoc:
            ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
            xls2csv -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;

        ## Text
        text/* | */xml)
            previewTxtFile
            exit $STAT_PLAIN_TEXT;;

        ## DjVu
        image/vnd.djvu)
            ## Preview as text conversion (requires djvulibre)
            djvutxt "${FILE_PATH}" | fmt -w "${PV_WIDTH}" && exit $STAT_FIX_BOTH
            exiftool "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;
        ## Image
        image/*)
            previewImage
            exit $STAT_SHOW_IMAGE
            ;;
        ## Video and audio
        video/* | audio/*)
            mediainfo "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exiftool "${FILE_PATH}" && exit $STAT_FIX_BOTH
            exit $STAT_NO_PREVIEW;;
    esac
}

handle_fallback() {
    if [[ "$FILE_NAME" == "Dockerfile" ]]; then
        previewTxtFile
        exit $STAT_PLAIN_TEXT
    fi

    echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit $STAT_FIX_BOTH
}

MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"

if [[ -d "$FILE_PATH" ]]; then
    exa -F --git --group-directories-first --icons -h "${FILE_PATH}"
    exit $STAT_PLAIN_TEXT
fi

if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
    handle_image "${MIMETYPE}"
fi

handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit $STAT_NO_PREVIEW

