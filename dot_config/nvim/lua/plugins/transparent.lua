-- Make Neovim's background transparent so the terminal shows through.
return {
  -- Enable transparency on tokyonight (LazyVim default colorscheme).
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  -- Enable transparency on catppuccin (also installed).
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
    },
  },

  -- Fallback: clear common backgrounds for whatever colorscheme is active.
  -- This runs after the colorscheme loads, so it covers cases the
  -- per-theme options above miss.
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("user_transparency", { clear = true }),
        callback = function()
          local groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "FloatBorder",
            "SignColumn",
            "LineNr",
            "EndOfBuffer",
            "MsgArea",
            "TelescopeNormal",
            "TelescopeBorder",
            "NeoTreeNormal",
            "NeoTreeNormalNC",
          }
          -- Use :highlight ... guibg=NONE for a PARTIAL update (bg only).
          -- nvim_set_hl(0, group, { bg = "none" }) REPLACES the whole group,
          -- wiping fg -> snacks.nvim's blend() then crashes on a nil fg during
          -- :checkhealth. See basecamp/omarchy#3878.
          for _, group in ipairs(groups) do
            vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
          end
        end,
      })
    end,
  },
}
