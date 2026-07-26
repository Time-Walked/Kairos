#!/usr/bin/env bash
set -euo pipefail

RNSD_CONFIG="$HOME/.reticulum/config"
LOCAL_BIN="$HOME/.local/bin"
CONFIG_FILE="$(dirname "$0")/kairos.conf"

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "Loading config from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        echo "No config file found at $CONFIG_FILE"
        exit 1
    fi
}

validate_config() {
    if [ "$RNODE_ENABLED" != "yes" ] || [ -z "$RNODE_PORT" ]; then
        echo "Error: a relay requires RNODE_ENABLED=yes and RNODE_PORT set in kairos.conf"
        exit 1
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

  [[RNode Interface]]
    type = RNodeInterface
    interface_enabled = True
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
        echo "    passphrase = $RNODE_PASSPHRASE" >> "$RNSD_CONFIG"
    fi
    if [ -n "$RNODE_MODE" ]; then
        echo "    mode = $RNODE_MODE" >> "$RNSD_CONFIG"
    fi

    chmod 600 "$RNSD_CONFIG"
    echo "Wrote new config to $RNSD_CONFIG (permissions locked to owner only)"
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

    sudo loginctl enable-linger "$USER" || echo "Could not enable lingering, service will only run while logged in"

    echo "Waiting for rnsd to come up..."
    sleep 3

    systemctl --user status rnsd.service --no-pager || true
}

main() {
    load_config
    validate_config
    check_requirements
    install_dependencies
    setup_reticulum
    start_services
}

main "$@"
