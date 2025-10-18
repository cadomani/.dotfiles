#!/usr/bin/env bash
set -euo pipefail

# ra-multiplex setup script
# This script installs ra-multiplex and sets up a systemd user service
# for persistent rust-analyzer sessions across Neovim restarts.

echo "==> Installing ra-multiplex..."
if ! command -v cargo &> /dev/null; then
    echo "Error: cargo not found. Please install Rust first."
    exit 1
fi

cargo install ra-multiplex

echo "==> Creating config directory..."
mkdir -p ~/.config/ra-multiplex

echo "==> Creating minimal config file..."
cat > ~/.config/ra-multiplex/config.toml << 'EOF'
# ra-multiplex configuration
# Empty config to use all defaults (including TCP on 127.0.0.1:27631)
EOF

echo "==> Creating systemd user service..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/ra-multiplex.service << 'EOF'
[Unit]
Description=ra-multiplex server for rust-analyzer
Documentation=https://github.com/pr2502/ra-multiplex

[Service]
Type=simple
Environment="PATH=%h/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"
ExecStart=%h/.cargo/bin/ra-multiplex server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "==> Enabling and starting ra-multiplex service..."
systemctl --user daemon-reload
systemctl --user enable ra-multiplex.service
systemctl --user start ra-multiplex.service

echo "==> Checking service status..."
systemctl --user status ra-multiplex.service --no-pager -l

echo ""
echo "✓ ra-multiplex installed and running!"
echo ""
echo "The service will:"
echo "  - Keep rust-analyzer running persistently"
echo "  - Auto-start on login"
echo "  - Make Neovim reopen much faster for Rust projects"
echo ""
echo "Commands:"
echo "  ra-multiplex status  - Check server status"
echo "  systemctl --user status ra-multiplex.service  - Check systemd service"
echo "  journalctl --user -u ra-multiplex.service -f  - View logs"
