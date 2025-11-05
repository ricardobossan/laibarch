return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "jbyuki/one-small-step-for-vimkind",
      -- stylua: ignore
      config = function()
        local dap = require("dap")

        -- Proper BashDB path
        local BASHDB_DIR = vim.fn.stdpath("data") .. "/mason/opt/bashdb"

        -- Bash adapter setup
        dap.adapters.sh = {
          type = "executable",
          command = vim.fn.stdpath("data") .. "/mason/bin/bash-debug-adapter",
        }

        dap.configurations.sh = {
          {
            name = "Iniciar depurador Bash",
            type = "sh",
            request = "launch",
            program = "${file}",
            cwd = "${fileDirname}",
            pathBashdb = BASHDB_DIR .. "/bashdb",
            pathBashdbLib = BASHDB_DIR,
            pathBash = "bash",
            pathCat = "cat",
            pathMkfifo = "mkfifo",
            pathPkill = "pkill",
            env = {},
            args = {},
            -- showDebugOutput = true,
            -- trace = true,
          },
        }
      end,
    },
  },
}
