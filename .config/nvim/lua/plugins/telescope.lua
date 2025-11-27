return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Override <leader><space> with custom finder that shows nothing when empty
    {
      "<leader><space>",
      function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local make_entry = require("telescope.make_entry")

        pickers
          .new({}, {
            prompt_title = "Find Files",
            finder = finders.new_job(function(prompt)
              if not prompt or prompt == "" then
                return nil -- Returns nil when prompt is empty, showing no results
              end
              -- Run rg --files with the prompt as a filter
              return { "rg", "--files", "--hidden", "--no-ignore", "-g", "!.git", "-g", "*" .. prompt .. "*" }
            end, make_entry.gen_from_file({})),
            sorter = conf.file_sorter({}),
            previewer = conf.file_previewer({}),
          })
          :find()
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
