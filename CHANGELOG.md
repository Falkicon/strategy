# Changelog

All notable changes to the Strategy addon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - Unreleased (Midnight Compatibility Update)

### ⚠️ Breaking Changes

This is a major architectural redesign for WoW 12.0 (Midnight) API compatibility. The addon now uses a **button-based strategy panel** instead of target/mouseover auto-detection.

**Why the change?** Blizzard's Midnight expansion introduces "secret values" that restrict `UnitName()`, `UnitGUID()`, and similar APIs in combat and M+ (ChallengeMode). These restrictions make auto-detection of mobs impossible in the content Strategy is designed for.

### Added

- **Strategy Panel**: New visual interface showing all strategies for the current instance
- **Keybind System**: Press 1-0 (or custom binds) to quickly announce strategies
- **Instance Detection**: Automatic loading of strategies when entering supported dungeons
- **Announced Tracking**: Visual indicators showing which strategies have been shared
- **Preview Tooltips**: Hover over strategies to preview before announcing
- **Collapsible Groups**: Organize strategies by area (e.g., "Boss 1", "After Boss 1")
- **New slash commands**: `/ff 1`, `/ff 2`, etc. for quick announcements
- **New slash commands**: `/ff list` to show available strategies

### Changed

- **Data format**: Strategies now organized by instance area, not mob name
- **Output trigger**: Player clicks button or keybind instead of auto-detection
- **UI paradigm**: Strategy Panel replaces Strategy Window
- **Reset behavior**: Announced tracking resets on new instance run, not combat end

### Removed

- **Target detection**: No longer monitors `PLAYER_TARGET_CHANGED`
- **Mouseover detection**: No longer monitors `UPDATE_MOUSEOVER_UNIT`
- **Trigger modes**: "Target only", "Mouseover only", "Both" settings removed
- **Boss name matching**: No longer needs exact `UnitName()` matches

### Migration Notes

**For users upgrading from 1.x:**

- Your settings will be preserved where applicable
- The addon will now show a strategy panel instead of auto-announcing
- Click the strategy buttons or use keybinds to announce
- Strategies are organized by instance area, making it easier to find what you need

**For contributors:**

- Database format has changed - see `Database/README.md` for new structure
- Mob-based entries are now area-based entries with `id`, `name`, `group`, `keybind` fields
- See `spec.md` for complete architectural documentation

---

## [1.0.0] - 2024-12-01

### Added

- Initial release for The War Within Season 3
- Smart targeting with boss/trash detection (target and mouseover)
- Strategy Window for detailed encounter information
- Role-based strategies (Tank, DPS, Healer, All, Interrupt)
- Lazy loading system for memory efficiency
- Anti-spam output tracking (one announcement per boss per instance)
- Multiple output modes (instance, party, say, whisper)
- Modular database structure by expansion/instance
- Ace3 framework integration
- LibDataBroker/Bazooka support
- Slash commands (`/ff`, `/strategy`)
- Settings GUI with AceConfig

### Supported Content

- Operation: Floodgate (5 bosses + 14 high-priority trash)
- Additional Season 3 dungeons in progress
