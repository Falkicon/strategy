# Strategy - WoW Addon Specification

## Overview

Strategy is a World of Warcraft addon designed to assist tanks in Mythic+ dungeons by providing quick access to encounter strategies. The addon detects the current instance and presents a list of strategic areas (bosses, key trash packs, big pulls) that the tank can announce to the group with a button press or keybind.

> **Midnight Compatibility Note**: This addon is designed to work within Blizzard's Midnight (12.0) API restrictions. It uses **player-initiated actions** (button presses/keybinds) rather than auto-detection of target/mouseover units, ensuring full functionality in M+ and raids where `UnitName()` and related APIs return secret values.

## Design Philosophy

### What We CAN Do (Midnight-Safe)

- ✅ Detect current instance/dungeon/raid via `GetInstanceInfo()`
- ✅ Present a list of strategic areas for the player to choose from
- ✅ Output strategies to chat when player presses a button/keybind
- ✅ Remember which strategies have been announced per instance
- ✅ Provide keybinds for quick announcement (1-0 or custom)
- ✅ Auto-show/hide the strategy panel based on instance type

### What We CANNOT Do (Blocked by Midnight)

- ❌ Auto-detect target/mouseover mob name in combat
- ❌ Auto-announce strategies based on what tank is targeting
- ❌ Identify specific mobs by name in M+/raids during combat
- ❌ Modify behavior based on enemy cast names

## Core Features

### 1. Instance Detection & Strategy Panel

- **Auto-Detect Instance**: When player enters a supported dungeon/raid, show the strategy panel
- **Strategy List**: Display ordered list of strategic areas (not mobs, but encounter areas)
- **Visual Indicators**: Show which strategies have been announced (dimmed/checked)
- **Collapsible Groups**: Group strategies by area (e.g., "Before Boss 1", "Boss 1", "After Boss 1")

### 2. Player-Initiated Announcements

- **Button Click**: Click strategy button to announce to group
- **Keybinds**: Bind keys to announce specific strategies (1-10 or custom)
- **Quick-Announce Mode**: Hold modifier key to announce without confirmation
- **Preview Mode**: Hover to see strategy text before announcing

### 3. Strategy Organization (Per Instance)

```
┌─────────────────────────────────────────┐
│ Strategy: Operation Floodgate          │
├─────────────────────────────────────────┤
│ ▼ Big M.O.M.M.A. TRASH                   │
│   [1] Opening Pull Timing               │
│   [2] Weapon Stockpile Route            │
│ ▼ Big M.O.M.M.A. (Boss 1)              │
│   [3] Boss 1 Strategy                   │
│ ▼ Demolition Duo TRASH                  │
│   [4] Big Pull to Boss 2               │
│   [5] Skip Route Option                 │
│ ▼ Demolition Duo (Boss 2)              │
│   [6] Boss 2 Strategy                   │
│ ...                                     │
└─────────────────────────────────────────┘
```

### 4. Output System

- **Instance Chat**: Primary output to instance/party chat
- **Say Channel**: Option for local-only announcements
- **Whisper Mode**: Send to specific player (healer, etc.)
- **Window-Only Mode**: Display in addon window without chat spam

## Content Style Guide

To maintain a professional and objective tone, avoid assumptive language about outcomes (e.g., "or you die", "wipe mechanic"). Instead, use descriptive terms that convey the mechanic's nature and severity.

| Avoid (Assumptive/Fatalistic) | Use (Descriptive/Mechanical) |
| ----------------------------- | ---------------------------- |
| "Interrupt or wipe"           | "Must Interrupt"             |
| "Tank dies if missed"         | "Tankbuster"                 |
| "Instant death"               | "Lethal Damage"              |
| "One-shots group"             | "Heavy Group Damage"         |
| "Kill priority or wipe"       | "Priority Target"            |
| "Heal or tank dies"           | "Requires Heavy Healing"     |

## Technical Architecture

### Data Structure (Revised for Midnight)

