# kaipo-claude-code.nvim

A Neovim plugin for seamless Claude Code integration with floating terminal windows.

## Features

- **Floating Terminal Interface**: Clean, non-intrusive floating windows for Claude Code interactions
- **Multiple Task Types**: Built-in prompts for code explanation, review, optimization, refactoring, testing, and documentation
- **Terminal Management**: List, reconnect to, and manage multiple active Claude sessions
- **Custom Prompts**: Send any custom prompt to Claude Code with current buffer or selection
- **Automatic Cleanup**: Temporary files and terminals are cleaned up automatically

## Requirements

- Neovim 0.8.0+
- [Claude Code](https://claude.ai/code) installed and configured

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

### Visual Mode Commands

- `<leader>ce` - Explain selected code
- `<leader>cr` - Review selected code for bugs and improvements
- `<leader>co` - Optimize selected code
- `<leader>cf` - Refactor selected code for readability
- `<leader>ct` - Generate unit tests for selected code
- `<leader>cd` - Add comprehensive comments to selected code
- `<leader>cp` - Custom prompt for selected code

### Normal Mode Commands

- `<leader>cb` - Review entire buffer
- `<leader>ch` - Get help with error messages
- `<leader>gcl` - List and reconnect to active Claude terminals

### Commands

- `:ClaudeAsk [prompt]` - Send custom prompt with current buffer or selection
- `:ClaudeExplain` - Explain current line
- `:ClaudeDebug` - Debug current file with focus on current line
- `:ClaudeList` - List and reconnect to active terminals
- `:ClaudeShow` - Show active terminals (display only)
- `:ClaudeKillAll` - Kill all active Claude terminals
- `:ClaudeDebugState` - Debug plugin state

## Configuration

The plugin works out of the box with sensible defaults. You can customize it by passing options to the setup function:

```lua
require("claude").setup({
  -- Add any custom configuration options here
})
```

## Key Features

### Floating Terminal Interface
- Clean, bordered floating windows
- Automatic sizing (80% of editor dimensions)
- Terminal mode with easy exit (`Esc` key)
- Press `q` or `Esc` to close completed sessions

### Terminal Management
- Track multiple concurrent Claude sessions
- Reconnect to background terminals
- Automatic cleanup of finished processes
- Session age tracking

### Security Features
- Sanitized shell command execution
- Automatic temporary file cleanup
- Input validation and error handling

## Troubleshooting

### Claude Code Not Found
Make sure Claude Code is installed and in your PATH:
Download and install from: https://claude.ai/code

### Permission Issues
Ensure the temporary directory (`/tmp`) is writable:
```bash
ls -la /tmp
```

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