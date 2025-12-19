# Strategy – Agent Documentation

Technical reference for AI agents modifying this addon.

## External References

### Development Documentation
For comprehensive addon development guidance, consult these resources:

- **[ADDON_DEV/AGENTS.md](../../ADDON_DEV/AGENTS.md)** – Library index, automation scripts, dependency chains
- **[Addon Development Guide](../../ADDON_DEV/Addon_Dev_Guide/)** – Full documentation covering:
  - Core principles, project structure, TOC best practices
  - UI engineering, configuration UI, combat lockdown
  - Performance optimization, API resilience
  - Debugging, packaging/release workflow
  - Midnight (12.0) compatibility and secret values

### Blizzard UI Source Code
For reverse-engineering, hijacking, or modifying official Blizzard UI frames:

- **[wow-ui-source-live](../../wow-ui-source-live/)** – Official Blizzard UI addon code
  - Use this to understand frame hierarchies, event patterns, and protected frame behavior
  - Reference for instance/dungeon detection and boss frame implementations
  - Helpful for understanding chat channel APIs and message formatting

---

## Project Intent

A dungeon/raid strategy addon for WoW that provides:

- Pre-written strategies for boss encounters and trash pulls
- Button-based strategy panel with keybind support (1-0 keys)
- Role-filtered strategy output (tank, healer, DPS, interrupt, all)
- Multiple output channels (instance chat, party, say, whisper, self)
- Per-instance strategy databases with group organization

## Constraints

- Must work on Retail 11.0.2+
- Uses Ace3 framework (AceAddon, AceDB, AceConfig, AceEvent)
- Resilient to Midnight API restrictions (no mouseover/target detection in combat)

## File Structure

| File | Purpose | Lines |
|------|---------|-------|
| `Strategy.toc` | Manifest (library loading order) | ~60 |
| `Core/Core.lua` | Main addon initialization | ~514 |
| `Core/DefaultsManager.lua` | Settings UI and defaults | ~668 |
| `Core/StrategyPanel.lua` | v2.0 button panel UI | ~915 |
| `Core/StrategyEngine.lua` | Output formatting | ~404 |
| `Core/DatabaseManager.lua` | Strategy data management | ~380 |
| `Core/InstanceDetector.lua` | Zone/instance detection | ~307 |
| `Core/KeybindManager.lua` | Keybind system (1-0) | ~255 |
| `Database/StrategyDatabase.lua` | Database registry | ~50 |
| `Database/TWW/Dungeon/*.lua` | Per-instance strategy files | varies |

## Architecture

### Data Flow

1. InstanceDetector detects zone change → loads instance data
2. StrategyPanel displays strategies as clickable buttons
3. User clicks button or presses keybind (1-0)
4. StrategyPanel calls StrategyEngine to format output
5. Output sent to configured channel (instance/party/say/whisper/self)

### Strategy Data Format

Strategies are organized in instance files under `Database/TWW/Dungeon/`:

```lua
{
    instanceID = 1274,  -- Numeric ID for reliable matching
    instanceName = "Operation: Floodgate",
    strategies = {
        {
            id = "boss1_momma",
            name = "Big M.O.M.M.A.",
            group = "Boss 1",
            keybind = 2,
            strategy = {
                interrupt = { "Interrupt Hydraulic Blast" },
                tank = { "Face away from group during Hydraulic Blast" },
                dps = { "Kill adds quickly" },
                healer = { "Tank takes heavy damage during Hydraulic Blast" },
                all = { "Move as a group during Pneumatic Burst" }
            }
        },
    }
}
```

**Group naming conventions:**

- `"Before Boss N"` – Trash pulls before boss
- `"Boss N"` – Boss encounter (divider shows boss name from strategy.name)
- `"After Boss N"` – Trash pulls after boss

### Output Format

Strategies are output with role tags and bullet points:

```
=== Big M.O.M.M.A. ===
[!] • Interrupt Hydraulic Blast
[T] • Face away from group during Hydraulic Blast
[D] • Kill adds quickly
[H] • Tank takes heavy damage during Hydraulic Blast
[A] • Move as a group during Pneumatic Burst
```

**Role tags:** `[!]` Interrupt, `[T]` Tank, `[D]` DPS, `[H]` Healer, `[A]` All roles

### Visibility and Enabled State

**Panel visibility logic:**

1. Addon must be `enabled = true`
2. Must be in a supported instance (dungeon/raid)
3. Instance data must exist in database
4. Auto-show respects `autoShowStrategyPanel` setting

**When disabled:** Panel hides immediately, keybinds are unregistered

### Performance Patterns

