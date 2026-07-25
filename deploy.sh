#!/bin/bash
set -euo pipefail

ensure_python() {
    if ! command -v python3 > /dev/null 2>&1; then
        echo "python3 not found, installing.."
        sudo apt update
        sudo apt install -y python3 python3-pip
    fi
}

ensure_rich() {
    if ! python3 -c "import rich" > /dev/null 2>&1; then
        echo "python 'rich' library not found, installing.."
        pip3 install rich --break-system-packages --user
    fi
}

main() {
    ensure_python
    ensure_rich
    exec python3 "$(dirname "$0")/launcher.py"
}

main "$@"