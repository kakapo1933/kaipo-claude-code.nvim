-- Command execution utilities for Claude integration
local file_utils = require('claude.utils.file')

local M = {}

-- Create Claude command string with input file
-- @param claude_executable string: Path to Claude executable
-- @param merged_file string: Path to input file
-- @return string: Complete command string
function M.create_claude_command(claude_executable, merged_file)
	return string.format("%s < %s", vim.fn.shellescape(claude_executable), vim.fn.shellescape(merged_file))
end

-- Execute Claude with content using the terminal system
-- @param claude_executable string: Path to Claude executable
-- @param terminal_create_func function: Function to create terminal
-- @param prompt string: Prompt text
-- @param content string: Content to process
-- @param display_prompt string: Display prompt for terminal (optional)
function M.execute_claude_with_content(claude_executable, terminal_create_func, prompt, content, display_prompt)
	local merged_file, session_id = file_utils.create_claude_input(prompt, content)
	if not merged_file then
		vim.notify("Error: " .. (session_id or "Unknown error"), vim.log.levels.ERROR)
		return
	end

	local command = M.create_claude_command(claude_executable, merged_file)
	terminal_create_func(command, display_prompt or prompt, merged_file)
end

-- Get visual selection content
-- @return string: Selected text
function M.get_visual_selection()
	vim.cmd('normal! "vy')
	return vim.fn.getreg("v")
end

-- Get current buffer content
-- @return string: Buffer content as string
function M.get_buffer_content()
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

-- Get current line content
-- @return string: Current line text
function M.get_current_line()
	return vim.fn.getline(".")
end

-- Get content based on mode (visual selection vs buffer)
-- @return string: Content
-- @return boolean: True if selection, false if buffer
function M.get_content_by_mode()
	local mode = vim.fn.mode()
	local has_selection = false
	local content = ""

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Visual mode - get selection
		content = M.get_visual_selection()
		has_selection = true
	else
		-- Normal mode - get current buffer content
		content = M.get_buffer_content()
	end

	return content, has_selection
end

-- Create display prompt with mode indicator
-- @param base_prompt string: Base prompt text
-- @param has_selection boolean: Whether content is from selection
-- @return string: Display prompt with mode indicator
function M.create_display_prompt(base_prompt, has_selection)
	if has_selection then
		return base_prompt .. " (selection)"
	else
		return base_prompt .. " (buffer)"
	end
end

return M