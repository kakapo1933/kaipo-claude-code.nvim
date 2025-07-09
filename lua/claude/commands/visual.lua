-- Visual mode commands for Claude integration
local command_utils = require('claude.utils.command')

local M = {}

-- Create function to send visual selection to Claude
-- @param execute_func function: Function to execute Claude with content
-- @param prompt string: Prompt text
-- @return function: Command function
local function create_visual_command(execute_func, prompt)
	return function()
		local selection = command_utils.get_visual_selection()
		execute_func(prompt, selection, prompt)
	end
end

-- Register visual mode commands
-- @param execute_func function: Function to execute Claude with content
function M.register(execute_func)
	-- Visual mode commands for code analysis
	local visual_commands = {
		{ prompt = "Explain this code", desc = "Explain selection" },
		{ prompt = "Review this code for bugs and improvements", desc = "Review selection" },
		{ prompt = "Optimize this code", desc = "Optimize selection" },
		{ prompt = "Refactor this code to be more readable", desc = "Refactor selection" },
		{ prompt = "Write unit tests for this code", desc = "Generate tests" },
		{ prompt = "Add comprehensive comments to this code", desc = "Add documentation" },
	}

	-- Register each visual command
	for _, cmd in ipairs(visual_commands) do
		local command_func = create_visual_command(execute_func, cmd.prompt)
		-- These will be registered as keymaps in the keymaps module
		M[cmd.desc:lower():gsub(" ", "_")] = command_func
	end

	-- Custom prompt command
	M.custom_prompt = function()
		local prompt = vim.fn.input("Claude prompt: ")
		if prompt ~= "" then
			local selection = command_utils.get_visual_selection()
			execute_func(prompt, selection, prompt)
		end
	end
end

return M