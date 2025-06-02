-- claude.nvim plugin entry point
-- This file is loaded automatically by Neovim

if vim.g.loaded_claude then
  return
end
vim.g.loaded_claude = 1

-- Only auto-setup if user hasn't explicitly configured it
if not vim.g.claude_manual_setup then
  require('claude').setup()
end