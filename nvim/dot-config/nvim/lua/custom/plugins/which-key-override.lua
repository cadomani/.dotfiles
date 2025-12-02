-- Override which-key to add delay before showing
-- Default kickstart has delay = 0 which shows immediately
return {
  {
    'folke/which-key.nvim',
    opts = {
      delay = 250, -- milliseconds before which-key shows
    },
  },
}
