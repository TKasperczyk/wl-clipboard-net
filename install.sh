#!/bin/bash
# Install wl-clipboard-net

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
SERVICE_DIR="${HOME}/.config/systemd/user"
CONFIG_DIR="${HOME}/.config/wl-clipboard-net"

echo "Installing wl-clipboard-net..."

# Create directories
mkdir -p "$BIN_DIR" "$SERVICE_DIR" "$CONFIG_DIR"

# Install binary
install -m 755 "${SCRIPT_DIR}/wl-clipboard-net" "$BIN_DIR/"
echo "  Installed: $BIN_DIR/wl-clipboard-net"

# Install service
install -m 644 "${SCRIPT_DIR}/wl-clipboard-net.service" "$SERVICE_DIR/"
echo "  Installed: $SERVICE_DIR/wl-clipboard-net.service"

# Create example config if none exists
if [[ ! -f "${CONFIG_DIR}/config" ]]; then
    cat > "${CONFIG_DIR}/config" <<EOF
# wl-clipboard-net configuration
# Uncomment and set your remote host

#REMOTE_HOST=192.168.122.10
#SEND_PORT=9999
#RECV_PORT=9998
#POLL_INTERVAL=0.5
EOF
    echo "  Created: ${CONFIG_DIR}/config (edit this!)"
fi

# Reload systemd
systemctl --user daemon-reload

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.config/wl-clipboard-net/config"
echo "  2. Enable: systemctl --user enable wl-clipboard-net"
echo "  3. Start:  systemctl --user start wl-clipboard-net"
echo ""
echo "Or run directly: wl-clipboard-net -r <remote-host>"
