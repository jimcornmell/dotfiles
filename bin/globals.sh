#!/usr/bin/env bash

# Standard print layouts used by the scripts in this folder.

# See http://linuxcommand.org/lc3_adv_tput.php

# Colours used in scripts etc.
export black=0
export grey=8
export red=1
export green=2
export yellow=3
export blue=4
export magenta=5
export cyan=6
export white=7
export boldred=9
export boldgreen=10
export boldyellow=11
export boldblue=12
export boldmagenta=13
export boldcyan=14
export boldwhite=15

# Colours for the project branch information for consistency.
export coltext=2
export colbranch=5
export colproject=1
export foreground=$green
export background=$black

COLOUR_TERMINAL=$(tput colors 2> /dev/null)
if [ $? -eq 0 ] || [ $COLOUR_TERMINAL -gt 8 ]; then
    COLOUR_SUPPORTED=true
else
    COLOUR_SUPPORTED=false
fi

function runCmd {
    xdg-open $1 > /dev/null 2>&1
}

function setforeground() {
    export foreground=$1
    if [ "$COLOUR_SUPPORTED" ]; then
        tput setaf $1
    fi
}

function setbackground() {
    export background=$1
    if [ "$COLOUR_SUPPORTED" ]; then
        # Some terminals honour black to mean black, other treat it as
        # terminal background colour, we always want the latter.
        if [ $1 -eq $black ]
        then
            tput sgr0
            tput setaf $foreground
        else
            tput setab $1
        fi
    fi
}

function setcolour() {
    setforeground $1
    setbackground $2
}

function resetcolour() {
    export foreground=$green
    export background=$black
    if [ "$COLOUR_SUPPORTED" ]; then
        tput sgr0
    fi
}

# Output with no new lines.
# outnonl COLOUR TEXT
# e.g.
# outnonl $yellow "Hello World"
function outnonl() {
    setforeground $1
    echo -n "$2"
    resetcolour
}

# Output with new lines.
# outnl COLOUR TEXT
# e.g.
# outnl $yellow "Hello World"
function outnl() {
    setforeground $1
    echo "$2"
    resetcolour
}

# Output with new lines and wait for user.
# outwait COLOUR TEXT
# e.g.
# outwait $yellow "Hello World"
function outwait {
    setforeground $1
    read -n 1 -p "$2"
    resetcolour
}

# Output standard project line with branch.
# outprojinfo COLOUR PROJECT BRANCH
# e.g.
# outprojinfo $yellow "Project-Name" "BIL-1234"
function outprojinfo {
    outnonl $coltext "$1"
    outnonl $colproject "$2"

    if [[ -z "$3" ]]; then
        echo
    else
        outnonl $coltext " ("
        outnonl $colbranch "$3"
        outnl $coltext ")"
    fi
}

################################################################################
# Boxes: https://unicode.org/charts/PDF/U2500.pdf

function setboxfg() {
    boxfg=$1
}
function setboxbg() {
    boxbg=$1
}
function setboxtextfg() {
    boxtextfg=$1
}
function setboxtextbg() {
    boxtextbg=$1
}
function setboxtextjustify() {
    boxtextjustify=$1
}
function setboxwidth() {
    boxwidth=$1
}
function setboxmargin() {
    boxmargin=$1
}

