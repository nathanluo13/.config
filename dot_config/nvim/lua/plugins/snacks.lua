return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Disable smooth-scroll animation so wheel/Ctrl-d input applies 1:1
      -- instantly (no interpolation lag) — matches omarchy's snappy scroll.
      scroll = { enabled = false },
      picker = {
        sources = {
          explorer = {
            -- Always show hidden (H) and ignored (I) files by default.
            hidden = true,
            ignored = true,
          },
        },
      },
      lazygit = {
        win = {
          width = 0,
          height = 0,
          row = 0,
          col = 0,
          border = "none",
          backdrop = false,
        },
      },
      styles = {
        lazygit = {
          width = 0,
          height = 0,
          row = 0,
          col = 0,
          border = "none",
          backdrop = false,
        },
      },
    },
  },
}