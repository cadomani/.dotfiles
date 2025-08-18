# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for an Arch Linux system using Hyprland (Wayland compositor) with extensive development tooling. All configurations follow the XDG Base Directory specification and are stored under `.config/`.

## Key Architecture & Structure

### Theme System Integration
The dotfiles heavily integrate with "Omarchy" - a desktop theme/configuration framework. When modifying configurations, check for Omarchy-specific paths and variables in:
- `.config/hypr/environments.conf` - Environment variables and theme paths
- `.config/alacritty/alacritty.toml` - Theme imports
- `.config/waybar/` - Style and module configurations

### Modular Hyprland Configuration
Hyprland configuration is split across multiple files in `.config/hypr/`:
- `hyprland.conf` - Main entry point that sources other configs
- `bindings.conf` - Keybindings and shortcuts
- `environments.conf` - Environment variables (including NVIDIA settings)
- `autostart.conf` - Applications to launch on startup
- `monitors.conf` - Display configuration
- `input.conf` - Input device settings
- `windowrules.conf` - Per-application window rules

### Shell Configuration Hierarchy
Multiple shells are configured with shared components:
- **Zsh** (`.config/zsh/.zshrc`) - Primary shell with Oh My Zsh
- **Nushell** (`.config/nushell/`) - Alternative modern shell
- **Shared components**: Both use Starship prompt (`.config/starship/starship.toml`)

## Common Development Tasks

### Managing Dotfiles
```bash
# Stage and commit configuration changes
git add .config/<tool>/
git commit -m "Update <tool> configuration"

# Check for untracked configuration files
git status
```

### Testing Configuration Changes
```bash
# Reload Hyprland configuration without restart
hyprctl reload

# Test Neovim configuration
nvim --headless -c "checkhealth" -c "qa"

# Reload Zsh configuration
source ~/.config/zsh/.zshrc

# Test Alacritty configuration
alacritty --print-events
```

## Important Considerations

### Symlink vs Direct Edit
This repository appears to be the actual dotfiles location (not symlinked). When making changes:
1. Edit files directly in this repository
2. Changes take effect immediately for most applications
3. Some applications may require restart (Hyprland can be reloaded with `hyprctl reload`)

### NVIDIA-Specific Settings
The system uses NVIDIA GPU with specific environment variables in `.config/hypr/environments.conf`. These settings are critical for Wayland compatibility.

### Plugin Dependencies
Several configurations depend on external plugins:
- **Zsh**: oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting
- **Neovim**: Extensive plugin ecosystem managed by lazy.nvim
- **Shell tools**: eza, zoxide, fzf, starship

When modifying these configs, ensure the required plugins/tools are available.

### Configuration Interdependencies
- **Terminal colors**: Alacritty imports Omarchy theme which affects Neovim and shell appearance
- **Font**: CaskaydiaMono Nerd Font is used across terminal applications
- **Keybindings**: Hyprland bindings launch specific applications with hardcoded paths