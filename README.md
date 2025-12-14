# Strategy

**Version:** 0.1.0-alpha  
**Author:** Jason Falk  
**License:** MIT

> **Alpha Release**: This project is currently in early alpha. Features and database content are subject to change.

## Overview

**Strategy** is a World of Warcraft addon designed to help tanks and party leaders share concise, actionable encounter strategies in Mythic+ dungeons.

Instead of relying on complex auto-detection or target scanning, Strategy provides a clean **Strategy Panel** that automatically appears when you enter a supported instance. The panel lists every boss and critical trash pack in progression order.

Simply **click a button** to announce the strategy to your group.

## Features

- **🏰 Automatic Detection**: Instantly loads the correct strategies when you enter a supported dungeon.
- **📋 Strategy Panel**: A visual list of all encounters in the instance.
- **⚡ One-Click Announce**: Click any button to output the strategy to chat.
- **🛡️ Role-Specific Advice**: Strategies align `[T] Tank`, `[H] Healer`, `[D] DPS`, and `[!] Interrupt` notes.
- **⌨️ Keybind Support**: Press `1-0` to announce strategies without clicking.
- **🎨 Modern UI**: Clean, dark-themed interface that fits modern WoW aesthetics.
- **🚫 Spam Prevention**: Buttons dim after use to help you track what you've announced.

## Installation

1. Download the latest release.
2. Extract the `Strategy` folder to your WoW AddOns directory:
   `World of Warcraft\_retail_\Interface\AddOns\`
3. Restart WoW.

## getting Started

1. **Enter a Dungeon**: The Strategy Panel will appear automatically.
2. **Review**: Hover over any button to see the full strategy tooltip.
3. **Announce**: Click the button (or use keybinds `1-9`) to send the strategy to instance chat.
4. **Settings**: Type `/strat settings` to configure output channels, panel size, and more.

## Commands

- `/strat` or `/strategy` - Toggle the Strategy Panel.
- `/strat settings` - Open the configuration menu.
- `/strat reset` - Reset the "announced" status of all buttons.
- `/strat help` - Show all available commands.

## Supported Content (TWW Season 1)

- **Operation: Floodgate**
- *(More dungeons coming soon)*

## Configuration

You can customize almost every aspect of the addon via `/strat settings`:

- **Output Channel**: Choose between Instance, Party, Say, Whisper, or Self (for testing).
- **Styling**: Adjust panel width, font sizes, opacity, and colors.
- **Behavior**: Toggle auto-show/hide, trash mob inclusion, and keybinds.

## Contributing

We welcome contributions! If you want to add strategies for a new dungeon:

1. Look at `Database/TWW/Dungeon/operation-floodgate.lua` as a template.
2. Follow the concise writing style guide in `Database/README.md`.
3. Submit a Pull Request.
