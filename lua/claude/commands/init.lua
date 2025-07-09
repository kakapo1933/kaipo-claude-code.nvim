-- Command registration and management
local claude = require('claude.claude')
local terminal = require('claude.terminal')
local command_utils = require('claude.utils.command')
local window_utils = require('claude.utils.window')
local config = require('claude.config')

local M = {}

-- Helper function to execute Claude with content
-- @param prompt string: Prompt text
-- @param content string: Content to process
-- @param display_prompt string: Display prompt (optional)
local function execute_claude_with_content(prompt, content, display_prompt)
	if not claude.is_available() then
		return
	end

	local claude_executable = claude.get_executable_path()
	command_utils.execute_claude_with_content(
		claude_executable,
		terminal.create_claude_terminal,
		prompt,
		content,
		display_prompt
	)
end

-- Register visual mode commands
function M.register_visual_commands()
	local visual_commands = require('claude.commands.visual')
	visual_commands.register(execute_claude_with_content)
end

-- Register buffer commands
function M.register_buffer_commands()
	local buffer_commands = require('claude.commands.buffer')
	buffer_commands.register(execute_claude_with_content)
end

-- Register interactive commands
function M.register_interactive_commands()
	local interactive_commands = require('claude.commands.interactive')
	interactive_commands.register(execute_claude_with_content)
end

-- Register terminal management commands
function M.register_terminal_commands()
	-- ClaudeList command
	vim.api.nvim_create_user_command("ClaudeList", function()
		local active_terminals = terminal.get_active_terminals()

		if #active_terminals == 0 then
			vim.notify("No active Claude terminals found", vim.log.levels.INFO)
			return
		end

		-- Create window for terminal list
		local win, buf = window_utils.create_positioned_window("Claude Terminals")

		-- Build content for the buffer
		local content = {}
		table.insert(content, "Active Claude Terminals (" .. #active_terminals .. ")")
		table.insert(content, string.rep("=", 50))
		table.insert(content, "")

		for i, term in ipairs(active_terminals) do
			local age_str = terminal.format_terminal_age(term.age)
			table.insert(content, string.format("%d. %s (running for %s)", i, term.prompt, age_str))
		end

		table.insert(content, "")
		table.insert(content, "Press number or Enter to select, q to cancel")

		-- Set buffer content
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
		vim.bo[buf].modifiable = false

		-- Set up selection functionality
		M.setup_terminal_list_selection(win, buf, active_terminals)
	end, { desc = "List and reconnect to Claude terminals" })

	-- ClaudeShow command
	vim.api.nvim_create_user_command("ClaudeShow", function()
		local active_terminals = terminal.get_active_terminals()

		if #active_terminals == 0 then
			print("No active Claude terminals found")
			return
		end

		local split_position = vim.g.claude_split_position or config.CONSTANTS.DEFAULT_SPLIT_POSITION
		print(string.format("\n=== Active Claude Terminals (%d) ===", #active_terminals))
		print(string.format("Current split position: %s", split_position))
		print("--------------------------------------")
		for i, term in ipairs(active_terminals) do
			local age_str = terminal.format_terminal_age(term.age)
			print(string.format("%d. %s (running for %s)", i, term.prompt, age_str))
		end
		print("======================================")
	end, { desc = "Show active Claude terminals" })

	-- ClaudeKillAll command
	vim.api.nvim_create_user_command("ClaudeKillAll", function()
		local count = terminal.kill_all_terminals()
		print(string.format("Killed %d Claude terminal(s)", count))
	end, { desc = "Kill all Claude terminals" })

	-- ClaudeOpen command
	vim.api.nvim_create_user_command("ClaudeOpen", function()
		if not claude.is_available() then
			return
		end

		local claude_executable = claude.get_executable_path()
		local command = vim.fn.shellescape(claude_executable)
		terminal.create_claude_terminal(command, "Claude Interactive Session", "")
	end, { desc = "Open Claude without any prompt" })
end

-- Register position control commands
function M.register_position_commands()
	-- Generic position command
	vim.api.nvim_create_user_command("ClaudePosition", function(opts)
		local position = opts.args:lower()
		if window_utils.is_valid_position(position) then
			vim.g.claude_split_position = position
			vim.notify(string.format("Claude window position set to: %s", position), vim.log.levels.INFO)
		else
			vim.notify("Invalid position. Use: left, right, bottom, or floating", vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		complete = function()
			return config.CONSTANTS.SUPPORTED_POSITIONS
		end,
		desc = "Set Claude window position",
	})

	-- Quick position commands
	local positions = config.CONSTANTS.SUPPORTED_POSITIONS
	for _, position in ipairs(positions) do
		local command_name = "ClaudePosition" .. position:sub(1,1):upper() .. position:sub(2)
		vim.api.nvim_create_user_command(command_name, function()
			vim.g.claude_split_position = position
			vim.notify("Claude window position set to: " .. position, vim.log.levels.INFO)
		end, { desc = "Set Claude window to " .. position })
	end
end

-- Set up terminal list selection functionality
-- @param win number: Window ID
-- @param buf number: Buffer ID
-- @param active_terminals table: Array of terminal info
function M.setup_terminal_list_selection(win, buf, active_terminals)
	local function close_and_select(choice_num)
		vim.api.nvim_win_close(win, true)
		if choice_num and active_terminals[choice_num] then
			terminal.reconnect_to_terminal(active_terminals[choice_num])
		end
	end

	-- Set up key mappings for selection
	for i = 1, #active_terminals do
		vim.keymap.set("n", tostring(i), function()
			close_and_select(i)
		end, { buffer = buf, noremap = true, silent = true })
	end

	-- Enter key to select terminal based on cursor line
	vim.keymap.set("n", "<CR>", function()
		local line_num = vim.api.nvim_win_get_cursor(win)[1]
		-- Lines 1-3 are header, terminal entries start at line 4
		local terminal_index = line_num - 3
		if terminal_index >= 1 and terminal_index <= #active_terminals then
			close_and_select(terminal_index)
		end
	end, { buffer = buf, noremap = true, silent = true })

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, noremap = true, silent = true })
end

-- Register all commands
function M.register_all_commands()
	M.register_visual_commands()
	M.register_buffer_commands()
	M.register_interactive_commands()
	M.register_terminal_commands()
	M.register_position_commands()
end

return M