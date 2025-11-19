#!/usr/bin/env -S nvim -l

-- Script to generate plugin pins from lazy-lock.json
-- Usage: nvim -l ~/.config/nvim/scripts/generate-lockfile-pins.lua

local config_path = vim.fn.stdpath("config")
local lockfile = config_path .. "/lazy-lock.json"
local output_file = config_path .. "/lua/plugins/lockfile-pins.lua"

-- Read lockfile
local lock_data = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))

-- Get currently loaded plugin specs to extract repo URLs
local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  print("Error: lazy.nvim not loaded")
  os.exit(1)
end

-- Build a map of plugin names to their repos from currently installed plugins
local plugin_repos = {}
for _, plugin in pairs(require("lazy.core.config").plugins) do
  if plugin.name and plugin.url then
    -- Extract owner/repo from git URL
    local repo = plugin.url:match("github.com[:/](.+)%.git$") or plugin.url:match("github.com[:/](.+)$")
    if repo then
      plugin_repos[plugin.name] = repo
    end
  end
end

-- Generate pins file
local lines = {
  "-- Auto-generated from lazy-lock.json",
  "-- Run: nvim -l ~/.config/nvim/scripts/generate-lockfile-pins.lua",
  "-- Do not edit manually!",
  "",
  "return {",
}

for plugin_name, plugin_info in pairs(lock_data) do
  if plugin_info.commit and plugin_repos[plugin_name] then
    table.insert(lines, string.format('  { "%s", commit = "%s" },',
      plugin_repos[plugin_name],
      plugin_info.commit))
  end
end

table.insert(lines, "}")

-- Write output
vim.fn.writefile(lines, output_file)
print("Generated: " .. output_file)
print("Pinned " .. #lines - 5 .. " plugins")