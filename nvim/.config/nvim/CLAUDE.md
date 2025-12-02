# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a modular Neovim configuration based on kickstart.nvim. It's a personal development environment designed for software engineering with language servers, debuggers, formatters, and productivity plugins.

## Configuration Architecture

### Core Structure
- `init.lua` - Main entry point that loads all modules
- `lua/options.lua` - Neovim options and settings
- `lua/keymaps.lua` - Core key mappings and autocommands
- `lua/autocmds.lua` - Additional autocommands
- `lua/lazy-bootstrap.lua` - Lazy.nvim plugin manager setup
- `lua/lazy-plugins.lua` - Plugin configuration loader

### Plugin Organization
- `lua/kickstart/plugins/` - Core plugins from kickstart.nvim (LSP, telescope, treesitter, etc.)
- `lua/custom/plugins/` - Personal plugin customizations and additions
- `lazy-lock.json` - Plugin version lockfile (tracked in git)

### Key Plugins
- **Lazy.nvim** - Plugin manager
- **LSP** - Language server support with mason.nvim for auto-installation
- **Telescope** - Fuzzy finder for files, buffers, grep, etc.
- **Treesitter** - Syntax highlighting and parsing
- **Which-key** - Key binding hints
- **Claude Code** - Integration with Claude Code (`<C-,>` to toggle)

## Development Commands

### Plugin Management
```bash
# Update all plugins
:Lazy update

# View plugin status
:Lazy

# Health check for Neovim setup
:checkhealth
```

### Key Mappings
- Leader key: `<Space>`
- Local leader: `|`
- Claude Code toggle: `<C-,>`
- Claude Code variants: `<leader>cC` (continue), `<leader>cV` (verbose), `<leader>cR` (resume)

### Essential Keybinds
- `<leader>sh` - Search help documentation
- `<leader>sf` - Find files (Telescope)
- `<leader>sg` - Live grep
- `<leader>q` - Open diagnostic quickfix list
- `<C-h/j/k/l>` - Navigate between splits
- `<leader>-` - Split window below
- `<leader>|` - Split window right

### Language-Specific Features
#### C/C++ (via Clangd)
- `<leader>gh` - Switch between header/source files
- `<leader>gt` - Show type hierarchy
- `<leader>gs` - Show symbol info

## File Structure Conventions

- Add new plugins to `lua/custom/plugins/` directory
- Each plugin should be in its own file with descriptive name
- Follow the modular pattern: each plugin file returns a plugin spec table
- Custom keymaps can be added to existing files or new plugin configurations

## Configuration Patterns

### Adding New Plugins
1. Create new file in `lua/custom/plugins/plugin-name.lua`
2. Return a plugin specification table with setup configuration
3. Plugin will be automatically loaded via the `{ import = 'custom.plugins' }` line in `lazy-plugins.lua`

### Custom Autocommands
- Use the `augroup` helper function from `autocmds.lua` for proper cleanup
- File-type specific keymaps should be added via FileType autocommands

### Settings Override
- Global settings go in `options.lua`
- Key mappings go in `keymaps.lua`
- Plugin-specific settings go in their respective plugin configuration files

## Dependencies

This configuration requires:
- Neovim 0.9+ (stable or nightly)
- `git`, `make`, `unzip`, C compiler (gcc)
- `ripgrep` for telescope live grep
- Clipboard tool (xclip/xsel on Linux, pbcopy on macOS)
- Nerd Font (optional, controlled by `vim.g.have_nerd_font` in init.lua)

Language-specific dependencies are managed through Mason for LSP servers, formatters, and linters.