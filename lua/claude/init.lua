-- Claude Neovim Integration Plugin
-- Provides floating terminal windows for real-time Claude AI interactions

local config = require('claude.config')
local claude = require('claude.claude')
local commands = require('claude.commands')
local keymaps = require('claude.keymaps')
local visual_commands = require('claude.commands.visual')
local buffer_commands = require('claude.commands.buffer')
local interactive_commands = require('claude.commands.interactive')

local M = {}

-- Configuration for window position (backward compatibility)
M.split_position = vim.g.claude_split_position or config.CONSTANTS.DEFAULT_SPLIT_POSITION

-- Setup function to initialize commands and keymaps
-- @param opts table: Configuration options (optional)
function M.setup(opts)
	opts = opts or {}
	
	-- Merge user options with defaults
	local user_config = vim.tbl_deep_extend("force", config.defaults, opts)
	
	-- Check if Claude is available
	if not claude.check_claude_code() then
		vim.notify("Claude Code not found. Some features may not work.", vim.log.levels.WARN)
	end
	
	-- Register all commands
	commands.register_all_commands()
	
	-- Register command functions for keymaps
	local execute_func = function(prompt, content, display_prompt)
		if not claude.is_available() then
			return
		end
		
		local command_utils = require('claude.utils.command')
		local terminal = require('claude.terminal')
		local claude_executable = claude.get_executable_path()
		
		command_utils.execute_claude_with_content(
			claude_executable,
			terminal.create_claude_terminal,
			prompt,
			content,
			display_prompt
		)
	end
	
	-- Register command functions
	visual_commands.register(execute_func)
	buffer_commands.register(execute_func)
	interactive_commands.register(execute_func)
	
	-- Register all keymaps
	keymaps.register_all_keymaps(visual_commands, buffer_commands, interactive_commands)
	
	-- Update split position if provided in config
	if user_config.split_position then
		M.split_position = user_config.split_position
		vim.g.claude_split_position = user_config.split_position
	end
end

-- Legacy function for backward compatibility
function M.send_to_claude(prompt)
	return function()
		if not claude.is_available() then
			return
		end
		
		local command_utils = require('claude.utils.command')
		local terminal = require('claude.terminal')
		local claude_executable = claude.get_executable_path()
		
		local selection = command_utils.get_visual_selection()
		command_utils.execute_claude_with_content(
			claude_executable,
			terminal.create_claude_terminal,
			prompt,
			selection,
			prompt
		)
	end
end

-- Legacy function for backward compatibility
function M.create_claude_terminal(command, prompt, temp_file)
	local terminal = require('claude.terminal')
	return terminal.create_claude_terminal(command, prompt, temp_file)
end

return M