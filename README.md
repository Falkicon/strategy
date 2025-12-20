# Strategy

A World of Warcraft addon designed to help tanks and party leaders share concise, actionable encounter strategies in Mythic+ dungeons and raids.

![WoW Version](https://img.shields.io/badge/WoW-11.0%2B-blue)
![Interface](https://img.shields.io/badge/Interface-120001-green)
[![GitHub](https://img.shields.io/badge/GitHub-Falkicon%2FStrategy-181717?logo=github)](https://github.com/Falkicon/Strategy)
[![Sponsor](https://img.shields.io/badge/Sponsor-pink?logo=githubsponsors)](https://github.com/sponsors/Falkicon)

> **Alpha Release**: This project is currently in early alpha. Features and database content are subject to change.

## Overview

Instead of relying on complex auto-detection or target scanning, Strategy provides a clean **Strategy Panel** that automatically appears when you enter a supported instance. The panel lists every boss and critical trash pack in progression order.

Simply **click a button** to announce the strategy to your group.

## Features

- **🏰 Automatic Detection** – Instantly loads the correct strategies when you enter a supported dungeon
- **📋 Strategy Panel** – A visual list of all encounters in the instance
- **⚡ One-Click Announce** – Click any button to output the strategy to chat
- **🛡️ Role-Specific Advice** – Strategies align `[TANK]`, `[HEAL]`, `[DPS]`, `[INT]`, and `[DISP]` notes
- **🎨 Modern UI** – Clean, dark-themed interface with a detailed side panel
- **🚫 Spam Prevention** – Strategies are announced button-by-button, with full control over what is sent
- **⌨️ Keybind Support** – Quick announcements via 1-0 keys

## Installation

1. Download or clone this repository
2. Place the `Strategy` folder in your WoW addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Restart WoW or type `/reload` if already running

## Getting Started

1. **Enter a Dungeon** – The Strategy Panel will appear automatically
2. **Select** – Click a boss or trash pack to open the **Detail Panel**
3. **Review** – Read the strategy yourself in the side panel
4. **Announce** – Click the "Announce" button to send it to chat
5. **Settings** – Type `/ff settings` to configure output channels, panel size, and more

## Slash Commands

| Command | Description |
|---------|-------------|
| `/ff` or `/ff help` | Show command list |
| `/ff settings` | Open the configuration menu |
| `/ff panel` | Toggle the Strategy Panel |
| `/ff 1-10` | Announce strategy by keybind number (0 = 10) |
| `/ff diagnose` | Show diagnostic info |
| `/ff enable` | Enable addon |
| `/ff disable` | Disable addon (hides panel) |
| `/ff toggle` | Toggle addon on/off |
| `/ff reset` | Reset the "announced" status of all buttons |

## Supported Content

- **The War Within** – Full support for Season 3 Dungeons
- **Midnight** – Forward-compatible architecture ready for 12.0

## Configuration

Open settings via `/ff settings` or `Esc` → `Options` → `AddOns` → `Strategy`.

### Settings Sections

- **General** – Enable Strategy, Output Channel, Whisper Target
- **Role Settings** – Role Filter, Tank Role Only Mode
- **Strategy Panel** – Dimensions, spacing, font size, opacity, auto show/hide
- **Profiles** – Standard AceDB profile management

| Setting | Description |
|---------|-------------|
| Output Channel | Choose between Instance, Party, Say, Whisper, or Self (for testing) |
| Role Filter | Show strategies for All, Tank, Healer, DPS, or Auto (based on spec) |
| Panel Width | Adjust panel width (150-400px) |
| Background Opacity | Visibility of panel background (0-100%) |

## Requirements

- World of Warcraft Retail 11.0+ or Midnight Beta
- Supported dungeon or raid instance

## Files

| File | Purpose |
|------|---------|
| `Strategy.toc` | Addon manifest |
| `Core/Core.lua` | Main addon initialization |
| `Core/StrategyPanel.lua` | Button panel UI |
| `Core/StrategyEngine.lua` | Output formatting |
| `Core/DatabaseManager.lua` | Strategy data management |
| `Core/InstanceDetector.lua` | Zone/instance detection |
| `Database/TWW/Dungeon/*.lua` | Per-instance strategy files |

## Technical Notes

- **Ace3 Framework** – Uses AceAddon, AceDB, AceConfig, AceEvent for robust infrastructure
- **Event-Driven** – Reacts to zone changes and instance detection events
- **Lazy Loading** – Instance data loaded only when needed
- **Midnight-Safe** – Avoids combat-restricted APIs (no mouseover/target detection)

## Contributing

We welcome contributions! If you want to add strategies for a new dungeon:

1. Look at `Database/TWW/Dungeon/operation-floodgate.lua` as a template
2. Follow the concise writing style guide in `Database/README.md`
3. Submit a Pull Request

## Support

If you find Strategy useful, consider [sponsoring on GitHub](https://github.com/sponsors/Falkicon) to support continued development and new addons. Every contribution helps!

## License

GPL-3.0 License – see [LICENSE](LICENSE) for details.
