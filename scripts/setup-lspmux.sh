#!/usr/bin/env bash
set -euo pipefail

# lspmux setup script
# This script installs lspmux (successor to ra-multiplex) and sets up a
# systemd user service for persistent rust-analyzer sessions across Neovim restarts.
# rustaceanvim v7+ auto-detects lspmux on 127.0.0.1:27631.

echo "==> Installing lspmux..."
if ! command -v cargo &> /dev/null; then
    echo "Error: cargo not found. Please install Rust first."
    exit 1
fi

cargo install lspmux

echo "==> Creating config directory..."
mkdir -p ~/.config/lspmux

echo "==> Creating minimal config file..."
cat > ~/.config/lspmux/config.toml << 'EOF'
# lspmux configuration
# Empty config to use all defaults (including TCP on 127.0.0.1:27631)
EOF

echo "==> Stopping old ra-multiplex service if present..."
systemctl --user stop ra-multiplex.service 2>/dev/null || true
systemctl --user disable ra-multiplex.service 2>/dev/null || true

echo "==> Creating systemd user service..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/lspmux.service << 'EOF'
[Unit]
Description=lspmux server for rust-analyzer
Documentation=https://codeberg.org/p2502/lspmux

[Service]
Type=simple
Environment="PATH=%h/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"
ExecStart=%h/.cargo/bin/lspmux server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "==> Enabling and starting lspmux service..."
systemctl --user daemon-reload
systemctl --user enable lspmux.service
systemctl --user start lspmux.service

echo "==> Checking service status..."
systemctl --user status lspmux.service --no-pager -l

echo ""
echo "Done! lspmux installed and running."
echo ""
echo "The service will:"
echo "  - Keep rust-analyzer running persistently"
echo "  - Auto-start on login"
echo "  - rustaceanvim v7+ auto-connects with no config needed"
echo ""
echo "Commands:"
echo "  systemctl --user status lspmux.service  - Check systemd service"
echo "  journalctl --user -u lspmux.service -f  - View logs"
