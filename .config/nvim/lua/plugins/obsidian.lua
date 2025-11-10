return {
  "epwalsh/obsidian.nvim",
  --version = "*", -- recommended, use latest release instead of latest commit
  commit = "50242f385835ac8761f3a2006b8464c2f462e9c1",
  priority = 1000,
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "Zettelkasten",
        path = "~/Documents/zettelkasten/",
      },
      {
        name = "bys",
        path = "~/Documents/bys/",
      },
      {
        name = "ricardo",
        path = "~/Documents/ricardo/",
        overrides = {
          daily_notes = {
            folder = "daily_notes",
            date_format = "%Y-%m-%d",
            template = "daily_notes_template.md",
          },
        },
      },
      {
        name = "mai",
        path = "~/Documents/mai/",
      },
    },
    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },
    ui = {
      enable = true, -- set to false to disable all additional syntax features
      update_debounce = 200, -- update delay after a text change (in milliseconds)
      max_file_length = 5000, -- disable UI features for files with more than this many lines
      -- Define how various check-boxes are displayed
      checkboxes = {
        -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        -- ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        -- ["!"] = { char = "", hl_group = "ObsidianImportant" },
        -- Replace the above with this if you don't have a patched font:
        -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
        -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

        -- You can also add more custom ones...
      },
    },
  },
  keys = {
    { "<leader>on", "", desc = "+notes", remap = true },
    { "<leader>ond", "<cmd>ObsidianToday<CR>", desc = "Today", remap = true },
    { "<leader>ono", "<cmd>ObsidianOpen<CR>", desc = "Open", remap = true },
    { "<leader>onm", "<cmd>ObsidianToday +1<CR>", desc = "Tomorrow", remap = true },
    { "<leader>onM", "<cmd>ObsidianTomorrow<CR>", desc = "Tomorrow (weekday)", remap = true },
    { "<leader>onn", "<cmd>ObsidianNew<CR>", desc = "New", remap = true },
    { "<leader>ony", "<cmd>ObsidianToday -1<CR>", desc = "Yesterday", remap = true },
    { "<leader>onY", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday (weekday)", remap = true },
    { "<leader>ot", "<cmd>ObsidianTemplate<CR>", desc = "Insert Template", remap = true },
    { "<leader>ow", "<cmd>ObsidianWorkspace<CR>", desc = "Select Workspace", remap = true },
    { "<leader>ol", "", desc = "+link", remap = true },
    { "<leader>ole", "<cmd>ObsidianLink<CR>", desc = "Add existing", remap = true },
    { "<leader>olg", "<cmd>ObsidianFollowLink<CR>", desc = "Follow", remap = true },
    { "<leader>oll", "<cmd>ObsidianLinks<CR>", desc = "Search all for current note", remap = true },
    { "<leader>olb", "<cmd>ObsidianBacklinks<CR>", desc = "See backlinks for note", remap = true },
    { "<leader>oln", "<cmd>ObsidianLinkNew<CR>", desc = "Add New", remap = true },
    { "<leader>on", "", desc = "+notes", remap = true },
    { "<leader>ond", "<cmd>ObsidianToday<CR>", desc = "Today", remap = true },
    { "<leader>ono", "<cmd>ObsidianOpen<CR>", desc = "Open", remap = true },
    { "<leader>onm", "<cmd>ObsidianToday +1<CR>", desc = "Tomorrow", remap = true },
    { "<leader>onM", "<cmd>ObsidianTomorrow<CR>", desc = "Tomorrow (weekday)", remap = true },
    { "<leader>onn", "<cmd>ObsidianNew<CR>", desc = "New", remap = true },
    { "<leader>ony", "<cmd>ObsidianToday -1<CR>", desc = "Yesterday", remap = true },
    { "<leader>onY", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday (weekday)", remap = true },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", desc = "Switch between notes", remap = true },
    { "<leader>os", "", desc = "+search", remap = true },
    { "<leader>osn", "<cmd>ObsidianSearch<CR>", desc = "Search all notes", remap = true },
    { "<leader>ost", "<cmd>ObsidianTags<CR>", desc = "Search tags", remap = true },
    { "<leader>osl", "<cmd>ObsidianLinks<CR>", desc = "Search links for current note", remap = true },
  },
  -- Inverts checkbox symbols order, so `>` comes before `x`.
  config = function(_, opts)
    local toggle_checkbox = require("obsidian.util").toggle_checkbox
    require("obsidian").setup(opts)

    local client = require("obsidian").get_client()

    vim.api.nvim_create_user_command("ObsidianToggleCheckbox", function()
      local checkboxes = vim.tbl_keys(client.opts.ui.checkboxes)
      table.sort(checkboxes, function(a, b)
        return (client.opts.ui.checkboxes[a].order or 1000) > (client.opts.ui.checkboxes[b].order or 1000)
      end)
      toggle_checkbox(checkboxes)
    end, {})
  end,
}
