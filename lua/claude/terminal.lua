-- Terminal management for Claude sessions
local window_utils = require('claude.utils.window')

local M = {}

-- Store active Claude terminals globally to persist across function calls
if not _G.claude_terminals then
	_G.claude_terminals = {}
end

-- Get the global terminals table
-- @return table: Global terminals table
function M.get_terminals()
	return _G.claude_terminals
end

-- Create a terminal window for Claude processing
-- @param command string: Command to execute
-- @param prompt string: Prompt for window title
-- @param temp_file string: Temporary file path for cleanup
-- @param position string: Window position (optional)
-- @return number: Window ID
-- @return number: Buffer ID
function M.create_claude_terminal(command, prompt, temp_file, position)
	-- Create and position window
	local win, buf = window_utils.create_positioned_window(prompt, position)

	-- Set up terminal keymaps
	window_utils.setup_terminal_keymaps(buf)

	-- Start terminal in the buffer
	local job_id = vim.fn.termopen(command, {
		on_exit = function(_, exit_code, _)
			if exit_code == 0 then
				-- Add instruction at the end (check if buffer is still modifiable)
				pcall(function()
					vim.bo[buf].modifiable = true
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "--- Press q or Esc to close ---" })
					vim.bo[buf].modifiable = false
				end)
			end
			-- Remove from tracking when terminal exits
			_G.claude_terminals[buf] = nil
			-- Clean up temporary file if provided
			if temp_file and temp_file ~= "" then
				pcall(function()
					os.remove(temp_file)
				end)
			end
		end,
	})

	-- Track this terminal with job ID
	_G.claude_terminals[buf] = {
		prompt = prompt,
		created_at = os.time(),
		job_id = job_id,
		pid = vim.fn.jobpid and vim.fn.jobpid(job_id) or nil,
	}

	-- Enter insert mode to show live output
	vim.cmd("startinsert")

	return win, buf
end

-- Get list of active terminals with their info
-- @return table: Array of active terminal info
function M.get_active_terminals()
	local active_terminals = {}
	local claude_terminals = M.get_terminals()

	for buf, info in pairs(claude_terminals) do
		local is_valid = vim.api.nvim_buf_is_valid(buf)
		local job_running = info.job_id and vim.fn.jobwait({ info.job_id }, 0)[1] == -1

		if is_valid and job_running then
			table.insert(active_terminals, {
				buf = buf,
				prompt = info.prompt,
				age = os.time() - info.created_at,
				pid = info.pid,
				job_id = info.job_id,
			})
		else
			claude_terminals[buf] = nil -- Clean up invalid or finished terminals
		end
	end

	return active_terminals
end

-- Kill all active Claude terminals
-- @return number: Number of terminals killed
function M.kill_all_terminals()
	local count = 0
	local claude_terminals = M.get_terminals()
	
	for buf, _ in pairs(claude_terminals) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
			count = count + 1
		end
		claude_terminals[buf] = nil
	end
	
	return count
end

-- Find windows displaying a specific buffer
-- @param buf number: Buffer ID to search for
-- @return table: Array of window IDs displaying the buffer
function M.find_windows_for_buffer(buf)
	local windows = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			table.insert(windows, win)
		end
	end
	return windows
end

-- Reconnect to existing terminal, focusing existing window or creating new one
-- @param terminal_info table: Terminal info from get_active_terminals
-- @param position string: Window position (optional)
-- @return number: Window ID
function M.reconnect_to_terminal(terminal_info, position)
	-- Check if the terminal buffer is already displayed in any window
	local existing_windows = M.find_windows_for_buffer(terminal_info.buf)
	
	if #existing_windows > 0 then
		-- Focus the first existing window instead of creating a new one
		local win = existing_windows[1]
		vim.api.nvim_set_current_win(win)
		return win
	end
	
	-- Create and position window for existing terminal
	local win, new_buf = window_utils.create_positioned_window(terminal_info.prompt, position)

	-- Replace the new buffer with the existing terminal buffer
	vim.api.nvim_win_set_buf(win, terminal_info.buf)
	vim.api.nvim_buf_delete(new_buf, { force = true })

	-- Set up keymaps for the reconnected window
	window_utils.setup_terminal_keymaps(terminal_info.buf)

	return win
end

-- Format terminal age for display
-- @param age_seconds number: Age in seconds
-- @return string: Formatted age string
function M.format_terminal_age(age_seconds)
	return string.format("%dm%ds", math.floor(age_seconds / 60), age_seconds % 60)
end

return M