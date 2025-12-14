# Strategy – Agent Notes

## Project intent

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
**Current Architecture:**

- Strategy Panel with clickable strategy buttons
- Keybind support (1-0 keys) for quick announcements
- Boss name dividers (shows actual boss names from strategy data)
- Read-only mode (toggle announce buttons on/off)
- Announced state tracking with visual feedback
- Settings panel with comprehensive styling controls
- Enable/disable toggle that properly shows/hides panel
- Output modes: instance, party, say, whisper, self
- Role filtering: all, tank, healer, DPS, auto (based on spec)

## Strategy addon conventions

### Architecture

**Module structure:**

- `Core.lua` – Main addon initialization, slash commands
- `DefaultsManager.lua` – Profile defaults and settings UI
- `StrategyPanel.lua` – Button-based strategy panel UI
- `StrategyEngine.lua` – Output formatting (role headers, bullets)
- `DatabaseManager.lua` – Strategy data loading and management
- `InstanceDetector.lua` – Zone detection and instance data lookup
- `KeybindManager.lua` – Keybind registration (1-0 keys)

**Data flow:**

1. InstanceDetector detects zone change → loads instance data
2. StrategyPanel displays strategies as clickable buttons
3. User clicks button or presses keybind (1-0)
4. StrategyPanel calls StrategyEngine to format output
5. Output sent to configured channel (instance/party/say/whisper/self)

### SavedVariables

- Root: `StrategyDB` (AceDB-3.0 managed)
- Profile structure: `StrategyDB.profiles[profileName]`
- Key settings:
  - `enabled` – Enable/disable addon (hides panel, disables keybinds)
  - `outputMode` – Where to send strategies (instance/party/say/whisper/self)
  - `roleFilter` – Which roles to show (all/tank/healer/dps/auto)
  - `autoShowStrategyPanel` – Auto-show panel on instance enter
  - `autoHideStrategyPanel` – Auto-hide panel on instance leave
  - `announcedStrategies` – Tracking for which strategies have been announced
  - `strategyPanel` – UI styling settings (width, height, colors, fonts, etc.)

### Strategy data format

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
                interrupt = {
                    "Interrupt Hydraulic Blast",
                },
                tank = {
                    "Face away from group during Hydraulic Blast",
                    "Move out of Pneumatic Burst zones",
                },
                dps = {
                    "Kill adds quickly",
                    "Avoid standing in front of boss",
                },
                healer = {
                    "Tank takes heavy damage during Hydraulic Blast",
                    "Dispel Pneumatic Burst debuffs",
                },
                all = {
                    "Move as a group during Pneumatic Burst",
                }
            }
        },
        -- ... more strategies
    }
}
```

**Group naming conventions:**

- `"Before Boss N"` – Trash pulls before boss
- `"Boss N"` – Boss encounter (divider shows boss name from strategy.name)
- `"After Boss N"` – Trash pulls after boss
- Groups appear in order with dividers between them

### Output format

Strategies are output with role tags and bullet points:

```
=== Big M.O.M.M.A. ===
[!] • Interrupt Hydraulic Blast
[T] • Face away from group during Hydraulic Blast
[T] • Move out of Pneumatic Burst zones
[D] • Kill adds quickly
[D] • Avoid standing in front of boss
[H] • Tank takes heavy damage during Hydraulic Blast
[H] • Dispel Pneumatic Burst debuffs
[A] • Move as a group during Pneumatic Burst
```

**Role tags:**

- `[!]` – Interrupt (always shown)
- `[T]` – Tank
- `[D]` – DPS
- `[H]` – Healer
- `[A]` – All roles

### Visibility and enabled state

**Panel visibility logic:**

1. Addon must be `enabled = true`
2. Must be in a supported instance (dungeon/raid)
3. Instance data must exist in database
4. Auto-show respects `autoShowStrategyPanel` setting

**Enabled checks prevent:**

- Panel from auto-showing on instance enter
- Manual `/ff panel` from showing panel
- Keybinds from working
- Strategy announcements via clicks

**When disabled:**

- Panel hides immediately
- Keybinds are unregistered
- Settings UI checkbox triggers hide/show

### Performance patterns

- Event-driven: `ZONE_CHANGED_NEW_AREA`, `PLAYER_ENTERING_WORLD`
- Lazy loading: Instance data loaded only when needed
- Announced state cached in SavedVariables
- Settings changes trigger live updates via `ApplySettings()`

### Debugging expectations

- `/ff diagnose` – Full diagnostic output (modules, instance, database status)
- `/ff status` – (Not yet implemented, could be added)
- Debug mode in settings enables verbose logging
- Never spam chat during normal operation

## Decisions log

| Date       | Decision                                                                 |
| ---------- | ------------------------------------------------------------------------ |
| 2025-12-11 | v2.0: Switch from mouseover/target to manual keybind-based announcements |
| 2025-12-11 | Use Ace3 framework for settings, database, events                        |
| 2025-12-11 | Store strategies in per-instance Lua files                               |
| 2025-12-11 | Use instanceID for reliable instance matching (not just name)            |
| 2025-12-12 | Add comprehensive panel styling settings (30+ properties)                |
| 2025-12-12 | Remove all legacy v1.x WindowManager code                                |
| 2025-12-13 | Remove outputFormat setting, hardcode to bullets format only             |
| 2025-12-13 | Add showAnnounceButtons toggle for read-only mode                        |
| 2025-12-13 | Show actual boss names in dividers instead of "Boss 1"                   |
| 2025-12-13 | Fix enabled checkbox to properly hide/show panel                         |
| 2025-12-13 | Add "self" and "whisper" output modes with proper handling               |

## API compatibility notes

All zone/instance detection uses Midnight-safe APIs:

```lua
-- Midnight-safe instance detection
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetZoneText = GetZoneText

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

