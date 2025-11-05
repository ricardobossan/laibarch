-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- C# folding configuration
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = "cs",
  callback = function()
    if require("nvim-treesitter.parsers").has_parser() then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt_local.foldlevel = 0
      vim.opt_local.foldenable = true
    end
  end,
})

-- Markdown folding: collapse from ## and beyond
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = "markdown",
  callback = function()
    if require("nvim-treesitter.parsers").has_parser() then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt_local.foldlevel = 1
      vim.opt_local.foldenable = true
    end
  end,
})

-- General folding for other filetypes
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = { "lua", "python", "javascript", "typescript", "rust", "go", "java" },
  callback = function()
    if require("nvim-treesitter.parsers").has_parser() then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt_local.foldlevel = 1
      vim.opt_local.foldenable = true
    end
  end,
})
