---@type LazySpec
return {
  'b0o/schemastore.nvim',
  lazy = true,
  version = false, -- last release is way too old
  config = function()
    -- Enable JSON schema validation for various files
    require('lspconfig').jsonls.setup {
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = { enable = true },
        },
      },
    }
  end,
}