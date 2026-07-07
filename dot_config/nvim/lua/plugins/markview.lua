-- In-buffer markdown rendering via markview.nvim.
--
-- Deliberately minimal — the maintainer's recommended spec. markview
-- self-lazy-loads, so `lazy = false` is correct (lazy-loading it actually slows
-- preview startup). Tree-sitter `markdown`/`markdown_inline` parsers are already
-- installed system-wide and icons come from the nerd font, so no dependencies
-- or extra config are needed. Callouts, block quotes, headings, code blocks,
-- tables, etc. all render from defaults.
--
-- obsidian.nvim's own `ui` renderer stays disabled (see obsidian.lua) so the two
-- don't both decorate the buffer — markview owns rendering.
--
-- IMPORTANT: markview recommends `nowrap` for correct rendering (its wrap
-- support is glitchy and is what made callouts look broken). LazyVim FORCE-
-- ENABLES `wrap` for markdown via its own FileType autocmd, so we override it
-- back to nowrap. The override is scheduled so it runs AFTER LazyVim's autocmd
-- and wins.
--
-- Default cursor behaviour is "reading mode": the line under the cursor is NOT
-- revealed as raw in normal mode (hybrid mode off by default). Toggle hybrid
-- editing with `:Markview hybridToggle`; toggle rendering with `:Markview toggle`.

return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "markdown.mdx" },
      callback = function()
        vim.schedule(function()
          vim.opt_local.wrap = false
        end)
      end,
    })
  end,
}
