# Changelog

All notable changes to the Strategy addon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.6-alpha] - 2025-12-19

### Added
- **FenUI Library**: Embedded FenUI widget library for consistent UI components
- **CurseForge Metadata**: Added `## X-License: GPL-3.0` to .toc file
- **CurseForge Integration**: Added project ID and webhook info to AGENTS.md
- **Cursor Ignore**: Added `.cursorignore` to reduce indexing overhead

### Changed
- **Documentation**: Consolidated shared documentation to central `ADDON_DEV/AGENTS.md`; trimmed addon-specific AGENTS.md
- **Interface Version**: Updated to `120001` for Midnight

## [0.1.5-alpha] - 2025-12-14

### Added
- **Deployment**: Automatic CurseForge packaging via Webhook.
- **Project Structure**: Standardized `LICENSE`, `CONTRIBUTING.md`, and GitHub templates.
- **Documentation**: Centralized dev guides to `Interface/ADDON_DEV`.

### Changed
- **Interface Version**: Updated to `120000` for Midnight Beta compatibility.
- **Documentation**: Corrected role tags (`[TANK]`, `[HEAL]`) and Season 3 info in README.

## [0.1.0-alpha] - 2025-12-14

### Initial Release
- **Strategy Panel**: New visual interface showing all strategies for the current instance.
- **Midnight Ready**: Built on an event-driven architecture compatible with WoW 12.0 API restrictions.
- **Role Targets**: Clear `[TANK]`, `[HEAL]`, `[DPS]`, `[INT]` strategy tagging.
- **Supported Content**: The War Within Season 3 Dungeons.
