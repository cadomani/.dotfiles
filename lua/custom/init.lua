-- Custom module entry point
-- This file loads all custom overrides AFTER kickstart defaults
-- Loaded via `require 'custom'` in init.lua

-- Load custom options (shell, etc.)
require 'custom.options'

-- Load custom keymaps
require 'custom.keymaps'

-- Load custom autocmds
require 'custom.autocmds'

-- Note: custom/plugins/ is loaded via lazy-plugins.lua's { import = 'custom.plugins' }
