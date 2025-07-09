-- Claude executable detection and validation
local config = require('claude.config')

local M = {}

-- Store the path to claude executable
M.executable_path = nil

-- Check if Claude Code is installed and find its path
-- @return boolean: True if Claude is found and executable
function M.check_claude_code()
	-- First check if 'claude' command is directly available
	if vim.fn.executable("claude") == 1 then
		M.executable_path = "claude"
		return true
	end

	-- If not found, check common installation paths
	local home = vim.fn.expand("~")
	local claude_paths = {}
	
	-- Expand home directory in search paths
	for _, path in ipairs(config.claude_search_paths) do
		local expanded_path = path:gsub("^~", home)
		table.insert(claude_paths, expanded_path)
	end

	for _, path in ipairs(claude_paths) do
		if vim.fn.filereadable(path) == 1 and vim.fn.executable(path) == 1 then
			M.executable_path = path
			vim.notify("Claude Code found at: " .. path, vim.log.levels.INFO)
			return true
		end
	end

	vim.notify("Claude Code not found. Install from: https://claude.ai/code", vim.log.levels.ERROR)
	return false
end

-- Get the current Claude executable path
-- @return string|nil: Path to Claude executable or nil if not found
function M.get_executable_path()
	if M.executable_path then
		return M.executable_path
	end
	
	if M.check_claude_code() then
		return M.executable_path
	end
	
	return nil
end

-- Validate that Claude is available before execution
-- @return boolean: True if Claude is available
function M.is_available()
	return M.get_executable_path() ~= nil
end

-- Reset executable path (useful for testing or reconfiguration)
function M.reset()
	M.executable_path = nil
end

return M