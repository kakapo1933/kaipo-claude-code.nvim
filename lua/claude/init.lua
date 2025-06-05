-- Claude Neovim Integration Plugin
-- Provides floating terminal windows for real-time Claude AI interactions

local M = {}

-- Store active Claude terminals globally to persist across function calls
if not _G.claude_terminals then
  _G.claude_terminals = {}
end
local claude_terminals = _G.claude_terminals

-- Check if Claude Code is installed
local function check_claude_code()
  -- Use vim.system for better security and error handling
  local result = vim.system({ "which", "claude" }):wait()
  if result.code ~= 0 then
    vim.notify("Claude Code not found. Install from: https://claude.ai/code", vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Function to create a floating terminal window for Claude processing
function M.create_claude_terminal(command, prompt, temp_file)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local window_config = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Claude Processing: " .. prompt .. " ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, window_config)

  -- Key mappings for the floating terminal
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buf, noremap = true, silent = true })

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
      claude_terminals[buf] = nil
      -- Clean up temporary file if provided
      if temp_file and temp_file ~= "" then
        pcall(function()
          os.remove(temp_file)
        end)
      end
    end,
  })

  -- Track this terminal with job ID
  claude_terminals[buf] = {
    prompt = prompt,
    created_at = os.time(),
    job_id = job_id,
    pid = vim.fn.jobpid(job_id),
  }

  -- Enter insert mode to show live output
  vim.cmd("startinsert")

  return win, buf
end

-- Function to send visual selection to Claude using floating terminal
function M.send_to_claude(prompt)
  return function()
    if not check_claude_code() then
      return
    end

    -- Get visual selection using vim's built-in function
    vim.cmd('normal! "vy')
    local selection = vim.fn.getreg("v")

    -- Create unique temporary file for this session
    local session_id = os.time() .. "_" .. math.random(1000, 9999)
    local temp_file = string.format("/tmp/nvim_claude_%s.txt", session_id)
    local file = io.open(temp_file, "w")
    if file then
      file:write(selection)
      file:close()

      -- Create floating terminal with Claude command (sanitized)
      -- Write prompt to temp file to avoid pipe issues
      local prompt_file = string.format("/tmp/nvim_claude_prompt_%s.txt", session_id)
      local prompt_handle = io.open(prompt_file, "w")
      if prompt_handle then
        prompt_handle:write(prompt .. ":\n\n")
        prompt_handle:close()
        
        local escaped_prompt_file = vim.fn.shellescape(prompt_file)
        local escaped_temp_file = vim.fn.shellescape(temp_file)
        local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_temp_file)
        M.create_claude_terminal(command, prompt, temp_file)
        
        -- Clean up prompt file after a delay
        vim.defer_fn(function()
          pcall(function() os.remove(prompt_file) end)
        end, 1000)
      else
        vim.notify("Error creating prompt file", vim.log.levels.ERROR)
      end
    else
      vim.notify("Error creating temporary file", vim.log.levels.ERROR)
    end
  end
end

