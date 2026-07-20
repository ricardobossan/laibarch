-- PlantUML support: syntax highlighting, LSP, and preview.
--
-- The language server (ptdewey/plantuml-lsp) is not in the Mason registry, so
-- it cannot be declared through mason.nvim like the other servers. Instead it
-- is managed as a lazy.nvim plugin whose `build` step compiles the Go binary,
-- which keeps it version-pinned in lazy-lock.json and reinstalls it on a new
-- machine with `:Lazy sync` -- no manual install step.
--
-- Requires the `go` toolchain (see .local/share/ricing/programs.txt), and
-- `plantuml` itself for diagnostics.

local data = vim.fn.stdpath("data")
local server_bin = data .. "/lazy/plantuml-lsp/plantuml-lsp"

-- The server reads exactly one thing from --stdlib-path: a `C4` subdirectory
-- (see internal/features/features.go). The full plantuml-stdlib checkout is
-- 339M, so only stdlib/C4 is sparse-checked-out -- 5M instead, byte-identical.
local stdlib_repo = data .. "/plantuml-stdlib"
local stdlib_path = stdlib_repo .. "/stdlib"

return {
  -- The server provides no semantic tokens, so highlighting still comes from a
  -- syntax file. Neovim 0.10 has no built-in .puml detection and the `ft` keys
  -- below depend on it, hence vim.filetype.add in init.
  {
    "aklt/plantuml-syntax",
    commit = "9d4900aa16674bf5bb8296a72b975317d573b547",
    ft = "plantuml",
    init = function()
      vim.filetype.add({
        extension = {
          puml = "plantuml",
          plantuml = "plantuml",
          pu = "plantuml",
          uml = "plantuml",
          iuml = "plantuml",
          wsd = "plantuml",
        },
      })
    end,
  },

  {
    "ptdewey/plantuml-lsp",
    -- v0.5.3 plus two commits; the build step compiles exactly this revision.
    commit = "dd37e40914b8c2826c360c8ee7d3a211f7e7af83",
    ft = "plantuml",
    build = function(plugin)
      local function run(cmd, cwd)
        local res = vim.system(cmd, { cwd = cwd, text = true }):wait()
        if res.code ~= 0 then
          error(table.concat(cmd, " ") .. " failed:\n" .. (res.stderr or ""))
        end
      end

      run({ "go", "build", "-o", "plantuml-lsp", "." }, plugin.dir)

      if vim.fn.isdirectory(stdlib_repo) == 0 then
        run({
          "git",
          "clone",
          "--filter=blob:none",
          "--no-checkout",
          "--depth=1",
          "https://github.com/plantuml/plantuml-stdlib.git",
          stdlib_repo,
        })
        run({ "git", "sparse-checkout", "set", "--no-cone", "stdlib/C4" }, stdlib_repo)
        run({ "git", "checkout" }, stdlib_repo)
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Degrade gracefully: before `:Lazy build` has run on a fresh machine the
      -- binary does not exist yet, and registering it would only produce errors.
      if vim.fn.executable(server_bin) == 0 then
        return opts
      end

      local cmd = { server_bin, "--exec-path=plantuml" }
      if vim.fn.isdirectory(stdlib_path) == 1 then
        table.insert(cmd, "--stdlib-path=" .. stdlib_path)
      end

      -- lspconfig ships no plantuml server, so define one before LazyVim walks
      -- opts.servers and calls setup() on it.
      local configs = require("lspconfig.configs")
      if not configs.plantuml_lsp then
        configs.plantuml_lsp = {
          default_config = {
            cmd = cmd,
            filetypes = { "plantuml" },
            root_dir = function(fname)
              return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1]) or vim.fs.dirname(fname)
            end,
            settings = {},
          },
        }
      end

      opts.servers = opts.servers or {}
      -- mason = false: not in the Mason registry, built by the `build` step above.
      opts.servers.plantuml_lsp = { mason = false }
      return opts
    end,
  },

  -- Live preview in the browser: alacritty has no inline image protocol, so
  -- rendering in the terminal is not an option.
  {
    "weirongxu/plantuml-previewer.vim",
    commit = "368a1f331c1ff29f6a3ee76facfca39a7f374b13",
    ft = "plantuml",
    dependencies = {
      { "tyru/open-browser.vim", commit = "7d4c1d8198e889d513a030b5a83faa07606bac27" },
    },
    init = function()
      -- The plugin bundles PlantUML 1.2023.2, so previews would render against a
      -- different version than the language server uses for diagnostics (error
      -- renders even carry a "1239 days old" nag). Prefer the system jar, which
      -- is what `plantuml` on PATH runs.
      local jar = "/usr/share/java/plantuml/plantuml.jar"
      if vim.fn.filereadable(jar) == 1 then
        vim.g["plantuml_previewer#plantuml_jar_path"] = jar
      end
    end,
    keys = {
      {
        "<leader>cp",
        ft = "plantuml",
        "<cmd>PlantumlToggle<cr>",
        desc = "PlantUML Preview",
      },
    },
  },
}
