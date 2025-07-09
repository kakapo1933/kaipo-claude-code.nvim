-- Interactive commands for Claude integration
local command_utils = require('claude.utils.command')
local config = require('claude.config')

local M = {}

-- Register interactive commands
-- @param execute_func function: Function to execute Claude with content
function M.register(execute_func)
	-- Error help command
	M.error_help = function()
		local error_msg = vim.fn.input("Paste error message: ")
		if error_msg ~= "" then
			execute_func("Help me fix this error", error_msg, "Help me fix this error")
		end
	end

	-- ClaudeAsk command - custom prompt with current buffer or selection
	vim.api.nvim_create_user_command("ClaudeAsk", function(cmd_opts)
		local prompt = cmd_opts.args
		if prompt == "" then
			prompt = vim.fn.input("Claude prompt: ")
			if prompt == "" then
				vim.notify("No prompt provided", vim.log.levels.WARN)
				return
			end
		end

		local content, has_selection = command_utils.get_content_by_mode()
		local display_prompt = command_utils.create_display_prompt(prompt, has_selection)
		execute_func(prompt, content, display_prompt)
	end, {
		nargs = "*",
		desc = "Send custom prompt to Claude with current buffer or selection",
		complete = function(ArgLead)
			-- Filter suggestions based on input
			local matches = {}
			for _, suggestion in ipairs(config.prompt_suggestions) do
				if suggestion:lower():find(ArgLead:lower(), 1, true) then
					table.insert(matches, suggestion)
				end
			end
			return matches
		end,
	})
end

return M