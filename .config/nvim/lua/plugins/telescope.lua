return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Override <leader><space> to use find_files with --no-ignore
    {
      "<leader><space>",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find Files (cwd)",
    },
  },
  opts = function(_, opts)
    -- Preserve LazyVim defaults and ensure proper merging
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      -- Ensure prompt is at top with proper layout
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
    })

    -- Override the find_files picker to use --no-ignore
    opts.pickers = opts.pickers or {}
    opts.pickers.find_files = vim.tbl_deep_extend("force", opts.pickers.find_files or {}, {
      find_command = { "rg", "--files", "--hidden", "--no-ignore", "-g", "!.git" },
      hidden = true,
    })

    return opts
  end,
}
