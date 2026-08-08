#!/usr/bin/env bash
set -eo pipefail

RNSD_CONFIG="$HOME/.reticulum/config"
LOCAL_BIN="$HOME/.local/bin"
CONFIG_FILE="$(dirname "$0")/kairos.conf"

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "Loading config from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        echo "No config file found at $CONFIG_FILE, using defaults."
        SERVER_LISTEN_IP=""
        SERVER_LISTEN_PORT=""
    fi
}


check_requirements() {
    case ":$PATH:" in
        *":$LOCAL_BIN:"*) ;;
        *) export PATH="$LOCAL_BIN:$PATH" ;;
    esac

    if ! grep -q "$LOCAL_BIN" "$HOME/.bashrc" 2>/dev/null; then
        echo "export PATH=\"$LOCAL_BIN:\$PATH\"" >> "$HOME/.bashrc"
        echo "Added $LOCAL_BIN to PATH in ~/.bashrc for future sessions."
    fi
}

install_dependencies() {
    if command -v python3 > /dev/null 2>&1 && command -v pip3 > /dev/null 2>&1; then
        echo "python3 and pip3 already installed, skipping."
        return 0
    fi

    if command -v apt > /dev/null 2>&1; then
        echo "Detected Debian/Ubuntu (apt). Installing python3 + pip3..."
        sudo apt update
        sudo apt install -y python3 python3-pip
    else
        echo "This installer currently only supports Debian/Ubuntu."
        echo "Please install python3 and pip3 manually, then re-run this script."
        exit 1
    fi
}

setup_reticulum() {
    if command -v rnsd > /dev/null 2>&1; then
        echo "rnsd is already installed, skipping."
    else
        echo "Installing rns..."
        pip3 install rns --break-system-packages --user
    fi

    if command -v nomadnet > /dev/null 2>&1; then
        echo "nomadnet is already installed, skipping."
    else
        echo "Installing nomadnet..."
        pip3 install nomadnet --break-system-packages --user
    fi

    RNSD_PATH="$(which rnsd)"
    echo "rnsd path: $RNSD_PATH"

    mkdir -p "$HOME/.reticulum"

    if [ -f "$RNSD_CONFIG" ]; then
        BACKUP_PATH="${RNSD_CONFIG}.backup.$(date +%s)"
        cp "$RNSD_CONFIG" "$BACKUP_PATH"
        echo "Existing config backed up to: $BACKUP_PATH"
    fi

    cat > "$RNSD_CONFIG" << EOF
[reticulum]
  enable_transport = True
  share_instance = Yes
  shared_instance_type = tcp
  shared_instance_port = 37428
  instance_control_port = 37429

[logging]
  loglevel = 4

[interfaces]

  [[TCP Server Interface]]
    type = TCPServerInterface
    interface_enabled = True
    listen_ip = $SERVER_LISTEN_IP
    listen_port = $SERVER_LISTEN_PORT
EOF

    chmod 600 "$RNSD_CONFIG"
    echo "Wrote new config to $RNSD_CONFIG (permissions locked to owner only)"
}

confirm_firewall() {
    echo ""
    echo "This will open port $SERVER_LISTEN_PORT/tcp on this machine's firewall"
    echo "so other Reticulum nodes can connect to it."
    read -rp "Proceed? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Skipping firewall changes. You'll need to open this port manually"
        echo "for other nodes to be able to connect."
        return 0
    fi
    configure_firewall
}

configure_firewall() {
    if command -v ufw > /dev/null 2>&1; then
        echo "Opening port $SERVER_LISTEN_PORT/tcp via ufw..."
        sudo ufw allow "${SERVER_LISTEN_PORT}/tcp"
    else
        echo "ufw not found - if you have a different firewall, make sure"
        echo "port $SERVER_LISTEN_PORT/tcp is open for incoming connections."
    fi
}

start_services() {
    RNSD_PATH="$(which rnsd)"
    SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_USER_DIR"

    cat > "$SYSTEMD_USER_DIR/rnsd.service" << EOF
[Unit]
Description=Reticulum Network Stack Daemon
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$RNSD_PATH
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now rnsd.service

    sudo loginctl enable-linger "$USER" || echo "Could not enable lingering - service will only run while logged in."

    echo "Waiting for rnsd to come up..."
    sleep 3

    echo "===================================="
    systemctl --user status rnsd.service --no-pager || true
    echo "===================================="
    echo ""
    echo "Server listening on ${SERVER_LISTEN_IP}:${SERVER_LISTEN_PORT}"
    echo "Clients connect using a TCPClientInterface pointed at this"
    echo "machine's public IP/hostname and port ${SERVER_LISTEN_PORT}."
}

main() {
    load_config
    check_requirements
    install_dependencies
    setup_reticulum
    confirm_firewall
    start_services
}

main "$@"