- `UnitName("mouseover")` – Not available in combat (Midnight)
- `UnitGUID("target")` – Not available in combat (Midnight)
- Automatic boss detection – Replaced with manual keybind system

## File structure

| File                            | Purpose                          | Lines  |
| ------------------------------- | -------------------------------- | ------ |
| `Strategy.toc`                  | Manifest (library loading order) | ~60    |
| `Core/Core.lua`                 | Main addon initialization        | ~514   |
| `Core/DefaultsManager.lua`      | Settings UI and defaults         | ~668   |
| `Core/StrategyPanel.lua`        | v2.0 button panel UI             | ~915   |
| `Core/StrategyEngine.lua`       | Output formatting                | ~404   |
| `Core/DatabaseManager.lua`      | Strategy data management         | ~380   |
| `Core/InstanceDetector.lua`     | Zone/instance detection          | ~307   |
| `Core/KeybindManager.lua`       | Keybind system (1-0)             | ~255   |
| `Database/StrategyDatabase.lua` | Database registry                | ~50    |
| `Database/TWW/Dungeon/*.lua`    | Per-instance strategy files      | varies |

## Settings organization

**General Settings:**

- Enable Strategy (checkbox with hide/show logic)
- Output Channel (instance/party/say/whisper/self)
- Whisper Target (text field, enabled only when whisper mode selected)

**Role Settings:**

- Role Filter (all/tank/healer/dps/auto)
- Tank Role Only Mode (checkbox to restrict usage to tanks)

**Combat Settings:**

- Allow Combat Output (checkbox)

**Content Settings:**

- Debug Mode (checkbox)
- Zone Display (dropdown)

**Strategy Panel:**

- Dimensions: Width, Min/Max Height
- Spacing: Padding, Button Spacing
- Font Size
- Background Opacity
- Show Group Names (checkbox)
- Show Dividers (checkbox)
- Show Announce Buttons (checkbox – toggles read-only mode)
- Auto Show/Hide Panel (checkboxes)
- Reset Announced Strategies (button)

**Profiles:**

- Standard AceDB profile management
- Copy/Delete/New profile

**Testing & Debug:**

- Test Random Boss (button)
- Debug Mode (checkbox)

## Slash commands

- `/ff` or `/ff help` – Show command list
- `/ff settings` – Open settings panel
- `/ff panel` – Toggle strategy panel
- `/ff 1-10` – Announce strategy by keybind number (0 = 10)
- `/ff diagnose` – Show diagnostic info
- `/ff enable` – Enable addon
- `/ff disable` – Disable addon (hides panel)
- `/ff toggle` – Toggle addon on/off
- `/ff reset` – Reset announced strategies
- `/ff test` – Test random boss (for development)

## Future considerations

- Additional TWW dungeons (currently only Operation: Floodgate)
- Raid strategy databases
- Per-boss difficulty variants (Normal/Heroic/Mythic)
- Mythic+ specific strategies (with affix awareness)
- Export/import custom strategies
- Combat logging integration (if Midnight APIs improve)
- Minimap button (currently slash-only)
- `/ff status` command for quick health check
