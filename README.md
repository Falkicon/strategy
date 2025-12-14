# Strategy - M+ Strategy Assistant

**Version**: 2.0.0  
**Author**: Jason Falk  
**Expansion**: The War Within (Season 3)

## Overview

Strategy is a World of Warcraft addon designed to help tanks share encounter strategies with their group in Mythic+ dungeons. When you enter a supported instance, Strategy shows a panel with all strategic areas (bosses, big pulls, key mechanics). Click a button or press a keybind to announce the strategy to your group.

> **Midnight Compatibility**: Strategy 2.0 is designed for WoW 12.0+ (Midnight) API restrictions. It uses player-initiated button presses instead of target/mouseover auto-detection, ensuring full functionality in M+ and raids.

## Key Features

- **🏰 Instance Detection**: Automatically loads strategies when entering supported dungeons/raids
- **📋 Strategy Panel**: Visual list of all encounter strategies with click-to-announce buttons
- **⌨️ Keybinds**: Press 1-0 (or custom binds) to quickly announce strategies
- **🏗️ Role-Based Strategies**: Separate advice for Tank, DPS, Healer, and All roles
- **🚨 Priority Interrupts**: Highlighted interrupt callouts for critical abilities
- **⚡ Lazy Loading**: Only loads data for your current instance (85% memory reduction)
- **🔇 Anti-Spam**: Visual tracking of already-announced strategies
- **🎨 Visual Clarity**: Color-coded role headers and WoW-native formatting
- **🔧 Flexible Output**: Instance chat, party, whisper, window-only, or minimal modes
- **📍 Bazooka Integration**: LibDataBroker support for display addons
- **🖼️ Modern UI**: Clean strategy panel with collapsible groups and preview tooltips

## Installation

1. Extract to `World of Warcraft\_retail_\Interface\AddOns\`
2. Ensure folder is named exactly `Strategy` (no `!` prefix)
3. Restart WoW or `/reload`
4. Confirm loading with startup message

## Commands

### Basic Commands

- `/ff` or `/strategy` - Toggle strategy panel
- `/ff show` - Show strategy panel
- `/ff hide` - Hide strategy panel
- `/ff config` - Open settings GUI
- `/ff status` - Show current settings and loaded data
- `/ff list` - List available strategies for current instance
- `/ff reset` - Reset announced tracking (allows re-announcing)

### Quick Announce

- `/ff 1`, `/ff 2`, etc. - Announce specific strategy by number
- `/ff test` - Test output with sample strategy

### Output Modes

- `/ff tank` - Enable silent tank mode (whisper to self)
- `/ff say` - Switch to say mode (solo testing)
- `/ff instance` - Switch to instance chat mode

## Strategy Panel

The Strategy Panel is the main interface for Strategy 2.0:

- **📍 Instance-Aware**: Automatically shows when entering supported dungeons
- **📋 Ordered Strategies**: All strategic areas listed in logical progression order
- **🔘 Click to Announce**: Click any strategy button to output to group chat
- **⌨️ Keybind Support**: Press 1-0 to quickly announce strategies (configurable)
- **✓ Announced Tracking**: Strategies dim after announcing to prevent spam
- **📂 Collapsible Groups**: Organize by area ("Before Boss 1", "Boss 1", etc.)
- **👁️ Preview Tooltips**: Hover to see full strategy before announcing

### Panel Settings

- **Auto Show**: Automatically display panel when entering instances
- **Auto Hide**: Hide panel when leaving instances
- **Scale**: Global multiplier for panel size (default: 1.0)
- **Background Opacity**: Transparency level (default: 0.9)
- **Keybind Mode**: Focus, Modifier (Shift+#), or Always

## Supported Content

### Season 3 "The War Within" Mythic+ Dungeons

- **Operation: Floodgate** ✅ (5 bosses + 14 high-priority trash)
- **Halls of Atonement** ⏳ (planned)
- **Ara-Kara, City of Echoes** ⏳ (planned)
- **Eco-Dome Al'dani** ⏳ (planned)
- **Priory of the Sacred Flame** ⏳ (planned)
- **Tazavesh: Streets of Wonder** ⏳ (planned)
- **Tazavesh: So'leah's Gambit** ⏳ (planned)
- **The Dawnbreaker** ⏳ (planned)

## Technical Architecture

### Modular Database System

```
Database/
└── TWW/
    ├── Dungeon/
    │   ├── operation-floodgate.lua
    │   └── [other dungeons...]
    └── Raid/
        └── [future raid content]
