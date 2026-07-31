return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Override <leader><space> to search from cwd instead of git root.
    -- Standard find_files picker (fuzzy matching, hidden + ignored files via
    -- opts.pickers.find_files below), except that it shows nothing until the prompt is non-empty.
    {
      "<leader><space>",
      function()
        local sorter = require("telescope.config").values.file_sorter({})
        -- Filter out every entry while the prompt is empty; score normally otherwise.
        -- Wrapping :score rather than :scoring_function keeps these entries out of the
        -- sorter's discard cache, so they come back as soon as something is typed.
        local score = sorter.score
        sorter.score = function(self, prompt, entry, cb_add, cb_filter)
          if prompt == "" then
            return cb_filter(entry)
          end
          return score(self, prompt, entry, cb_add, cb_filter)
        end

        require("telescope.builtin").find_files({ sorter = sorter })
      end,
      desc = "Find Files (cwd)",
    },
    -- Override <leader>/ to search from cwd instead of git root
    {
      "<leader>/",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Grep (cwd)",
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
      -- Configure vimgrep to use --no-ignore for live_grep
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--no-ignore",
        "-g",
        "!.git",
      },
    })

    -- Override the find_files picker to use --no-ignore (for :Telescope find_files)
    opts.pickers = opts.pickers or {}
    opts.pickers.find_files = vim.tbl_deep_extend("force", opts.pickers.find_files or {}, {
      find_command = { "rg", "--files", "--hidden", "--no-ignore", "-g", "!.git" },
      hidden = true,
    })

    return opts
  end,
}