function setboxstyle() {
    style=$1 # Style one of, HASH, BLANK, SINGLE, DOUBLE, MIXEDDH, MIXEDSH
    boxstyle=$style

    case $style in
    HASH)
        pH="#"
        pV="#"
        pTL="#"
        pTR="#"
        pBL="#"
        pBR="#"
        pVL="#"
        pVR="#"
        pDH="#"
        pUH="#"
        pVH="#"
        ;;
    BLANK)
        pH=" "
        pV=" "
        pTL=" "
        pTR=" "
        pBL=" "
        pBR=" "
        pVL=" "
        pVR=" "
        pDH=" "
        pUH=" "
        pVH=" "
        ;;
    SINGLE)
        pH="\u2500"     # ─ SINGLE HORIZONTAL
        pV="\u2502"     # │ SINGLE VERTICAL
        pTL="\u250C"    # ┌ SINGLE DOWN AND RIGHT
        pTR="\u2510"    # ┐ SINGLE DOWN AND LEFT
        pBL="\u2514"    # └ SINGLE UP AND RIGHT
        pBR="\u2518"    # ┘ SINGLE UP AND LEFT
        pVL="\u2524"    # ┤ SINGLE VERTICAL AND LEFT
        pVR="\u251C"    # ├ SINGLE VERTICAL AND RIGHT
        pDH="\u252C"    # ┬ SINGLE DOWN AND HORIZONTAL
        pUH="\u2534"    # ┴ SINGLE UP AND HORIZONTAL
        pVH="\u253C"    # ┼ SINGLE VERTICAL AND HORIZONTAL
        ;;
    DOUBLE)
        pH="\u2550"     # ═ DOUBLE HORIZONTAL
        pV="\u2551"     # ║ DOUBLE VERTICAL
        pTL="\u2554"    # ╔ DOUBLE DOWN AND RIGHT
        pTR="\u2557"    # ╗ DOUBLE DOWN AND LEFT
        pBL="\u255A"    # ╚ DOUBLE UP AND RIGHT
        pBR="\u255D"    # ╝ DOUBLE UP AND LEFT
        pVL="\u2563"    # ╣ DOUBLE VERTICAL AND LEFT
        pVR="\u2560"    # ╠ DOUBLE VERTICAL AND RIGHT
        pDH="\u2566"    # ╦ DOUBLE DOWN AND HORIZONTAL
        pUH="\u2569"    # ╩ DOUBLE UP AND HORIZONTAL
        pVH="\u256C"    # ╬ DOUBLE VERTICAL AND HORIZONTAL
        ;;
    MIXEDDH)
        pH="\u2550"     # ═ DOUBLE HORIZONTAL
        pV="\u2502"     # │ SINGLE VERTICAL
        pTL="\u2552"    # ╒ DOWN SINGLE AND RIGHT DOUBLE
        pTR="\u2555"    # ╕ DOWN SINGLE AND LEFT DOUBLE
        pBL="\u2558"    # ╘ UP SINGLE AND RIGHT DOUBLE
        pBR="\u255B"    # ╛ UP SINGLE AND LEFT DOUBLE
        pVL="\u2561"    # ╡ VERTICAL SINGLE AND LEFT DOUBLE
        pVR="\u255E"    # ╞ VERTICAL SINGLE AND RIGHT DOUBLE
        pDH="\u2564"    # ╤ DOWN SINGLE AND HORIZONTAL DOUBLE
        pUH="\u2567"    # ╧ UP SINGLE AND HORIZONTAL DOUBLE
        pVH="\u256A"    # ╪ VERTICAL SINGLE AND HORIZONTAL DOUBLE
        ;;
    MIXEDSH)
        pH="\u2500"     # ─ SINGLE HORIZONTAL
        pV="\u2551"     # ║ DOUBLE VERTICAL
        pTL="\u2553"    # ╓ DOWN DOUBLE AND RIGHT SINGLE
        pTR="\u2556"    # ╖ DOWN DOUBLE AND LEFT SINGLE
        pBL="\u2559"    # ╙ UP DOUBLE AND RIGHT SINGLE
        pBR="\u255C"    # ╜ UP DOUBLE AND LEFT SINGLE
        pVL="\u2562"    # ╢ VERTICAL DOUBLE AND LEFT SINGLE
        pVR="\u255F"    # ╟ VERTICAL DOUBLE AND RIGHT SINGLE
        pDH="\u2565"    # ╥ DOWN DOUBLE AND HORIZONTAL SINGLE
        pUH="\u2568"    # ╨ UP DOUBLE AND HORIZONTAL SINGLE
        pVH="\u256B"    # ╫ VERTICAL DOUBLE AND HORIZONTAL SINGLE
        ;;
    esac
}

function setboxdefaults() {
    boxfg=$green
    boxbg=$black
    boxtextfg=$green
    boxtextbg=$black
    boxwidth=80
    boxmargin=0
    setboxstyle SINGLE
    setboxtextjustify CENTRE
}

function boxinfo() {
    echo "BOX CONFIGURATION"
    echo "    FG=$boxfg"
    echo "    BG=$boxbg"
    echo "    TEXT FG=$boxtextfg"
    echo "    TEXT BG=$boxtextbg"
    echo "    WIDTH=$boxwidth"
    echo "    MARGIN=$boxmargin"
    echo "    STYLE=$boxstyle"
    echo "    JUSTIFY=$boxtextjustify"
}

# Output single character.
# outchar CHAR
function outchar() {
    echo -e -n "$1"
}

# Output same character many times.
function outchars() {
    n=$1 # number to output
    c=$2 # char to output
    for ((i = 0 ; i < $n ; i++))
    do
        echo -e -n "$c"
    done
}

