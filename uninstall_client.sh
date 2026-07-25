#!/usr/bin/env bash
set -euo pipefail

RNSD_CONFIG_DIR="$HOME/.reticulum"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
LOCAL_BIN="$HOME/.local/bin"

confirm_uninstall() {
    echo "This will stop and remove Kairos/Reticulum from this machine."
    read -rp "Continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
}

stop_service() {
    if systemctl --user is-active --quiet rnsd.service 2>/dev/null; then
        echo "Stopping rnsd.service..."
        systemctl --user stop rnsd.service
    else
        echo "rnsd.service is not running, skipping stop."
    fi

    if systemctl --user is-enabled --quiet rnsd.service 2>/dev/null; then
        echo "Disabling rnsd.service..."
        systemctl --user disable rnsd.service
    else
        echo "rnsd.service is not enabled, skipping disable."
    fi

    if [ -f "$SYSTEMD_USER_DIR/rnsd.service" ]; then
        rm "$SYSTEMD_USER_DIR/rnsd.service"
        echo "Removed systemd unit file."
    fi

    systemctl --user daemon-reload

    loginctl disable-linger "$USER" 2>/dev/null || true
}

remove_packages() {
    if command -v pip3 > /dev/null 2>&1; then
        echo "Removing rns and nomadnet..."
        pip3 uninstall -y rns nomadnet --break-system-packages 2>/dev/null || true
    fi
}

remove_path_entry() {
    if [ -f "$HOME/.bashrc" ] && grep -q "$LOCAL_BIN" "$HOME/.bashrc"; then
        sed -i "\|export PATH=\"$LOCAL_BIN:\$PATH\"|d" "$HOME/.bashrc"
        echo "Removed PATH entry from ~/.bashrc"
    fi
}

remove_identity() {
    if [ ! -d "$RNSD_CONFIG_DIR" ]; then
        echo "No Reticulum config/identity directory found, nothing to remove."
        return 0
    fi

    echo ""
    echo "WARNING: $RNSD_CONFIG_DIR contains your Reticulum identity keys."
    echo "Deleting this is PERMANENT - you cannot recover this identity afterward."
    echo "Any destinations/addresses tied to it will be unreachable under this identity again."
    echo ""
    read -rp "Delete identity and config permanently? (type YES to confirm): " identity_confirm

    if [ "$identity_confirm" = "YES" ]; then
        rm -rf "$RNSD_CONFIG_DIR"
        echo "Removed $RNSD_CONFIG_DIR"
    else
        echo "Keeping $RNSD_CONFIG_DIR - only the service and packages were removed."
    fi
}

main() {
    confirm_uninstall
    stop_service
    remove_packages
    remove_path_entry
    remove_identity

    echo ""
    echo "Uninstall complete."
}

main "$@"
