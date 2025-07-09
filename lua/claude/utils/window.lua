-- Window creation and positioning utilities
local config = require('claude.config')

local M = {}

-- Create floating window with specified configuration
-- @param buf number: Buffer ID
-- @param prompt string: Prompt text for window title
-- @return number: Window ID
function M.create_floating_window(buf, prompt)
	local width = math.floor(vim.o.columns * config.CONSTANTS.WIDTH_RATIO)
	local height = math.floor(vim.o.lines * config.CONSTANTS.HEIGHT_RATIO)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local window_config = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Claude: " .. (prompt or "Processing") .. " ",
		title_pos = "center",
	}

	return vim.api.nvim_open_win(buf, true, window_config)
end

-- Create split window with specified position
-- @param buf number: Buffer ID
-- @param prompt string: Prompt text for window title
-- @param position string: Window position ("left", "right", "bottom")
-- @return number: Window ID
function M.create_split_window(buf, prompt, position)
	-- Create split based on position setting
	local commands = {
		left = {"vsplit", "wincmd h"},
		right = {"vsplit", "wincmd L"},
		bottom = {"split", "wincmd J"}
	}

	local cmds = commands[position]
	if cmds then
		for _, cmd in ipairs(cmds) do
			vim.cmd(cmd)
		end
	end

	-- Set window size
	if position == "bottom" then
		local height = math.floor(vim.o.lines * config.CONSTANTS.SPLIT_SIZE_RATIO)
		vim.cmd("resize " .. height)
	else
		local width = math.floor(vim.o.columns * config.CONSTANTS.SPLIT_SIZE_RATIO)
		vim.cmd("vertical resize " .. width)
	end

	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	-- Set window title for splits
	vim.wo[win].statusline = "%#Title# Claude: " .. (prompt or "Processing") .. " %#Normal#"
	return win
end

-- Create and position window based on configuration
-- @param prompt string: Prompt text for window title
-- @param position string: Window position (optional, uses global config if not provided)
-- @return number: Window ID
-- @return number: Buffer ID
function M.create_positioned_window(prompt, position)
	local buf = vim.api.nvim_create_buf(false, true)
	local win_position = position or vim.g.claude_split_position or config.CONSTANTS.DEFAULT_SPLIT_POSITION
	local win

	if win_position == "floating" then
		win = M.create_floating_window(buf, prompt)
	else
		win = M.create_split_window(buf, prompt, win_position)
	end

	return win, buf
end

-- Set up common keymaps for Claude terminal windows
-- @param buf number: Buffer ID
function M.setup_terminal_keymaps(buf)
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buf, noremap = true, silent = true })
end

-- Validate window position
-- @param position string: Position to validate
-- @return boolean: True if valid position
function M.is_valid_position(position)
	for _, valid_pos in ipairs(config.CONSTANTS.SUPPORTED_POSITIONS) do
		if position == valid_pos then
			return true
		end
	end
	return false
end

return M