# Output some text in the centre.
# outcentre COLOUR CHAR TEXT
# e.g.
# outcentre $red "#" " Some text "
function outcentre {
    col=$1
    char=$2
    str=$3
    strw=${#str}
    w=$((boxwidth))
    l=$((w/2-strw/2))
    r=$((w/2-strw/2))
    r=$(((w-l-r-strw)+r))
    setforeground $col
    outchars $l "$char"
    echo -n "$str"
    outchars $r "$char"
    resetcolour
    echo
}

# Output some text in the centre with horizontal line either side.
# outcentreline COLOUR TEXT
# e.g.
# outcentreline $red " Some text "
function outcentreline {
    outcentre $1 "$pH" "$2"
}

function boxtop() {
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    outchar $pTL
    outchars $((boxwidth-2)) $pH
    outchar $pTR
    resetcolour
    echo
}

function boxmid() {
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    outchar $pVR
    outchars $((boxwidth-2)) $pH
    outchar $pVL
    resetcolour
    echo
}

function boxmidspecial() {
    str=$1
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    for ((i = 0 ; i < ${#str} ; i++))
    do
        c=${str:$i:1}
        if [[ "$c" == "-" ]]; then
            echo -e -n "$pH"
        elif [[ "$c" == "|" ]]; then
            echo -e -n "$pV"
        elif [[ "$c" == "+" ]]; then
            echo -e -n "$pVH"
        elif [[ "$c" == "L" ]]; then
            echo -e -n "$pVL"
        elif [[ "$c" == "R" ]]; then
            echo -e -n "$pVR"
        elif [[ "$c" == "D" ]]; then
            echo -e -n "$pDH"
        elif [[ "$c" == "U" ]]; then
            echo -e -n "$pUH"
        elif [[ "$c" == "l" ]]; then
            echo -e -n "$pTL"
        elif [[ "$c" == "r" ]]; then
            echo -e -n "$pTR"
        elif [[ "$c" == "j" ]]; then
            echo -e -n "$pBL"
        elif [[ "$c" == "k" ]]; then
            echo -e -n "$pBR"
        else
            echo -e -n "$c"
        fi
    done
    resetcolour
    echo
}

function boxtextjustifiedline() {
    str=$(echo $1 | sed 's/\t/ /g') # Text to output, with no tabs.
    w=$((boxwidth-2))
    strw=${#str}
    l=$((w/2-strw/2))
    r=$((w/2-strw/2))
    r=$(((w-l-r-strw)+r))
    setforeground $boxtextfg
    setbackground $boxtextbg
    if [ $boxtextjustify == LEFT ]; then
        echo -n "$str"
        outchars $l " "
        outchars $r " "
    elif [ $boxtextjustify == RIGHT ]; then
        outchars $l " "
        outchars $r " "
        echo -n "$str"
    elif [ $boxtextjustify == CENTRE ]; then
        outchars $l " "
        echo -n "$str"
        outchars $r " "
    fi
    # TODO: SPLIT
    # TODO: JUSTIFY
}

function boxtextline() {
    str=$1
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    outchar $pV

    boxtextjustifiedline "$str"

    setforeground $boxfg
    setbackground $boxbg
    outchar $pV
    resetcolour
}

function boxtext() {
    lines="$1"
    while IFS= read -r line; do
        boxtextline "$line"
        echo
    done <<< "$lines"
}

function boxtextcolumns() {
    colourTitle="$1"
    colourText="$2"
    numCols="$3"
    oldwidth=$boxwidth
    t=$((numCols+4))
    setboxtextfg $colourTitle
    setforeground $boxfg
    setbackground $boxbg
    outchar $pV

    for ((j = 4 ; j < $((numCols+4)) ; j++))
    do
        setboxwidth ${!j}
        boxtextjustifiedline "${!t}"
        t=$((t+1))
        setforeground $boxfg
        setbackground $boxbg
        outchar $pV
    done
    resetcolour
    echo

    setforeground $boxfg
    setbackground $boxbg
    outchar $pV
    setboxtextfg $colourText
    for ((j = 4 ; j < $((numCols+4)) ; j++))
    do
        setboxwidth ${!j}
        boxtextjustifiedline "${!t}"
        t=$((t+1))
        setforeground $boxfg
        setbackground $boxbg
        outchar $pV
    done
    resetcolour
    echo

    setboxwidth $oldwidth
}

function boxbottom() {
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    outchar $pBL
    outchars $((boxwidth-2)) $pH
    outchar $pBR
    resetcolour
    echo
}

# Ouput simple box.
function outbox() {
    str=$1 # Text to output.
    boxtop
    boxtext "$str"
    boxbottom
}

# Ouput error box.
function outerrorbox() {
    str=$1 # Text to output.

    errobxorigtextfg=$boxtextfg
    errobxorigtextbg=$boxtextbg
    errobxorigfg=$boxfg
    errobxorigbg=$boxbg

    setboxtextfg $black
    setboxtextbg $red
    setboxfg $black
    setboxbg $red

    origboxwidth=$boxwidth
    width=${#str}
    setboxwidth $((width+2))

    boxtop
    boxtext "$str"
    boxbottom

    setboxtextfg $errobxorigtextfg
    setboxtextbg $errobxorigtextbg
    setboxfg $errobxorigfg
    setboxbg $errobxorigbg
    setboxwidth $origboxwidth
}

function resetcolour() {
    export foreground=$green
    export background=$black
    if [ "$COLOUR_SUPPORTED" ]; then
        tput sgr0
    fi
}

# Horizontal ruler.
function outhr {
    outchars $boxmargin " "
    setforeground $boxfg
    setbackground $boxbg
    outchars $boxwidth $pH
    resetcolour
    echo
}

function outruler() {
    outchar $pVR
    outchars 8 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVH
    outchars 9 $pH
    outchar $pVL
    echo
}

setboxdefaults

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}
