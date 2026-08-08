#!/usr/bin/env bash

# Shared interface block writers for Reticulum config files.
# this is the single place that knows what each interface 
# block looks like for reticulum config file

write_vps_interface() {
    local name="${1:-VPS_Uplink}"

    if [ "${VPS_ENABLED:-no}" != "yes" ]; then
        return 0
    fi

    cat >> "$RNSD_CONFIG" << EOF

  [[$name]]
    type = TCPClientInterface
    interface_enabled = True
    target_host = $VPS_HOST
    target_port = $VPS_PORT
    network_name = $VPS_NETWORK_NAME
EOF

    if [ -n "${VPS_PASSPHRASE:-}" ]; then
        echo "    passphrase = $VPS_PASSPHRASE" >> "$RNSD_CONFIG"
    fi

    echo "VPS backbone interface added (host: $VPS_HOST)"
}

write_rnode_interface() {
    local name="${1:-RNode Interface}"

    if [ "${RNODE_ENABLED:-no}" != "yes" ]; then
        return 0
    fi

    cat >> "$RNSD_CONFIG" << EOF

  [[$name]]
    type = RNodeInterface
    interface_enabled = True
    port = $RNODE_PORT
    frequency = $RNODE_FREQUENCY
    bandwidth = $RNODE_BANDWIDTH
    txpower = $RNODE_TXPOWER
    spreadingfactor = $RNODE_SPREADINGFACTOR
    codingrate = $RNODE_CODINGRATE
EOF

    if [ -n "${RNODE_NETWORK_NAME:-}" ]; then
        echo "    network_name = $RNODE_NETWORK_NAME" >> "$RNSD_CONFIG"
    fi
    if [ -n "${RNODE_PASSPHRASE:-}" ]; then
        echo "    passphrase = $RNODE_PASSPHRASE" >> "$RNSD_CONFIG"
    fi
    if [ -n "${RNODE_MODE:-}" ]; then
        echo "    mode = $RNODE_MODE" >> "$RNSD_CONFIG"
    fi

    echo "RNode interface added (port: $RNODE_PORT)"
}

write_server_interface() {
    local name="${1:-TCP Server Interface}"

    if [ -z "${SERVER_LISTEN_IP:-}" ] || [ -z "${SERVER_LISTEN_PORT:-}" ]; then
        return 0
    fi

    cat >> "$RNSD_CONFIG" << EOF

  [[$name]]
    type = TCPServerInterface
    interface_enabled = True
    listen_ip = $SERVER_LISTEN_IP
    listen_port = $SERVER_LISTEN_PORT
EOF

    echo "Server interface added (listening on $SERVER_LISTEN_IP:$SERVER_LISTEN_PORT)"
}