return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "jbyuki/one-small-step-for-vimkind",
      -- stylua: ignore
      config = function()
        local dap = require("dap")

        -- Proper BashDB path
        local command = vim.fn.exepath('netcoredbg') -- "netcoredbg" --vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"

        -- Got from $HOME/.local/share/nvim/lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/adapters/coreclr.lua
        -- Still unsure what this does
        local function detached()
          if vim.fn.has('win32') == 1 then
            return {
              detached = false,
            }
          end
        end

        -- netcoredbg adapter setup
        dap.adapters.netcoredbg = {
          type = "executable",
          command = command,
          args = { "--interpreter=vscode" },
          options = detached(),
        }

        ---[[
        -- Configuration
        dap.configurations.cs = {
          {
            type = "netcoredbg",
            name = "attach - netcoredbg",
            request = "attach",
            processId = require("dap.utils").pick_process,
            args = {},
          },
          {
            type = "netcoredbg",
            name = "launch - netcoredbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/" .. "bin" .. "/" .. "Debug" .. "/", "file")
            end,
          },
        }
        --]]
      end,
    },
  },
}