-- Setup function to initialize commands and keymaps
function M.setup(opts)
  opts = opts or {}
  local keymap = vim.keymap.set

  -- Send selection for explanation
  keymap("v", "<leader>Ce", M.send_to_claude("Explain this code"), { desc = "[Claude Code] Explain selection" })

  -- Send selection for review
  keymap(
    "v",
    "<leader>Cr",
    M.send_to_claude("Review this code for bugs and improvements"),
    { desc = "[Claude Code] Review selection" }
  )

  -- Send selection for optimization
  keymap("v", "<leader>Co", M.send_to_claude("Optimize this code"), { desc = "[Claude Code] Optimize selection" })

  -- Send selection for refactoring
  keymap(
    "v",
    "<leader>Cf",
    M.send_to_claude("Refactor this code to be more readable"),
    { desc = "[Claude Code] Refactor selection" }
  )

  -- Send selection for testing
  keymap("v", "<leader>Ct", M.send_to_claude("Write unit tests for this code"), { desc = "[Claude Code] Generate tests" })

  -- Send selection for documentation
  keymap(
    "v",
    "<leader>Cd",
    M.send_to_claude("Add comprehensive comments to this code"),
    { desc = "[Claude Code] Add documentation" }
  )

  -- Send selection with custom prompt
  keymap("v", "<leader>Cp", function()
    local prompt = vim.fn.input("Claude prompt: ")
    if prompt ~= "" then
      M.send_to_claude(prompt)()
    end
  end, { desc = "[Claude Code] Custom prompt" })

  -- Send entire buffer to Claude
  keymap("n", "<leader>Cb", function()
    if not check_claude_code() then
      return
    end

    local filename = vim.fn.expand("%")
    local escaped_filename = vim.fn.shellescape(filename)
    -- Create prompt file to avoid pipe issues
    local session_id = os.time() .. "_" .. math.random(1000, 9999)
    local prompt_file = string.format("/tmp/nvim_claude_prompt_%s.txt", session_id)
    local prompt_handle = io.open(prompt_file, "w")
    if prompt_handle then
      prompt_handle:write("Review this entire file:\n\n")
      prompt_handle:close()
      
      local escaped_prompt_file = vim.fn.shellescape(prompt_file)
      local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_filename)
      M.create_claude_terminal(command, "Review this entire file")
      
      -- Clean up prompt file after a delay
      vim.defer_fn(function()
        pcall(function() os.remove(prompt_file) end)
      end, 1000)
    else
      vim.notify("Error creating prompt file", vim.log.levels.ERROR)
    end
  end, { desc = "[Claude Code] Review entire file" })

  -- Quick commands for common tasks
  vim.api.nvim_create_user_command("ClaudeExplain", function()
    if not check_claude_code() then
      return
    end

    local selection = vim.fn.getline(".")
    local session_id = os.time() .. "_" .. math.random(1000, 9999)
    local temp_file = string.format("/tmp/nvim_claude_line_%s.txt", session_id)
    local file = io.open(temp_file, "w")
    if file then
      local write_success, write_err = pcall(function()
        file:write(selection)
        file:close()
      end)

      if write_success then
        -- Create prompt file to avoid pipe issues
        local prompt_file = string.format("/tmp/nvim_claude_prompt_line_%s.txt", session_id)
        local prompt_handle = io.open(prompt_file, "w")
        if prompt_handle then
          prompt_handle:write("Explain this line of code:\n\n")
          prompt_handle:close()
          
          local escaped_prompt_file = vim.fn.shellescape(prompt_file)
          local escaped_temp_file = vim.fn.shellescape(temp_file)
          local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_temp_file)
          M.create_claude_terminal(command, "Explain this line of code", temp_file)
          
          -- Clean up prompt file after a delay
          vim.defer_fn(function()
            pcall(function() os.remove(prompt_file) end)
          end, 1000)
        else
          vim.notify("Error creating prompt file", vim.log.levels.ERROR)
        end
      else
        vim.notify("Error writing to temporary file: " .. (write_err or "unknown"), vim.log.levels.ERROR)
        pcall(function()
          os.remove(temp_file)
        end)
      end
    else
      vim.notify("Error creating temporary file", vim.log.levels.ERROR)
    end
  end, { desc = "Explain current line with Claude" })

  vim.api.nvim_create_user_command("ClaudeDebug", function()
    if not check_claude_code() then
      return
    end

    local filename = vim.fn.expand("%")
    local line_num = vim.fn.line(".")
    local debug_prompt = string.format("Debug this file, focus on line %d", line_num)
    -- Create prompt file to avoid pipe issues
    local session_id = os.time() .. "_" .. math.random(1000, 9999)
    local prompt_file = string.format("/tmp/nvim_claude_prompt_debug_%s.txt", session_id)
    local prompt_handle = io.open(prompt_file, "w")
    if prompt_handle then
      prompt_handle:write(debug_prompt .. ":\n\n")
      prompt_handle:close()
      
      local escaped_prompt_file = vim.fn.shellescape(prompt_file)
      local escaped_filename = vim.fn.shellescape(filename)
      local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_filename)
      M.create_claude_terminal(command, debug_prompt)
      
      -- Clean up prompt file after a delay
      vim.defer_fn(function()
        pcall(function() os.remove(prompt_file) end)
      end, 1000)
    else
      vim.notify("Error creating prompt file", vim.log.levels.ERROR)
    end
  end, { desc = "Debug current file with Claude" })

  -- Function to get Claude help for error messages
  keymap("n", "<leader>Ch", function()
    if not check_claude_code() then
      return
    end

    local error_msg = vim.fn.input("Paste error message: ")
    if error_msg ~= "" then
      local session_id = os.time() .. "_" .. math.random(1000, 9999)
      local temp_file = string.format("/tmp/nvim_claude_error_%s.txt", session_id)
      local file = io.open(temp_file, "w")
      if file then
        local write_success, write_err = pcall(function()
          file:write(error_msg)
          file:close()
        end)

        if write_success then
          -- Create prompt file to avoid pipe issues
          local prompt_file = string.format("/tmp/nvim_claude_prompt_error_%s.txt", session_id)
          local prompt_handle = io.open(prompt_file, "w")
          if prompt_handle then
            prompt_handle:write("Help me fix this error:\n\n")
            prompt_handle:close()
            
            local escaped_prompt_file = vim.fn.shellescape(prompt_file)
            local escaped_temp_file = vim.fn.shellescape(temp_file)
            local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_temp_file)
            M.create_claude_terminal(command, "Help me fix this error", temp_file)
            
            -- Clean up prompt file after a delay
            vim.defer_fn(function()
              pcall(function() os.remove(prompt_file) end)
            end, 1000)
          else
            vim.notify("Error creating prompt file", vim.log.levels.ERROR)
          end
        else
          vim.notify("Error writing to temporary file: " .. (write_err or "unknown"), vim.log.levels.ERROR)
          pcall(function()
            os.remove(temp_file)
          end)
        end
      else
        vim.notify("Error creating temporary file", vim.log.levels.ERROR)
      end
    end
  end, { desc = "[Claude Code] Help with error" })

  -- Command to list active Claude terminals
  vim.api.nvim_create_user_command("ClaudeList", function()
    local active_terminals = {}

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

    if #active_terminals == 0 then
      vim.notify("No active Claude terminals found", vim.log.levels.INFO)
      return
    end

    -- Create a floating window to display the list
    local buf = vim.api.nvim_create_buf(false, true)

    -- Build content for the buffer
    local content = {}
    table.insert(content, "Active Claude Terminals (" .. #active_terminals .. ")")
    table.insert(content, string.rep("=", 50))
    table.insert(content, "")

    for i, term in ipairs(active_terminals) do
      local age_str = string.format("%dm%ds", math.floor(term.age / 60), term.age % 60)
      table.insert(content, string.format("%d. %s (running for %s)", i, term.prompt, age_str))
    end

    table.insert(content, "")
    table.insert(content, "Press number to select, or Esc to cancel")

    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.bo[buf].modifiable = false

    -- Create floating window
    local width = math.floor(vim.o.columns * 0.6)
    local height = #content + 2
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local list_window_config = {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " Claude Terminals ",
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, list_window_config)

    -- Set up key mappings for selection
    local function close_and_select(choice_num)
      vim.api.nvim_win_close(win, true)
      if choice_num and active_terminals[choice_num] then
        local selected = active_terminals[choice_num]
        -- Create new floating window for existing terminal
        local term_width = math.floor(vim.o.columns * 0.8)
        local term_height = math.floor(vim.o.lines * 0.8)
        local term_row = math.floor((vim.o.lines - term_height) / 2)
        local term_col = math.floor((vim.o.columns - term_width) / 2)

        local terminal_window_config = {
          relative = "editor",
          width = term_width,
          height = term_height,
          row = term_row,
          col = term_col,
          style = "minimal",
          border = "rounded",
          title = " Claude Processing: " .. selected.prompt .. " ",
          title_pos = "center",
        }

        vim.api.nvim_open_win(selected.buf, true, terminal_window_config)

        -- Set up keymaps for the reconnected window
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = selected.buf, noremap = true, silent = true })
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = selected.buf, noremap = true, silent = true })
      end
    end

    -- Set up key mappings
    for i = 1, #active_terminals do
      vim.keymap.set("n", tostring(i), function()
        close_and_select(i)
      end, { buffer = buf, noremap = true, silent = true })
    end

    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, noremap = true, silent = true })
  end, { desc = "List and reconnect to Claude terminals" })

  -- Command to kill all Claude terminals
  vim.api.nvim_create_user_command("ClaudeKillAll", function()
    local count = 0
    for buf, _ in pairs(claude_terminals) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
        count = count + 1
      end
      claude_terminals[buf] = nil
    end
    print(string.format("Killed %d Claude terminal(s)", count))
  end, { desc = "Kill all Claude terminals" })

  -- Set up keymap group for Claude commands will be done after all keymaps

  -- Add keymapping for quick access
  keymap("n", "<leader>CL", "<cmd>ClaudeList<cr>", { desc = "[Claude Code] List terminals" })
  -- Additional Claude commands under C prefix
  keymap("n", "<leader>Ca", "<cmd>ClaudeAsk<cr>", { desc = "[Claude Code] Ask custom prompt" })
  keymap("n", "<leader>Cs", "<cmd>ClaudeShow<cr>", { desc = "[Claude Code] Show terminals" })
  keymap("n", "<leader>Ck", "<cmd>ClaudeKillAll<cr>", { desc = "[Claude Code] Kill all terminals" })
  keymap("n", "<leader>Cx", "<cmd>ClaudeExplain<cr>", { desc = "[Claude Code] Explain current line" })
  keymap("n", "<leader>Cg", "<cmd>ClaudeDebug<cr>", { desc = "[Claude Code] Debug current file" })

  -- Command for custom Claude prompts
  vim.api.nvim_create_user_command("ClaudeAsk", function(cmd_opts)
    if not check_claude_code() then
      return
    end

    local prompt = cmd_opts.args
    if prompt == "" then
      prompt = vim.fn.input("Claude prompt: ")
      if prompt == "" then
        vim.notify("No prompt provided", vim.log.levels.WARN)
        return
      end
    end

    -- Check if we're in visual mode or have a selection
    local mode = vim.fn.mode()
    local has_selection = false
    local content = ""

    if mode == "v" or mode == "V" or mode == "\22" then
      -- Visual mode - get selection
      vim.cmd('normal! "vy')
      content = vim.fn.getreg("v")
      has_selection = true
    else
      -- Normal mode - get current buffer content
      local filename = vim.fn.expand("%")
      if filename ~= "" and vim.fn.filereadable(filename) == 1 then
        content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      else
        content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      end
    end

    -- Create temporary file with content
    local session_id = os.time() .. "_" .. math.random(1000, 9999)
    local temp_file = string.format("/tmp/nvim_claude_custom_%s.txt", session_id)
    local file = io.open(temp_file, "w")
    if file then
      local write_success, write_err = pcall(function()
        file:write(content)
        file:close()
      end)

      if write_success then
        -- Create prompt file to avoid pipe issues
        local prompt_file = string.format("/tmp/nvim_claude_prompt_ask_%s.txt", session_id)
        local prompt_handle = io.open(prompt_file, "w")
        if prompt_handle then
          prompt_handle:write(prompt .. ":\n\n")
          prompt_handle:close()
          
          local escaped_prompt_file = vim.fn.shellescape(prompt_file)
          local escaped_temp_file = vim.fn.shellescape(temp_file)
          local command = string.format("cat %s %s | claude", escaped_prompt_file, escaped_temp_file)
          local display_prompt = has_selection and (prompt .. " (selection)") or (prompt .. " (buffer)")
          M.create_claude_terminal(command, display_prompt, temp_file)
          
          -- Clean up prompt file after a delay
          vim.defer_fn(function()
            pcall(function() os.remove(prompt_file) end)
          end, 1000)
        else
          vim.notify("Error creating prompt file", vim.log.levels.ERROR)
        end
      else
        vim.notify("Error writing to temporary file: " .. (write_err or "unknown"), vim.log.levels.ERROR)
        pcall(function()
          os.remove(temp_file)
        end)
      end
    else
      vim.notify("Error: Could not create temporary file", vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    desc = "Send custom prompt to Claude with current buffer or selection",
    complete = function(ArgLead)
      -- Provide some common prompt suggestions
      local suggestions = {
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

      local matches = {}
      for _, suggestion in ipairs(suggestions) do
        if suggestion:lower():find(ArgLead:lower(), 1, true) then
          table.insert(matches, suggestion)
        end
      end
      return matches
    end,
  })

  -- Command to show terminals without reconnection prompt
  vim.api.nvim_create_user_command("ClaudeShow", function()
    local active_terminals = {}

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
        claude_terminals[buf] = nil
      end
    end

    if #active_terminals == 0 then
      print("No active Claude terminals found")
      return
    end

    print(string.format("\n=== Active Claude Terminals (%d) ===", #active_terminals))
    for i, term in ipairs(active_terminals) do
      local age_str = string.format("%dm%ds", math.floor(term.age / 60), term.age % 60)
      print(string.format("%d. %s (running for %s)", i, term.prompt, age_str))
    end
    print("======================================")
  end, { desc = "Show active Claude terminals" })

  -- Debug command to check global state
  vim.api.nvim_create_user_command("ClaudeDebugState", function()
    print("DEBUG: Global claude_terminals state:")
    local count = 0
    for buf, info in pairs(_G.claude_terminals) do
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
  -- Register Claude group with which-key
  vim.schedule(function()
    local ok, wk = pcall(require, 'which-key')
    if ok and wk and wk.add then
      wk.add({
        { "<leader>C", group = "Claude Code" },
      })
    end
  end)
end

return M