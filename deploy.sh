#!/bin/bash
set -euo pipefail

THEME_FILE="$(dirname "$0")/assets/kairos_theme.conf"
LOGO_PATH="$(dirname "$0")/assets/reticulum_logo.png"
DIALOGRC_FILE="/tmp/kairos_dialogrc"

load_theme() {
    if [ -f "$THEME_FILE" ]; then
        source "$THEME_FILE"
    else
        THEME_BORDER=cyan
        THEME_TITLE=cyan
        THEME_BUTTON_BG=cyan
        THEME_ACTBUTTON_BG=blue
    fi

    # dialog wants UPPERCASE color names, our theme file uses lowercase
    B="${THEME_BORDER^^}"
    T="${THEME_TITLE^^}"
    BTN="${THEME_BUTTON_BG^^}"
    ACT="${THEME_ACTBUTTON_BG^^}"

    cat > "$DIALOGRC_FILE" << EOF
screen_color = (WHITE,BLACK,ON)
dialog_color = (WHITE,BLACK,OFF)
title_color = (${T},BLACK,ON)
border_color = (${B},BLACK,ON)
button_active_color = (WHITE,${ACT},ON)
button_inactive_color = (BLACK,${BTN},OFF)
menubox_color = (WHITE,BLACK,OFF)
menubox_border_color = (${B},BLACK,ON)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (BLACK,${BTN},ON)
tag_color = (${T},BLACK,ON)
tag_selected_color = (BLACK,${ACT},ON)
EOF

    export DIALOGRC="$DIALOGRC_FILE"
}

check_dialog() {
    if ! command -v dialog > /dev/null 2>&1; then
        echo "dialog not found, installing.."
        sudo apt install -y dialog
    fi
}

check_chafa() {
    if ! command -v chafa > /dev/null 2>&1; then
        echo "chafa not found, installing.."
        sudo apt install -y chafa
    fi
}

show_banner() {
    clear
    if [ -f "$LOGO_PATH" ]; then
        chafa --size=40x20 "$LOGO_PATH"
    else
        echo "(logo not found at $LOGO_PATH - skipping)"
    fi
    echo ""
    echo "        Kairos - Reticulum Deployment Toolkit"
    echo ""
    sleep 1.5
}

show_menu() {
    CHOICE=$(dialog --title "Kairos Deployment Menu" \
        --menu "Choose an install path based on your needs:" 15 60 4 \
        "1" "Client install" \
        "2" "Server install" \
        "3" "Exit" \
        3>&1 1>&2 2>&3)
}

run_themed_install() {
    local script_to_run="$1"
    local title="$2"

    ( "$script_to_run" 2>&1 ) | dialog --title "$title" \
        --progressbox "Running $script_to_run ..." 24 90

    clear
    echo "$title finished. Press Enter to continue."
    read -r
}

main() {
    load_theme
    check_dialog
    check_chafa
    show_banner
    show_menu

    case "$CHOICE" in
        1)
            run_themed_install "./install_client.sh" "Client Install"
            ;;
        2)
            run_themed_install "./install_server.sh" "Server Install"
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "No selection, exiting"
            exit 1
            ;;
    esac
}

main "$@"