- Event-driven: `ZONE_CHANGED_NEW_AREA`, `PLAYER_ENTERING_WORLD`
- Lazy loading: Instance data loaded only when needed
- Announced state cached in SavedVariables
- Settings changes trigger live updates via `ApplySettings()`

## SavedVariables

- **Root**: `StrategyDB` (AceDB-3.0 managed)
- **Profile structure**: `StrategyDB.profiles[profileName]`
- **Key settings**:
  - `enabled` – Enable/disable addon (hides panel, disables keybinds)
  - `outputMode` – Where to send strategies (instance/party/say/whisper/self)
  - `roleFilter` – Which roles to show (all/tank/healer/dps/auto)
  - `autoShowStrategyPanel` – Auto-show panel on instance enter
  - `autoHideStrategyPanel` – Auto-hide panel on instance leave
  - `announcedStrategies` – Tracking for which strategies have been announced
  - `strategyPanel` – UI styling settings (width, height, colors, fonts, etc.)

## Slash Commands

| Command | Description |
|---------|-------------|
| `/ff` or `/ff help` | Show command list |
| `/ff settings` | Open settings panel |
| `/ff panel` | Toggle strategy panel |
| `/ff 1-10` | Announce strategy by keybind number (0 = 10) |
| `/ff diagnose` | Show diagnostic info |
| `/ff enable` | Enable addon |
| `/ff disable` | Disable addon (hides panel) |
| `/ff toggle` | Toggle addon on/off |
| `/ff reset` | Reset announced strategies |
| `/ff test` | Test random boss (for development) |

## Debugging

- `/ff diagnose` – Full diagnostic output (modules, instance, database status)
- Debug mode in settings enables verbose logging
- Never spam chat during normal operation

## API Compatibility Notes

All zone/instance detection uses Midnight-safe APIs:

```lua
local name, instanceType, difficultyID, difficultyName,
      maxPlayers, dynamicDifficulty, isDynamic, instanceID,
      instanceGroupSize, lfgDungeonID = GetInstanceInfo()
```

**Critical APIs:**

- `GetInstanceInfo()` – Returns instance details including instanceID
- `IsInInstance()` – Quick check if player is in an instance
- `SendChatMessage(msg, channel, language, target)` – Send to chat
- `C_ChallengeMode` – Mythic+ detection

**Avoided in v2.0 (Midnight restrictions):**

- `UnitName("mouseover")` – Not available in combat
- `UnitGUID("target")` – Not available in combat
- Automatic boss detection – Replaced with manual keybind system

## Future Considerations

- Additional TWW dungeons (currently only Operation: Floodgate)
- Raid strategy databases
- Per-boss difficulty variants (Normal/Heroic/Mythic)
- Mythic+ specific strategies (with affix awareness)
- Export/import custom strategies
- Combat logging integration (if Midnight APIs improve)
- Minimap button (currently slash-only)

## Documentation Requirements

**Always update documentation when making changes:**

### CHANGELOG.md
Update the changelog for any change that:
- Adds new features or functionality
- Fixes bugs or issues
- Changes existing behavior
- Modifies settings or configuration options
- Adds new dungeon/raid strategies

**Format** (Keep a Changelog style):
```markdown
## [Version] - YYYY-MM-DD
### Added
- New features or strategies

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features
```

### README.md
Update the README when:
- Adding new features that users should know about
- Changing slash commands or settings
- Adding support for new dungeons/raids
- Modifying installation or usage instructions

**Key sections to review**: Features, Slash Commands, Supported Content, Configuration

## Decisions Log

| Date | Decision |
|------|----------|
| 2025-12-11 | v2.0: Switch from mouseover/target to manual keybind-based announcements |
| 2025-12-11 | Use Ace3 framework for settings, database, events |
| 2025-12-11 | Store strategies in per-instance Lua files |
| 2025-12-11 | Use instanceID for reliable instance matching (not just name) |
| 2025-12-12 | Add comprehensive panel styling settings (30+ properties) |
| 2025-12-12 | Remove all legacy v1.x WindowManager code |
| 2025-12-13 | Remove outputFormat setting, hardcode to bullets format only |
| 2025-12-13 | Add showAnnounceButtons toggle for read-only mode |
| 2025-12-13 | Show actual boss names in dividers instead of "Boss 1" |
| 2025-12-13 | Add "self" and "whisper" output modes with proper handling |

## Library Management

This addon manages its libraries using `update_libs.ps1` located in `Interface\ADDON_DEV`.
**DO NOT** manually update libraries in `Libs`.
Instead, if you need to update libraries, run:
`powershell -File "c:\Program Files (x86)\World of Warcraft\_retail_\Interface\ADDON_DEV\update_libs.ps1"`
