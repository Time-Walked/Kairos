#!/bin/bash
set -euo pipefail

#build colors for whiptail menu 
export NEWT_COLORS='
root=white,black
window=white,black
border=cyan,black
title=cyan,black
textbox=white,black
button=black,cyan
actbutton=white,cyan
listbox=white,black
actlistbox=black,cyan
sellistbox=black,cyan
actsellistbox=black,white
label=white,black
'

check_whiptail() {
    if ! command -v whiptail > /dev/null 2>&1; then
        echo "whiptail not found, installing.."
        sudo apt install -y whiptail
    fi
}

show_menu() {
    CHOICE=$(whiptail --title "Kairos Deployment Menu" \
        --menu "Choose an install path based on your needs:" 15 60 4 \
        "1" "Client install" \
        "2" "Server install" \
        "3" "Exit" \
        3>&1 1>&2 2>&3)
}

main() {
    check_whiptail
    show_menu

    case "$CHOICE" in
        1)
            ./install_client.sh
            ;;
        2)
            ./install_server.sh
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