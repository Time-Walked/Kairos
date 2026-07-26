#!/usr/bin/env bash
set -euo pipefail

RNSD_CONFIG="$HOME/.reticulum/config"

check_config_exists() {
    if [ ! -f "$RNSD_CONFIG" ]; then
        echo "Error: no config found at $RNSD_CONFIG"
        echo "Run an installer first!"
        exit 1
    fi
}

check_safe_to_append() {
    IFACE_LINE=$(grep -n '^\[interfaces\]' "$RNSD_CONFIG" | head -1 | cut -d: -f1 || true)

    if [ -z "$IFACE_LINE" ]; then
        echo "Error: no [interfaces] section found in $RNSD_CONFIG"
        exit 1
    fi

    AFTER=$(tail -n +$((IFACE_LINE + 1)) "$RNSD_CONFIG")
    if echo "$AFTER" | grep -qE '^\[[^][]'; then
        echo "Error: [interfaces] doesn't appear to be the last section in this config."
        echo "Please add it manually, or use a fresh config via install_client.sh."
        exit 1
    fi
}

backup_config() {
    BACKUP_PATH="${RNSD_CONFIG}.backup.$(date +%s)"
    cp "$RNSD_CONFIG" "$BACKUP_PATH"
    echo "Existing config backed up to: $BACKUP_PATH"
}

choose_interface_type() {
    echo ""
    echo "What kind of interface do you want to add?"
    echo "  1  VPS backbone (TCPClientInterface)"
    echo "  2  RNode radio (RNodeInterface)"
    echo "  3  TCP Server (TCPServerInterface)"
    read -rp "Selection [1/2/3]: " IFACE_TYPE
}

prompt_interface_name() {
    read -rp "Name for this interface (used as [[Name]] in the config): " IFACE_NAME
    if [ -z "$IFACE_NAME" ]; then
        echo "Error: interface name cannot be empty"
        exit 1
    fi
    if grep -q "\[\[$IFACE_NAME\]\]" "$RNSD_CONFIG"; then
        echo "Error: an interface named '$IFACE_NAME' already exists in this config."
        exit 1
    fi
}

add_vps_interface() {
    read -rp "VPS host: " VPS_HOST
    read -rp "VPS port: " VPS_PORT
    read -rp "Network name: " VPS_NETWORK_NAME
    read -rp "Passphrase (leave blank if none): " VPS_PASSPHRASE

    cat >> "$RNSD_CONFIG" << EOF

  [[$IFACE_NAME]]
    type = TCPClientInterface
    enabled = Yes
    target_host = $VPS_HOST
    target_port = $VPS_PORT
    network_name = $VPS_NETWORK_NAME
EOF

    if [ -n "$VPS_PASSPHRASE" ]; then
        cat >> "$RNSD_CONFIG" << EOF
    passphrase = "$VPS_PASSPHRASE"
EOF
    fi
}

add_rnode_interface() {
    echo "Find your port with: ls /dev/ttyUSB* /dev/ttyACM*"
    read -rp "RNode port: " RNODE_PORT
    read -rp "Frequency [915000000]: " RNODE_FREQUENCY
    RNODE_FREQUENCY="${RNODE_FREQUENCY:-915000000}"
    read -rp "Bandwidth [125000]: " RNODE_BANDWIDTH
    RNODE_BANDWIDTH="${RNODE_BANDWIDTH:-125000}"
    read -rp "TX power [17]: " RNODE_TXPOWER
    RNODE_TXPOWER="${RNODE_TXPOWER:-17}"
    read -rp "Spreading factor [8]: " RNODE_SPREADINGFACTOR
    RNODE_SPREADINGFACTOR="${RNODE_SPREADINGFACTOR:-8}"
    read -rp "Coding rate [5]: " RNODE_CODINGRATE
    RNODE_CODINGRATE="${RNODE_CODINGRATE:-5}"
    read -rp "Network name (IFAC, leave blank if none): " RNODE_NETWORK_NAME
    read -rp "Passphrase (IFAC, leave blank if none): " RNODE_PASSPHRASE
    read -rp "Mode [full/boundary/gateway/access_point, leave blank for full]: " RNODE_MODE

    cat >> "$RNSD_CONFIG" << EOF

  [[$IFACE_NAME]]
    type = RNodeInterface
    enabled = Yes
    port = $RNODE_PORT
    frequency = $RNODE_FREQUENCY
    bandwidth = $RNODE_BANDWIDTH
    txpower = $RNODE_TXPOWER
    spreadingfactor = $RNODE_SPREADINGFACTOR
    codingrate = $RNODE_CODINGRATE
EOF

    if [ -n "$RNODE_NETWORK_NAME" ]; then
        echo "    network_name = $RNODE_NETWORK_NAME" >> "$RNSD_CONFIG"
    fi
    if [ -n "$RNODE_PASSPHRASE" ]; then
        echo "    passphrase = \"$RNODE_PASSPHRASE\"" >> "$RNSD_CONFIG"
    fi
    if [ -n "$RNODE_MODE" ]; then
        echo "    mode = $RNODE_MODE" >> "$RNSD_CONFIG"
    fi
}

add_server_interface() {
    read -rp "Listen IP [0.0.0.0]: " SERVER_LISTEN_IP
    SERVER_LISTEN_IP="${SERVER_LISTEN_IP:-0.0.0.0}"
    read -rp "Listen port: " SERVER_LISTEN_PORT
    if [ -z "$SERVER_LISTEN_PORT" ]; then
        echo "Error: listen port cannot be empty"
        exit 1
    fi

    cat >> "$RNSD_CONFIG" << EOF

  [[$IFACE_NAME]]
    type = TCPServerInterface
    enabled = Yes
    listen_ip = $SERVER_LISTEN_IP
    listen_port = $SERVER_LISTEN_PORT
EOF
}

restart_notice() {
    echo ""
    echo "Interface '$IFACE_NAME' added to $RNSD_CONFIG"
    echo ""
    if systemctl --user is-active --quiet rnsd.service 2>/dev/null; then
        echo "rnsd is currently running and won't pick this up automatically."
        read -rp "Restart rnsd now to apply it? (y/n): " restart_confirm
        if [[ "$restart_confirm" =~ ^[Yy]$ ]]; then
            systemctl --user restart rnsd.service
            echo "Restarted."
        else
            echo "Not restarted - run 'systemctl --user restart rnsd.service' when ready."
        fi
    fi
}

main() {
    check_config_exists
    check_safe_to_append
    backup_config
    choose_interface_type
    prompt_interface_name

    case "$IFACE_TYPE" in
        1) add_vps_interface ;;
        2) add_rnode_interface ;;
        3) add_server_interface ;;
        *) echo "Invalid selection."; exit 1 ;;
    esac

    chmod 600 "$RNSD_CONFIG"
    restart_notice
}

main "$@"
