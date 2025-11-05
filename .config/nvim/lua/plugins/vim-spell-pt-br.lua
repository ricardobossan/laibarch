return {
  "mateusbraga/vim-spell-pt-br",
  commit = "3d7eb3098de77b86c8a880354b442b3d84b18a72",
  -- Set spelllang to Portuguese (Brazil)
  init = function()
    vim.g.spellptbr_file = vim.fn.stdpath("data") .. "/spell/pt_br.utf-8.add"
    vim.cmd("au BufNewFile,BufRead *.md,*.txt setlocal spell spelllang=pt_br,en_us")
  end,
}
