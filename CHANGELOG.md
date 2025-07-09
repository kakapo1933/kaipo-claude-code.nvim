# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2025-07-09

### Added
- Modular architecture with separated concerns for commands, keymaps, and utilities
- Centralized configuration system with user-customizable options
- Enhanced plugin extensibility and maintainability

### Changed
- Refactored codebase into dedicated modules (commands/, utils/, config.lua, etc.)
- Improved code organization and separation of business logic
- Enhanced plugin architecture for easier feature additions

### Improved
- Code maintainability through clean modular structure
- Plugin extensibility with better separation of concerns
- Configuration management with centralized system

## [0.3.2] - 2025-07-04

### Added
- Floating window position option
- Configurable window positions (left, right, bottom, floating)

### Changed
- Enhanced window management with multiple position options

## [0.3.1] - 2025-07-04

### Changed
- Extracted duplicate window creation logic into helper function
- Improved code organization and maintainability

## [0.3.0] - 2025-07-04

### Added
- Configurable split window positions (left, right, bottom)
- Position commands and keymaps for dynamic window positioning
- Enhanced window management system

### Changed
- Replaced floating windows with configurable split windows as default
- Updated keybinding organization

## [0.2.0] - 2025-07-04

### Added
- .gitignore file with common exclusions

### Changed
- Improved Claude executable detection and updated documentation
- Enhanced plugin stability and user experience

## [0.1.0] - 2025-07-04

### Added
- Initial release of kaipo-claude-code.nvim
- Split terminal interface for Claude Code integration
- Multiple task types with built-in prompts:
  - Code explanation (`<leader>Ce`)
  - Code review (`<leader>Cr`)
  - Code optimization (`<leader>Co`)
  - Code refactoring (`<leader>Cf`)
  - Unit test generation (`<leader>Ct`)
  - Documentation generation (`<leader>Cd`)
  - Custom prompts (`<leader>Cp`)
- Terminal management features:
  - List and reconnect to active Claude terminals (`<leader>CL`)
  - Show active terminals (`<leader>Cs`)
  - Kill all terminals (`<leader>Ck`)
- Automatic Claude Code executable detection
- Which-key integration for organized keybinding display
- Security features with sanitized shell command execution
- Automatic cleanup of temporary files and terminals
- Support for both visual and normal mode operations
- Commands for programmatic usage (`:ClaudeAsk`, `:ClaudeExplain`, etc.)

### Security
- Sanitized shell command execution
- Automatic temporary file cleanup
- Input validation and error handling