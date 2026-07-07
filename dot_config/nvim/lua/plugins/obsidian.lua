-- Obsidian "mode" for LazyVim.
--
-- Behaviour: the plugin stays dormant until you open a markdown file that lives
-- inside an Obsidian vault (any folder, at any depth, that contains a `.obsidian`
-- directory). The workspace `path` below walks UP from the current file looking
-- for `.obsidian`; if it finds one it returns the vault root and Obsidian mode
-- turns on, otherwise it returns nil and the plugin does nothing. So markdown
-- files outside a vault behave exactly like vanilla LazyVim.
--
-- All shortcuts live under <leader>o (see which-key group "+obsidian"). Inside a
-- note, <cr>/gf follow the link under the cursor (plugin defaults).

local function vault_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.uv.cwd()
  local marker = vim.fs.find(".obsidian", { path = start, upward = true, type = "directory" })[1]
  if marker then
    return vim.fs.dirname(marker) -- vault root = parent of the .obsidian folder
  end
  return nil -- not in a vault -> no workspace -> Obsidian mode stays off
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- pin to tagged releases
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Lazy-load on markdown OR on any <leader>o shortcut.
    ft = "markdown",
    keys = {
      { "<leader>o", "", desc = "+obsidian" },
      { "<leader>oo", "<cmd>Obsidian<cr>", desc = "Command menu" },
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search (grep) notes" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Links in note" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Search tags" },
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
      { "<leader>oD", "<cmd>Obsidian dailies<cr>", desc = "Browse daily notes" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note (+ links)" },
      { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
      { "<leader>ox", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
      { "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Switch workspace" },
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "vault",
          path = vault_root,
          strict = true, -- use the root we resolved; don't re-detect
        },
      },

      -- Use snacks (already installed) for all pickers.
      picker = { name = "snacks.pick" },

      -- Completion is delivered via the bundled obsidian-ls LSP, surfaced through
      -- blink.cmp's existing `lsp` source (LazyVim default) — auto-wired, so the
      -- only knob left here is the trigger length.
      completion = { min_chars = 2 },

      -- Keep links and file naming consistent with how Flint vaults are written.
      link = { style = "wiki", format = "shortest" }, -- [[Note Title]] style
      new_notes_location = "current_dir", -- create new notes next to the current file
      note_id_func = function(title)
        return title or tostring(os.time()) -- filename = the title you type
      end,

      -- Flint manages its own frontmatter (id, tags, orbh-sessions, authors).
      -- Don't let Obsidian write or rewrite it on save.
      frontmatter = { enabled = false },

      -- In-buffer rendering is handled by render-markdown.nvim (see
      -- render-markdown.lua). Disable obsidian's own UI so they don't both
      -- conceal/decorate the same buffer.
      ui = { enable = false },
    },
  },

  -- Register the which-key group label.
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "obsidian", icon = "" },
      },
    },
  },
}
