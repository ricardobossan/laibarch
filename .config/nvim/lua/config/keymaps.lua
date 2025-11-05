-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local default_opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- Escape insert mode
map("i", "jk", "<ESC>", default_opts)
map("v", "jk", "<ESC>", default_opts)
map("t", "jk", "<ESC>", default_opts)

-- New line escapes insert
map("n", "o", "o<ESC>", default_opts)
map("v", "o", "o<ESC>", default_opts)
map("n", "O", "O<ESC>", default_opts)
map("v", "O", "O<ESC>", default_opts)
