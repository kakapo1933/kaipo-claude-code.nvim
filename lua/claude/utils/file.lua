-- File operations and temporary file handling utilities
local config = require('claude.config')

local M = {}

-- Generate unique session ID for file operations
function M.generate_session_id()
	local range = config.CONSTANTS.SESSION_ID_RANGE
	return os.time() .. "_" .. math.random(range[1], range[2])
end

-- Create temporary file with content
-- @param content string: Content to write to file
-- @param prefix string: Prefix for filename (optional)
-- @return string|nil: File path on success, nil on failure
-- @return string: Session ID or error message
function M.create_temp_file(content, prefix)
	local session_id = M.generate_session_id()
	local temp_file = string.format("/tmp/nvim_claude_%s_%s.txt", prefix or "temp", session_id)
	local file = io.open(temp_file, "w")
	if file then
		local success, err = pcall(function()
			file:write(content)
			file:close()
		end)
		if success then
			return temp_file, session_id
		else
			return nil, err
		end
	else
		return nil, "Could not create temporary file"
	end
end

-- Merge two files into a third file using shell command
-- @param prompt_file string: Path to prompt file
-- @param content_file string: Path to content file
-- @param output_file string: Path to output file
-- @return string: System command output
function M.merge_files(prompt_file, content_file, output_file)
	local merge_cmd = string.format(
		"cat %s %s > %s",
		vim.fn.shellescape(prompt_file),
		vim.fn.shellescape(content_file),
		vim.fn.shellescape(output_file)
	)
	return vim.fn.system(merge_cmd)
end

-- Schedule cleanup of temporary files
-- @param files table: Array of file paths to remove
-- @param delay number: Delay in milliseconds (optional)
function M.cleanup_files(files, delay)
	local cleanup_delay = delay or config.CONSTANTS.TEMP_FILE_TIMEOUT
	vim.defer_fn(function()
		for _, file in ipairs(files) do
			pcall(function()
				os.remove(file)
			end)
		end
	end, cleanup_delay)
end

-- Create complete Claude input file with prompt and content
-- @param prompt string: Prompt text
-- @param content string: Content to process
-- @return string|nil: Path to merged file on success, nil on failure
-- @return string: Session ID or error message
function M.create_claude_input(prompt, content)
	local content_file, session_id = M.create_temp_file(content, "content")
	if not content_file then
		return nil, session_id
	end

	local prompt_file, _ = M.create_temp_file(prompt .. ":\n\n", "prompt")
	if not prompt_file then
		M.cleanup_files({content_file}, 0)
		return nil, "Could not create prompt file"
	end

	local merged_file = string.format("/tmp/nvim_claude_merged_%s.txt", session_id)
	M.merge_files(prompt_file, content_file, merged_file)

	-- Schedule cleanup of temporary files
	M.cleanup_files({prompt_file, content_file}, config.CONSTANTS.TEMP_FILE_TIMEOUT)

	return merged_file, session_id
end

return M