# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for an Arch Linux system using Hyprland (Wayland compositor) with extensive development tooling. The repository is organized using GNU Stow for symlink management, with each application having its own package directory. All configurations follow the XDG Base Directory specification and are stored under `.config/`.

## Key Architecture & Structure

### Stow Package Structure
The repository uses GNU Stow for dotfiles management with the following package structure:
- `alacritty/` - Terminal emulator configuration
- `claude/` - Claude Code configuration
- `hypr/` - Hyprland window manager and related configs
- `nvim/` - Neovim editor configuration
- `starship/` - Cross-shell prompt configuration
- `swayosd/` - On-screen display daemon for Wayland
- `waybar/` - Status bar configuration
- `zellij/` - Terminal multiplexer configuration
- `zsh/` - Zsh shell configuration

Each package contains a `.config/` directory that mirrors the target structure in `$HOME/.config/`.

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

### Managing Dotfiles with Stow
```bash
# Install/update a specific package (creates symlinks)
stow <package-name>

# Remove a package (removes symlinks)
stow -D <package-name>

# Reinstall a package (useful after config changes)
stow -R <package-name>

# Install all packages
stow */

# Stage and commit configuration changes
git add <package-name>/
git commit -m "Update <package-name> configuration"

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

### Stow Symlink Management
This repository uses GNU Stow to create symlinks from package directories to `$HOME/.config/`. When making changes:
1. Edit files directly in the package directories (e.g., `hypr/.config/hypr/hyprland.conf`)
2. Changes take effect immediately since files are symlinked to their target locations
3. Use `stow -R <package>` if you need to refresh symlinks after structural changes
4. Some applications may require restart (Hyprland can be reloaded with `hyprctl reload`)
5. The `.stow-local-ignore` file prevents documentation and git files from being symlinked

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