-- Configuration constants and defaults for Claude plugin
local M = {}

-- Default constants
M.CONSTANTS = {
	DEFAULT_SPLIT_POSITION = "right",
	WIDTH_RATIO = 0.8,
	HEIGHT_RATIO = 0.8,
	SPLIT_SIZE_RATIO = 0.4,
	TEMP_FILE_TIMEOUT = 1000,
	SESSION_ID_RANGE = {1000, 9999},
	SUPPORTED_POSITIONS = {"left", "right", "bottom", "floating"}
}

-- Default configuration
M.defaults = {
	split_position = M.CONSTANTS.DEFAULT_SPLIT_POSITION,
	auto_setup = true,
	keymaps = {
		explain = "<leader>Ce",
		review = "<leader>Cr",
		optimize = "<leader>Co",
		refactor = "<leader>Cf",
		test = "<leader>Ct",
		document = "<leader>Cd",
		custom = "<leader>Cp",
		buffer = "<leader>Cb",
		help = "<leader>Ch",
		list = "<leader>CL",
		ask = "<leader>Ca",
		show = "<leader>Cs",
		kill = "<leader>Ck",
		explain_line = "<leader>Cx",
		debug = "<leader>Cg",
		open = "<leader>Co",
		position = {
			left = "<leader>Cpl",
			right = "<leader>Cpr",
			bottom = "<leader>Cpb",
			floating = "<leader>Cpf"
		}
	}
}

-- Command suggestions for autocompletion
M.prompt_suggestions = {
	"Explain this code",
	"Review this code for bugs and improvements",
	"Optimize this code",
	"Refactor this code to be more readable",
	"Write unit tests for this code",
	"Add comprehensive comments to this code",
	"Debug this code",
	"What does this code do?",
	"How can I improve this code?",
	"Find potential security issues in this code",
}

-- Claude executable search paths
M.claude_search_paths = {
	"~/.claude/local/claude",
	"~/.local/bin/claude",
	"/usr/local/bin/claude",
	"/opt/homebrew/bin/claude",
	"/usr/bin/claude",
}

return M