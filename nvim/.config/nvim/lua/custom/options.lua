-- Custom options overrides
-- These are applied AFTER kickstart's options.lua

-- Set shell to Homebrew zsh
vim.o.shell = '/opt/homebrew/bin/zsh'

-- Enable Nerd Font icons (using CaskaydiaMono Nerd Font)
vim.g.have_nerd_font = true

-- Suppress lspconfig deprecation warning until upstream updates to vim.lsp.config
vim.g.lspconfig_suppress_deprecation_warnings = true
