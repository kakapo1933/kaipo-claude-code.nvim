-- Keymap definitions for Claude plugin
local config = require('claude.config')

local M = {}

-- Register visual mode keymaps
-- @param visual_commands table: Visual command functions
function M.register_visual_keymaps(visual_commands)
	local keymap = vim.keymap.set
	local keymaps = config.defaults.keymaps

	-- Visual mode keymaps
	keymap("v", keymaps.explain, visual_commands.explain_selection, { desc = "[Claude Code] Explain selection" })
	keymap("v", keymaps.review, visual_commands.review_selection, { desc = "[Claude Code] Review selection" })
	keymap("v", keymaps.optimize, visual_commands.optimize_selection, { desc = "[Claude Code] Optimize selection" })
	keymap("v", keymaps.refactor, visual_commands.refactor_selection, { desc = "[Claude Code] Refactor selection" })
	keymap("v", keymaps.test, visual_commands.generate_tests, { desc = "[Claude Code] Generate tests" })
	keymap("v", keymaps.document, visual_commands.add_documentation, { desc = "[Claude Code] Add documentation" })
	keymap("v", keymaps.custom, visual_commands.custom_prompt, { desc = "[Claude Code] Custom prompt" })
end

-- Register buffer mode keymaps
-- @param buffer_commands table: Buffer command functions
function M.register_buffer_keymaps(buffer_commands)
	local keymap = vim.keymap.set
	local keymaps = config.defaults.keymaps

	-- Buffer-wide keymaps
	keymap("n", keymaps.buffer, buffer_commands.review_buffer, { desc = "[Claude Code] Review entire file" })
end

-- Register interactive keymaps
-- @param interactive_commands table: Interactive command functions
function M.register_interactive_keymaps(interactive_commands)
	local keymap = vim.keymap.set
	local keymaps = config.defaults.keymaps

	-- Interactive keymaps
	keymap("n", keymaps.help, interactive_commands.error_help, { desc = "[Claude Code] Help with error" })
end

-- Register terminal management keymaps
function M.register_terminal_keymaps()
	local keymap = vim.keymap.set
	local keymaps = config.defaults.keymaps

	-- Terminal management keymaps
	keymap("n", keymaps.list, "<cmd>ClaudeList<cr>", { desc = "[Claude Code] List terminals" })
	keymap("n", keymaps.ask, "<cmd>ClaudeAsk<cr>", { desc = "[Claude Code] Ask custom prompt" })
	keymap("n", keymaps.show, "<cmd>ClaudeShow<cr>", { desc = "[Claude Code] Show terminals" })
	keymap("n", keymaps.kill, "<cmd>ClaudeKillAll<cr>", { desc = "[Claude Code] Kill all terminals" })
	keymap("n", keymaps.explain_line, "<cmd>ClaudeExplain<cr>", { desc = "[Claude Code] Explain current line" })
	keymap("n", keymaps.debug, "<cmd>ClaudeDebug<cr>", { desc = "[Claude Code] Debug current file" })
	keymap("n", keymaps.open, "<cmd>ClaudeOpen<cr>", { desc = "[Claude Code] Open Claude without prompt" })
end

-- Register position control keymaps
function M.register_position_keymaps()
	local keymap = vim.keymap.set
	local keymaps = config.defaults.keymaps.position

	-- Position control keymaps
	keymap("n", keymaps.left, "<cmd>ClaudePositionLeft<cr>", { desc = "[Claude Code] Position left" })
	keymap("n", keymaps.right, "<cmd>ClaudePositionRight<cr>", { desc = "[Claude Code] Position right" })
	keymap("n", keymaps.bottom, "<cmd>ClaudePositionBottom<cr>", { desc = "[Claude Code] Position bottom" })
	keymap("n", keymaps.floating, "<cmd>ClaudePositionFloating<cr>", { desc = "[Claude Code] Position floating" })
end

-- Register which-key groups
function M.register_which_key_groups()
	-- Register Claude group with which-key
	-- Use autocmd to ensure which-key is loaded
	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyLoad",
		callback = function(event)
			if event.data == "which-key.nvim" then
				local ok, wk = pcall(require, "which-key")
				if ok and wk and wk.add then
					wk.add({
						{ "<leader>C", group = "Claude Code", mode = { "n", "v" } },
						{ "<leader>Cp", group = "Position", mode = "n" },
					})
				end
			end
		end,
	})

	-- Also try immediate registration in case which-key is already loaded
	local ok, wk = pcall(require, "which-key")
	if ok and wk and wk.add then
		wk.add({
			{ "<leader>C", group = "Claude Code", mode = { "n", "v" } },
			{ "<leader>Cp", group = "Position", mode = "n" },
		})
	end
end

-- Register all keymaps
-- @param visual_commands table: Visual command functions
-- @param buffer_commands table: Buffer command functions
-- @param interactive_commands table: Interactive command functions
function M.register_all_keymaps(visual_commands, buffer_commands, interactive_commands)
	M.register_visual_keymaps(visual_commands)
	M.register_buffer_keymaps(buffer_commands)
	M.register_interactive_keymaps(interactive_commands)
	M.register_terminal_keymaps()
	M.register_position_keymaps()
	M.register_which_key_groups()
end

return M