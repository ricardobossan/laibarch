-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.ai_cmp = true -- enable AI completion sources in blink.cmp / nvim-cmp

vim.opt.wrap = true

-- LazyVim defaults to scrolloff = 4, which keeps 4 lines of context above/below
-- the cursor: the view scrolls before the cursor can reach the first/last visible
-- line, and H/L land 4 lines in from the edges. 0 lets the cursor hit both ends.
vim.opt.scrolloff = 0

-- Override LazyVim's fold settings to use treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 1  -- Default fold level (will be overridden per filetype in autocmds)
vim.opt.foldenable = true