```lua
StrategyDB = {
    -- Instance-based strategy organization (NOT mob-based)
    instances = {
        ["Operation: Floodgate"] = {
            instanceID = 2773,  -- For reliable detection
            expansion = "TWW",
            instanceType = "dungeon",

            -- Ordered list of strategic areas
            strategies = {
                {
                    id = "opening",
                    name = "Opening Pull",
                    group = "Big M.O.M.M.A. TRASH",
                    keybind = 1,
                    strategy = {
                        tank = {"Position at X for line-of-sight pull"},
                        all = {"Wait for tank to group mobs before AoE"}
                    }
                },
                {
                    id = "boss1",
                    name = "Big M.O.M.M.A.",
                    group = "Boss 1",
                    keybind = 2,
                    strategy = {
                        interrupt = {"Maximum Distortion - must interrupt"},
                        tank = {"Position around Mechadrones"},
                        dps = {"Kill Mechadrones quickly"},
                        healer = {"Major CDs during Jumpstart"},
                        all = {"Dodge Sonic Boom"}
                    }
                },
                -- ... more strategies
            },

            -- Tracking (reset on instance change)
            announced = {}  -- Set of strategy IDs already announced
        }
    },

    settings = {
        enabled = true,
        showPanel = true,
        panelPosition = {point = "RIGHT", x = -50, y = 0},
        autoShowInInstance = true,
        autoHideOutOfInstance = true,

        -- Output settings
        outputMode = "instance",  -- "instance", "party", "say", "whisper", "window"
        whisperTarget = "",
        outputFormat = "bullets",  -- "bullets", "numbers", "compact"
        roleFilter = "all",        -- "all", "tank", "auto"

        -- Keybind settings
        useNumberKeybinds = true,  -- 1-0 for first 10 strategies
        modifierKey = "none",      -- "none", "shift", "ctrl", "alt"

        -- Visual settings
        panelScale = 1.0,
        panelAlpha = 0.9,
        showAnnouncedDimmed = true,

        -- Audio
        audioOnAnnounce = true,

        -- Debug
        debugMode = false
    }
}
```

### WoW API Usage (Midnight-Safe)

| API                                       | Purpose                  | Midnight Status |
| ----------------------------------------- | ------------------------ | --------------- |
| `GetInstanceInfo()`                       | Detect current instance  | ✅ Safe         |
| `IsInInstance()`                          | Check if in dungeon/raid | ✅ Safe         |
| `GetZoneText()`                           | Backup zone detection    | ✅ Safe         |
| `C_ChallengeMode.GetActiveKeystoneInfo()` | Get M+ level             | ✅ Safe         |
| `SendChatMessage()`                       | Output strategies        | ✅ Safe         |
| `IsInGroup()`, `IsInRaid()`               | Check group state        | ✅ Safe         |
| `GetSpecializationRole()`                 | Check player role        | ✅ Safe         |
| `CreateFrame()`                           | UI creation              | ✅ Safe         |
| `SetBinding*()`                           | Keybind management       | ✅ Safe         |

### APIs NOT Used (Blocked/Restricted)

| API                     | Old Purpose           | Why Removed            |
| ----------------------- | --------------------- | ---------------------- |
| `UnitName("target")`    | Auto-detect boss      | ❌ Secret in combat    |
| `UnitName("mouseover")` | Auto-detect mouseover | ❌ Secret in combat    |
| `UnitGUID()`            | Unit identification   | ❌ Secret in combat    |
| `C_UnitAuras.*`         | Aura detection        | ❌ Protected in combat |

## User Interface

### Strategy Panel (Main UI)

