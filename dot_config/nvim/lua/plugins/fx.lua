local supported_filetypes = {
  json = true,
  jsonc = true,
  toml = true,
  yaml = true,
}

local filetype_args = {
  toml = { "--toml" },
  yaml = { "--yaml" },
}

local filetype_extensions = {
  json = "json",
  jsonc = "jsonc",
  toml = "toml",
  yaml = "yaml",
}

local function open_fx(args)
  if vim.fn.executable("fx") == 0 then
    vim.notify("fx is not installed or not on PATH", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local name = vim.api.nvim_buf_get_name(buf)
  local ext = filetype_extensions[ft] or vim.fn.fnamemodify(name, ":e")
  local tmp = vim.fn.tempname() .. (ext ~= "" and ("." .. ext) or "")
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  vim.fn.writefile(lines, tmp)

  local cmd = { "fx" }
  vim.list_extend(cmd, filetype_args[ft] or {})
  table.insert(cmd, tmp)
  vim.list_extend(cmd, args or {})

  local function cleanup()
    if tmp then
      vim.fn.delete(tmp)
      tmp = nil
    end
  end

  Snacks.terminal.open(cmd, {
    cwd = name ~= "" and vim.fn.fnamemodify(name, ":h") or vim.uv.cwd(),
    win = {
      width = 0,
      height = 0,
      row = 0,
      col = 0,
      border = "none",
      backdrop = false,
      on_buf = function(term)
        term:on("TermClose", cleanup, { buf = true })
        term:on("BufWipeout", cleanup, { buf = true })
      end,
    },
  })
end

return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_user_command("Fx", function(command)
        open_fx(command.fargs)
      end, {
        nargs = "*",
        desc = "Open the current buffer in fx",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(supported_filetypes),
        callback = function(event)
          vim.keymap.set("n", "<leader>jx", function()
            open_fx()
          end, { buffer = event.buf, desc = "Open in fx" })
        end,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "json" },
      },
    },
  },
}
