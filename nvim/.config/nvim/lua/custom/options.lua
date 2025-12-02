-- Custom options overrides
-- These are applied AFTER kickstart's options.lua

-- Set shell to Homebrew zsh
vim.o.shell = '/opt/homebrew/bin/zsh'

-- Suppress lspconfig deprecation warning until upstream updates to vim.lsp.config
vim.g.lspconfig_suppress_deprecation_warnings = true