```
┌──────────────────────────────────────────────┐
│ ⚔️ Strategy: Operation Floodgate    [−][×] │
├──────────────────────────────────────────────┤
│                                              │
│ 📍 FIRST AREA                               │
│ ┌──────────────────────────────────────────┐│
│ │ [1] Opening Pull          [Announce]    ││
│ │ [2] Stockpile Route       [Announce]    ││
│ └──────────────────────────────────────────┘│
│                                              │
│ 👹 BIG M.O.M.M.A. (BOSS 1)                  │
│ ┌──────────────────────────────────────────┐│
│ │ [3] Boss Strategy    ✓ Announced        ││
│ └──────────────────────────────────────────┘│
│                                              │
│ 📍 AFTER BOSS 1                             │
│ ┌──────────────────────────────────────────┐│
│ │ [4] Big Pull Route        [Announce]    ││
│ │ [5] Skip Option           [Announce]    ││
│ └──────────────────────────────────────────┘│
│                                              │
│ [Reset All] [Settings]      Tank Mode: ✓   │
└──────────────────────────────────────────────┘
```

### Strategy Preview (Tooltip on Hover)

```
┌─────────────────────────────────────────────┐
│ Big M.O.M.M.A. Strategy                     │
├─────────────────────────────────────────────┤
│ [!] INTERRUPT:                              │
│   • Maximum Distortion - must interrupt     │
│                                              │
│ [T] TANK:                                   │
│   • Position around Mechadrones             │
│                                              │
│ [D] DPS:                                    │
│   • Kill Mechadrones quickly                │
│                                              │
│ [H] HEALER:                                 │
│   • Major CDs during Jumpstart              │
│                                              │
│ [A] ALL:                                    │
│   • Dodge Sonic Boom                        │
├─────────────────────────────────────────────┤
│ Press [3] or click [Announce] to send       │
└─────────────────────────────────────────────┘
```

## Keybind System

### Default Keybinds

- `1-9, 0`: Announce strategies 1-10 (when panel focused or modifier held)
- `Shift+1-0`: Always announce (regardless of focus)
- `/ff 1`, `/ff 2`, etc.: Slash command announcement

### Keybind Modes

1. **Focus Mode**: Keybinds only work when strategy panel has focus
2. **Modifier Mode**: Hold Shift/Ctrl/Alt + number to announce
3. **Always Mode**: Number keys always announce (may conflict with action bars)

## Slash Commands

```
/ff                    - Toggle strategy panel
/ff show              - Show strategy panel
/ff hide              - Hide strategy panel
/ff settings          - Open settings
/ff 1, /ff 2, etc.    - Announce specific strategy
/ff reset             - Reset announced tracking
/ff list              - List available strategies for current instance
/ff test              - Test output with sample strategy
```

## Implementation Phases

### Phase 1: Core Midnight-Compatible MVP 🎯

**Goal**: Working instance-based strategy panel with button announcements

**Tasks**:

1. [ ] Refactor data structure from mob-based to area-based strategies
2. [ ] Create new StrategyPanel UI component
3. [ ] Implement instance detection and auto-show/hide
4. [ ] Build strategy button grid with click-to-announce
5. [ ] Add announcement tracking (dimmed when announced)
6. [ ] Convert existing dungeon data to new format
7. [ ] Remove all `UnitName()`/`UnitGUID()` dependencies
8. [ ] Test in M+ environment on Midnight beta

**Files to Modify**:

- `Core/Core.lua` - Remove target/mouseover detection
- `Core/Events.lua` - Remove `UPDATE_MOUSEOVER_UNIT`, `PLAYER_TARGET_CHANGED`
- `Core/StrategyEngine.lua` - Refactor for button-based output
- `Database/TWW/Dungeon/*.lua` - Convert to area-based format
- **NEW**: `Core/StrategyPanel.lua` - Main UI panel

### Phase 2: Keybind System

**Goal**: Quick announcements via keyboard

**Tasks**:

1. [ ] Implement keybind registration system
2. [ ] Add modifier key support (Shift+1, etc.)
3. [ ] Create keybind configuration UI
4. [ ] Add visual keybind indicators on buttons
5. [ ] Support custom keybind assignments

### Phase 3: Enhanced UX

**Goal**: Polish and quality-of-life features

**Tasks**:

1. [ ] Strategy preview tooltips on hover
2. [ ] Collapsible strategy groups
3. [ ] Drag-to-reorder strategies
4. [ ] Audio feedback on announcement
5. [ ] Minimap button
6. [ ] Import/Export strategy configurations

