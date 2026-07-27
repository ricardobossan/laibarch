-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local default_opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- Restore native H / L (top / bottom of the window, like M for middle).
-- LazyVim binds them to bprevious/bnext; deleting the maps falls back to the
-- builtin motions. Buffer switching is still on [b / ]b.
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")

-- Escape insert mode
map("i", "jk", "<ESC>", default_opts)
map("v", "jk", "<ESC>", default_opts)
map("t", "jk", "<ESC>", default_opts)

-- New line escapes insert
-- map("n", "o", "o<ESC>", default_opts)
-- map("v", "o", "o<ESC>", default_opts)
-- map("n", "O", "O<ESC>", default_opts)
-- map("v", "O", "O<ESC>", default_opts)
