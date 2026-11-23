#!/usr/bin/env bash
#
# host-banner.sh - print the short hostname as a rainbow block-letter banner.
#
# Meant to be called from ~/.bash_profile (see README.md). Prints nothing
# unless stdout is a terminal.
#
#   HOST_BANNER_COLOR=truecolor|256|16|none   override color detection
#   NO_COLOR=1                                disable color

[[ -t 1 ]] || exit 0
case ${TERM:-dumb} in dumb) exit 0 ;; esac

# Byte semantics: keeps pattern matching predictable and output independent of
# the host's locale. All widths are computed from the bitmaps below.
LC_ALL=C

BLOCK=$'\xe2\x96\x88'   # U+2588 FULL BLOCK in UTF-8
RESET=$'\e[0m'
GLYPH_W=5
GLYPH_H=5

# Gradient stops, evenly spaced: red orange yellow green blue purple
STOP_R=(255 255 255   0   0 160)
STOP_G=(  0 127 255 200  90  32)
STOP_B=(  0   0   0   0 255 240)
ANSI16=(31 33 93 32 34 35)      # dark yellow stands in for orange

# Set WIDTH to the terminal's column count.
get_width() {
    local size
    size=$({ stty size </dev/tty; } 2>/dev/null)
    WIDTH=${size##* }
    valid_width && return
    WIDTH=$(tput cols 2>/dev/null)
    valid_width || WIDTH=80
}

# Serial consoles often report 0 columns, so that counts as unknown.
valid_width() {
    case $WIDTH in '' | 0 | *[!0-9]*) return 1 ;; esac
}

# Set MODE to truecolor, 256, 16 or none.
get_color_mode() {
    local colors
    case ${HOST_BANNER_COLOR:-} in
        truecolor | 256 | 16 | none) MODE=$HOST_BANNER_COLOR; return ;;
    esac
    if [[ -n ${NO_COLOR:-} ]]; then MODE=none; return; fi
    case ${COLORTERM:-} in truecolor | 24bit) MODE=truecolor; return ;; esac
    case $TERM in *256color*) MODE=256; return ;; esac
    MODE=16
    colors=$(tput colors 2>/dev/null)
    case $colors in '' | *[!0-9]*) return ;; esac
    if (( colors >= 256 )); then MODE=256; fi
}

# Set CUBE to the nearest 6x6x6 color-cube level (0-5) for a 0-255 value.
cube_level() {
    if   (( $1 < 48 ));  then CUBE=0
    elif (( $1 < 115 )); then CUBE=1
    else CUBE=$(( ($1 - 35) / 40 ))
    fi
}

