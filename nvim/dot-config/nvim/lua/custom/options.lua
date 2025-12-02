-- Custom options overrides
-- These are applied AFTER kickstart's options.lua
--
-- NOTE: Some vim.g settings (have_nerd_font, lspconfig_suppress_deprecation_warnings)
-- must be set in init.lua BEFORE plugins load, so they live there instead.

-- Set shell to zsh (platform-specific path)
if vim.fn.has 'mac' == 1 then
  vim.o.shell = '/opt/homebrew/bin/zsh'
else
  vim.o.shell = '/usr/bin/zsh'
end
