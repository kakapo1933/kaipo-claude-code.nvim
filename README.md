# kaipo-claude-code.nvim

[![Version](https://img.shields.io/badge/version-0.3.2-blue.svg)](README.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Neovim plugin for seamless Claude Code integration with split terminal windows.

## Features

- **Split Terminal Interface**: Clean, right-side split windows for Claude Code interactions (40% width)
- **Multiple Task Types**: Built-in prompts for code explanation, review, optimization, refactoring, testing, and documentation
- **Terminal Management**: List, reconnect to, and manage multiple active Claude sessions
- **Custom Prompts**: Send any custom prompt to Claude Code with current buffer or selection
- **Automatic Cleanup**: Temporary files and terminals are cleaned up automatically

## Requirements

- Neovim 0.8.0+
- [Claude Code](https://claude.ai/code) installed and accessible
  - The plugin will automatically detect Claude Code in common installation paths
  - Supported locations: `~/.claude/local/claude`, `~/.local/bin/claude`, `/usr/local/bin/claude`, etc.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "kakapo1933/kaipo-claude-code.nvim",
  config = function()
    require("claude").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "kakapo1933/kaipo-claude-code.nvim",
  config = function()
    require("claude").setup()
  end,
}
```

### Manual Installation

1. Clone this repository to your Neovim configuration directory:
   ```bash
   git clone https://github.com/kakapo1933/kaipo-claude-code.nvim.git ~/.config/nvim/pack/plugins/start/kaipo-claude-code.nvim
   ```

2. Add to your `init.lua`:
   ```lua
   require("claude").setup()
   ```

## Usage

### Visual Mode Commands (Claude Code)

- `<leader>Ce` - Explain selected code
- `<leader>Cr` - Review selected code for bugs and improvements
- `<leader>Co` - Optimize selected code
- `<leader>Cf` - Refactor selected code for readability
- `<leader>Ct` - Generate unit tests for selected code
- `<leader>Cd` - Add comprehensive comments to selected code
- `<leader>Cp` - Custom prompt for selected code

### Normal Mode Commands (Claude Code)

- `<leader>Cb` - Review entire buffer
- `<leader>Ch` - Get help with error messages
- `<leader>CL` - List and reconnect to active Claude terminals
- `<leader>Ca` - Ask custom prompt
- `<leader>Cs` - Show active terminals
- `<leader>Ck` - Kill all terminals
- `<leader>Cx` - Explain current line
- `<leader>Cg` - Debug current file

### Position Commands (Claude Code)

- `<leader>Cp` - Position submenu (when using which-key)
- `<leader>Cpl` - Set window position to left
- `<leader>Cpr` - Set window position to right
- `<leader>Cpb` - Set window position to bottom
- `<leader>Cpf` - Set window position to floating

### Commands

- `:ClaudeAsk [prompt]` - Send custom prompt with current buffer or selection
- `:ClaudeExplain` - Explain current line
- `:ClaudeDebug` - Debug current file with focus on current line
- `:ClaudeList` - List and reconnect to active terminals
- `:ClaudeShow` - Show active terminals (display only)
- `:ClaudeKillAll` - Kill all active Claude terminals
- `:ClaudeDebugState` - Debug plugin state
- `:ClaudePosition {position}` - Set window position (left/right/bottom/floating)
- `:ClaudePositionLeft` - Set window position to left
- `:ClaudePositionRight` - Set window position to right
- `:ClaudePositionBottom` - Set window position to bottom
- `:ClaudePositionFloating` - Set window position to floating

### Window Controls

When a Claude window appears (split or floating):

1. **Terminal Mode** (default): You can see Claude's live output
   - Press `<Esc>` to enter normal mode
   
2. **Normal Mode**: Navigate and control the window
   - Press `q` to close the window
   - Use standard Vim commands (`:close`, `<C-w>c`, etc.)
   - Press `i` or `a` to return to terminal mode (if process is still running)

3. **ClaudeList Window**: Select from active terminals
   - Press number keys (1, 2, 3...) to reconnect to a terminal
   - Press `<Enter>` to select the terminal on the current cursor line
   - Press `q` to cancel and close the list

## Configuration

The plugin works out of the box with sensible defaults. You can customize it by passing options to the setup function:

```lua
require("claude").setup({
  -- Add any custom configuration options here
})
```

### Window Position

You can configure the default window position in three ways:

1. **Set globally in your init.lua:**
```lua
vim.g.claude_split_position = "floating"  -- Options: "left", "right", "bottom", "floating"
```

2. **Change dynamically using commands:**
```vim
:ClaudePosition floating
:ClaudePositionLeft
:ClaudePositionRight
:ClaudePositionBottom
:ClaudePositionFloating
```

3. **Using keymaps:**
- `<leader>Cpl` - Position left
- `<leader>Cpr` - Position right  
- `<leader>Cpb` - Position bottom
- `<leader>Cpf` - Position floating

The default position is "right". Your preference will be saved across sessions when changed via commands.

#### Position Types:
- **left/right/bottom**: Split windows at 40% size
- **floating**: Centered floating window at 80% size with rounded border

## Key Features

### Flexible Window Interface
- **Split Windows**: Clean split windows (left, right, bottom) at 40% size
- **Floating Windows**: Centered floating windows with rounded borders at 80% size
- **Configurable Position**: Choose your preferred window style
- Terminal mode with easy exit (`Esc` enters normal mode)
- Press `q` in normal mode to close windows
- Consistent behavior across all position types

### Terminal Management
- Track multiple concurrent Claude sessions
- Reconnect to background terminals
- Automatic cleanup of finished processes
- Session age tracking

### Which-Key Integration
- Automatic integration with which-key.nvim for organized keybinding display
- Groups commands under `<leader>C` with proper labeling
- Position commands grouped under `<leader>Cp` submenu
- Works with lazy loading and immediate registration

### Security Features
- Sanitized shell command execution
- Automatic temporary file cleanup
- Input validation and error handling

## Troubleshooting

### Claude Code Not Found
The plugin automatically searches for Claude Code in these locations:
- `~/.claude/local/claude` (default Claude installer location)
- `~/.local/bin/claude`
- `/usr/local/bin/claude`
- `/opt/homebrew/bin/claude` (Homebrew on macOS)
- `/usr/bin/claude`

If Claude Code is installed elsewhere:
1. Add it to your PATH: `export PATH="$PATH:/path/to/claude/directory"`
2. Or create a symlink: `ln -s /actual/path/to/claude ~/.local/bin/claude`

To install Claude Code: https://claude.ai/code

### Permission Issues
Ensure the temporary directory (`/tmp`) is writable:
```bash
ls -la /tmp
```

### TTY/Terminal Issues
If you encounter "Raw mode is not supported" errors:
- This plugin has been updated to work without TTY requirements
- The plugin now uses file-based input instead of pipes
- If issues persist, ensure you're running Neovim in a proper terminal

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for seamless AI integration in development workflows
- Built for the Neovim community with love ❤️