# Fill COLOR[column] with the escape sequence for each terminal column.
build_gradient() {
    local last=$(( ${#STOP_R[@]} - 1 )) span=$(( WIDTH > 1 ? WIDTH - 1 : 1 ))
    local x pos i f r g b n
    COLOR=()
    for (( x = 0; x < WIDTH; x++ )); do
        if [[ $MODE == none ]]; then COLOR[x]=''; continue; fi
        if [[ $MODE == 16 ]]; then
            COLOR[x]=$'\e['"${ANSI16[x * (last + 1) / WIDTH]}m"
            continue
        fi
        pos=$(( x * last ))
        i=$(( pos / span ))
        f=$(( pos % span ))
        if (( i >= last )); then i=$(( last - 1 )); f=$span; fi
        r=$(( STOP_R[i] + (STOP_R[i+1] - STOP_R[i]) * f / span ))
        g=$(( STOP_G[i] + (STOP_G[i+1] - STOP_G[i]) * f / span ))
        b=$(( STOP_B[i] + (STOP_B[i+1] - STOP_B[i]) * f / span ))
        if [[ $MODE == truecolor ]]; then
            COLOR[x]=$'\e[38;2;'"$r;$g;${b}m"
        else
            n=16
            cube_level $r; n=$(( n + 36 * CUBE ))
            cube_level $g; n=$(( n + 6 * CUBE ))
            cube_level $b; n=$(( n + CUBE ))
            COLOR[x]=$'\e[38;5;'"${n}m"
        fi
    done
}

# Set GLYPH to the five rows of a character ('#' = filled, '.' = empty).
get_glyph() {
    case $1 in
        A|a) GLYPH=(.###. '#...#' '#####' '#...#' '#...#') ;;
        B|b) GLYPH=('####.' '#...#' '####.' '#...#' '####.') ;;
        C|c) GLYPH=(.#### '#....' '#....' '#....' .####) ;;
        D|d) GLYPH=('####.' '#...#' '#...#' '#...#' '####.') ;;
        E|e) GLYPH=('#####' '#....' '####.' '#....' '#####') ;;
        F|f) GLYPH=('#####' '#....' '####.' '#....' '#....') ;;
        G|g) GLYPH=(.#### '#....' '#..##' '#...#' .####) ;;
        H|h) GLYPH=('#...#' '#...#' '#####' '#...#' '#...#') ;;
        I|i) GLYPH=('#####' ..#.. ..#.. ..#.. '#####') ;;
        J|j) GLYPH=(..### ...#. ...#. '#..#.' .##..) ;;
        K|k) GLYPH=('#...#' '#..#.' '###..' '#..#.' '#...#') ;;
        L|l) GLYPH=('#....' '#....' '#....' '#....' '#####') ;;
        M|m) GLYPH=('#...#' '##.##' '#.#.#' '#...#' '#...#') ;;
        N|n) GLYPH=('#...#' '##..#' '#.#.#' '#..##' '#...#') ;;
        O|o) GLYPH=(.###. '#...#' '#...#' '#...#' .###.) ;;
        P|p) GLYPH=('####.' '#...#' '####.' '#....' '#....') ;;
        Q|q) GLYPH=(.###. '#...#' '#.#.#' '#..#.' .##.#) ;;
        R|r) GLYPH=('####.' '#...#' '####.' '#..#.' '#...#') ;;
        S|s) GLYPH=(.#### '#....' .###. ....# '####.') ;;
        T|t) GLYPH=('#####' ..#.. ..#.. ..#.. ..#..) ;;
        U|u) GLYPH=('#...#' '#...#' '#...#' '#...#' .###.) ;;
        V|v) GLYPH=('#...#' '#...#' '#...#' .#.#. ..#..) ;;
        W|w) GLYPH=('#...#' '#...#' '#.#.#' '##.##' '#...#') ;;
        X|x) GLYPH=('#...#' .#.#. ..#.. .#.#. '#...#') ;;
        Y|y) GLYPH=('#...#' .#.#. ..#.. ..#.. ..#..) ;;
        Z|z) GLYPH=('#####' ...#. ..#.. .#... '#####') ;;
        0)   GLYPH=(.###. '#..##' '#.#.#' '##..#' .###.) ;;
        1)   GLYPH=(..#.. .##.. ..#.. ..#.. .###.) ;;
        2)   GLYPH=('####.' ....# .###. '#....' '#####') ;;
        3)   GLYPH=('####.' ....# .###. ....# '####.') ;;
        4)   GLYPH=('#..#.' '#..#.' '#####' ...#. ...#.) ;;
        5)   GLYPH=('#####' '#....' '####.' ....# '####.') ;;
        6)   GLYPH=(.###. '#....' '####.' '#...#' .###.) ;;
        7)   GLYPH=('#####' ....# ...#. ..#.. ..#..) ;;
        8)   GLYPH=(.###. '#...#' .###. '#...#' .###.) ;;
        9)   GLYPH=(.###. '#...#' .#### ....# .###.) ;;
        -)   GLYPH=(..... ..... .###. ..... .....) ;;
        _)   GLYPH=(..... ..... ..... ..... '#####') ;;
        *)   GLYPH=(.###. '#...#' ..##. ..... ..#..) ;;   # '?'
    esac
}

# Append one line to OUT, colored by column. $1 is the text, $2 the starting
# column, $3 is "bitmap" ('#' becomes a block) or "text" (printed literally).
append_row() {
    local text=$1 start=$2 kind=$3 i x ch current=''
    local pad
    printf -v pad '%*s' "$start" ''
    OUT+=$pad
    for (( i = 0; i < ${#text}; i++ )); do
        ch=${text:i:1}
        if [[ $kind == bitmap ]]; then
            case $ch in
                '#') ch=$BLOCK ;;
                *)   OUT+=' '; continue ;;
            esac
        fi
        # Plain text longer than the terminal wraps; keep the gradient aligned.
        x=$(( (start + i) % WIDTH ))
        if [[ ${COLOR[x]} != "$current" ]]; then
            current=${COLOR[x]}
            OUT+=$current
        fi
        OUT+=$ch
    done
    if [[ -n $current ]]; then OUT+=$RESET; fi
    OUT+=$'\n'
}

main() {
    local name bar rows i r start art_width
    name=$(uname -n) || exit 0
    name=${name%%.*}
    [[ -n $name ]] || exit 0

    get_width
    get_color_mode
    build_gradient

    printf -v bar '%*s' "$WIDTH" ''
    bar=${bar// /#}

    OUT=''
    append_row "$bar" 0 bitmap
    OUT+=$'\n'

    art_width=$(( ${#name} * (GLYPH_W + 1) - 1 ))
    if (( art_width <= WIDTH )); then
        rows=()
        for (( i = 0; i < ${#name}; i++ )); do
            get_glyph "${name:i:1}"
            for (( r = 0; r < GLYPH_H; r++ )); do
                if (( i > 0 )); then rows[r]+=.; fi
                rows[r]+=${GLYPH[r]}
            done
        done
        start=$(( (WIDTH - art_width) / 2 ))
        for (( r = 0; r < GLYPH_H; r++ )); do
            append_row "${rows[r]}" "$start" bitmap
        done
    else
        start=$(( WIDTH > ${#name} ? (WIDTH - ${#name}) / 2 : 0 ))
        append_row "$name" "$start" text
    fi

    OUT+=$'\n'
    append_row "$bar" 0 bitmap
    printf '%s' "$OUT"
}

main
