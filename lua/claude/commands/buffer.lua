-- Buffer-wide commands for Claude integration
local command_utils = require('claude.utils.command')

local M = {}

-- Register buffer commands
-- @param execute_func function: Function to execute Claude with content
function M.register(execute_func)
	-- Buffer review command
	M.review_buffer = function()
		local content = command_utils.get_buffer_content()
		execute_func("Review this entire file", content, "Review this entire file")
	end

	-- ClaudeExplain command - explain current line
	vim.api.nvim_create_user_command("ClaudeExplain", function()
		local line_content = command_utils.get_current_line()
		execute_func("Explain this line of code", line_content, "Explain this line of code")
	end, { desc = "Explain current line with Claude" })

	-- ClaudeDebug command - debug current file with focus on current line
	vim.api.nvim_create_user_command("ClaudeDebug", function()
		local line_num = vim.fn.line(".")
		local debug_prompt = string.format("Debug this file, focus on line %d", line_num)
		local content = command_utils.get_buffer_content()
		execute_func(debug_prompt, content, debug_prompt)
	end, { desc = "Debug current file with Claude" })

	-- ClaudeDebugState command - debug terminal state
	vim.api.nvim_create_user_command("ClaudeDebugState", function()
		local terminal = require('claude.terminal')
		local terminals = terminal.get_terminals()
		
		print("DEBUG: Global claude_terminals state:")
		local count = 0
		for buf, info in pairs(terminals) do
			count = count + 1
			print(
				string.format(
					"  buf=%d: prompt='%s', pid=%s, created=%s",
					buf,
					info.prompt,
					tostring(info.pid),
					os.date("%H:%M:%S", info.created_at)
				)
			)
		end
		print(string.format("Total: %d terminals in global state", count))
	end, { desc = "Debug Claude terminal global state" })
end

return M