### Phase 4: Advanced Features

**Goal**: Power user features

**Tasks**:

1. [ ] Keystone level-aware strategies (15+ vs 20+)
3. [x] Role-specific filtering
    - **Filter Logic**:
        - **All Roles**: Show everything.
        - **Auto**: Filter based on player's current spec role.
    - **Visibility Rules**:
        - **Everyone**: See `[A] ALL` items.
        - **Tank**: See `[T] TANK`, `[!] INTERRUPT`.
        - **DPS**: See `[D] DPS`, `[!] INTERRUPT`.
        - **Healer**: See `[H] HEALER`, `[D] DISPEL`.
    - **Visibility Overrides** (New Settings):
        - `[x] Always Show Interrupts`: Helper for Healers/Tanks who can interrupt.
        - `[x] Always Show Dispels`: Helper for DPS who can dispel.
3. [ ] Custom strategy creation UI
4. [ ] Strategy templates for common patterns
5. [ ] Guild sharing of custom strategies

## Migration Guide (From Old Architecture)

### What Changes for Users

- **Before**: Auto-announce on target/mouseover
- **After**: Click button or press keybind to announce

### Data Migration

The existing encounter database will be restructured:

**Before (mob-based)**:

```lua
["Big M.O.M.M.A."] = {
    zones = {"Operation: Floodgate"},
    mobType = "boss",
    tank = {...},
    dps = {...}
}
```

**After (area-based)**:

```lua
{
    id = "boss1_momma",
    name = "Big M.O.M.M.A.",
    group = "Boss 1",
    keybind = 3,
    strategy = {
        tank = {...},
        dps = {...}
    }
}
```

## Technical Considerations

### Performance

- Lazy-load strategy data per instance (don't load all dungeons at startup)
- Minimal memory footprint for the strategy panel
- No per-frame updates needed (event-driven only)

### Reliability

- Instance detection has multiple fallbacks (`GetInstanceInfo()` → `GetZoneText()`)
- Graceful handling if instance not in database
- SavedVariables versioning for future migrations

### Compatibility

- Works on Retail 11.x (current) and 12.x (Midnight)
- No dependencies on restricted APIs
- Safe for M+, raids, and all instanced content

## Success Metrics

1. **Zero API errors** in Midnight M+ environment
2. **< 3 seconds** to announce a strategy via keybind
3. **100% instance detection** accuracy for supported dungeons
4. **No duplicate announcements** per instance run
5. **Positive tank feedback** on usability vs. old auto-detect model

## Files to Create/Modify

| File                         | Action | Purpose                             |
| ---------------------------- | ------ | ----------------------------------- |
| `Core/StrategyPanel.lua`     | CREATE | Main strategy panel UI              |
| `Core/KeybindManager.lua`    | CREATE | Keybind registration and handling   |
| `Core/InstanceDetector.lua`  | CREATE | Instance detection and data loading |
| `Core/Core.lua`              | MODIFY | Remove target/mouseover logic       |
| `Core/Events.lua`            | MODIFY | Remove deprecated event handlers    |
| `Core/StrategyEngine.lua`    | MODIFY | Refactor for button-based output    |
| `Database/TWW/Dungeon/*.lua` | MODIFY | Convert to area-based format        |
| `Core/DatabaseManager.lua`   | MODIFY | Support new data structure          |

## Appendix: Why This Approach Works

From Blizzard's Midnight Beta Update (Nov 13, 2025):

> "Simplifying enemy names (e.g., 'Healer'), cast names ('Frontal'), or colorizing unit nameplates based on priority" is explicitly blocked.

However, they also state:

> "We have no issue with addons customizing how combat information we show in our UI is presented to players (whether for accessibility or personal preference reasons)"

Our approach:

1. **No auto-detection** of enemies → Player chooses what to announce
2. **Static data lookup** by instance → Not processing combat information
3. **Player-initiated output** → Not "making decisions for the player"

This aligns with Blizzard's stated goals while still providing value to tanks.