```

### Performance Features

- **Lazy Loading**: Instance data loaded only when needed
- **Memory Efficient**: ~60KB vs ~500KB with old monolithic approach
- **Scalable**: New content has zero impact on startup performance
- **Zone Detection**: Automatic loading/unloading based on current zone

### Dependencies

- **Ace3 Framework**: AceAddon, AceConsole, AceEvent, AceDB, AceConfig
- **LibDataBroker-1.1**: For Bazooka/display addon integration
- **LibDBIcon-1.0**: Minimap icon support

## Settings

### General Settings

- **Enable/Disable**: Master toggle for addon functionality
- **Tank Role Only**: Restrict to tank specializations only
- **Include Trash Mobs**: Show trash pack strategies (not just bosses)
- **Minimap Icon**: Toggle minimap icon visibility

### Output Settings

- **Output Channel**: Instance, Party, Say, Whisper Target, Whisper Self
- **Output Format**: Bullets, Numbers, Single Line
- **Whisper Target**: Player name for whisper mode

### Role Settings

- **Role Filter**: Auto-detect, All roles, or specific role combinations
- **Active Role Preview**: Shows which roles will be displayed

### Keybind Settings

- **Use Number Keybinds**: Enable 1-0 for first 10 strategies
- **Modifier Key**: None, Shift, Ctrl, or Alt (for Modifier mode)
- **Custom Keybinds**: Assign custom keys to specific strategies

### Strategy Panel Settings

- **Enable Strategy Panel**: Master toggle for the panel
- **Auto Show in Instance**: Automatically display when entering instances
- **Auto Hide Outside Instance**: Hide when leaving instances
- **Scale**: Panel size multiplier
- **Background Opacity**: Transparency level
- **Show Announced Dimmed**: Dim strategies after announcing

## Strategy Format

### Example Output (Bullets Format)

```
>>> BIG M.O.M.M.A. STRATEGY <<<
[!] INTERRUPT: Artillery Barrage - interrupt or use cover
[T] TANK: Use major defensive cooldowns for heavy mechanical damage
[D] DPS: Focus boss during normal phases
[H] HEALER: Heavy tank damage - be ready with major heals
[A] ALL: Move away from overcharge blast zones
```

### Role Indicators

- `[T] TANK` - Blue - Tank-specific mechanics and cooldown usage
- `[D] DPS` - Red - Target priorities and damage optimization
- `[H] HEALER` - Green - Healing assignments and dispel priorities
- `[A] ALL` - Gold - Party-wide mechanics everyone needs to know
- `[!] INTERRUPT` - Orange - Critical interrupt callouts

### Trash Mob Format

Trash mobs use a concise, one-line format focused on key actions:

```
TRASH
Shreddinator 3000: Immune to CC, dodge sawblades, avoid rotating flame frontal
Mechadrone Sniper: Interrupt Trickshot. Pri Target.
```

## Development

### Contributing

See `Database/README.md` for guidelines on adding new encounter data.

### File Structure

- **Core/Core.lua** - Main addon logic and Ace3 integration
- **Core/StrategyPanel.lua** - Strategy panel UI component
- **Core/StrategyEngine.lua** - Strategy formatting and output
- **Core/InstanceDetector.lua** - Instance detection and data loading
- **Core/KeybindManager.lua** - Keybind registration and handling
- **Strategy.toc** - Addon manifest and metadata
- **embeds.xml** - Library dependency loading
- **Database/** - Modular encounter data (see Database/README.md)
- **Libs/** - Ace3 and other library dependencies

### Testing

- In-game: `/ff test` for current instance or `/ff test [boss name]` for specific encounters
- All strategies tested in Season 3 M+ environments
- Cross-reference with dungeon guides for accuracy

## Support

### Known Issues

- Requires WoW 11.2+ (Interface version 110200/110205)
- Ace3 libraries must be properly installed
- Instance detection may take a moment when zone changing

### Troubleshooting

1. **Addon not loading**: Check for `!` prefix in folder name (remove it)
2. **No strategies showing**: Ensure you're in a supported instance and panel is enabled
3. **Commands not working**: Verify Ace3 libraries are installed
4. **Performance issues**: Only one instance loads at a time (this is intended)
5. **Panel not appearing**: Check if Auto Show is enabled in settings, or use `/ff show`
6. **Keybinds not working**: Check Keybind Mode setting (Focus vs Modifier vs Always)

## License

This addon is provided as-is for World of Warcraft players. Feel free to modify for personal use.

---

**Built for tanks, by a tank. Good luck in your keys! 🛡️⚔️**
