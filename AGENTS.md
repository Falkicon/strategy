# Strategy – Agent Documentation

Technical reference for AI agents modifying this addon.

For shared patterns, documentation requirements, and library management, see **[ADDON_DEV/AGENTS.md](../../ADDON_DEV/AGENTS.md)**.

---

## Project Intent

A dungeon/raid strategy addon for WoW that provides:

- Pre-written strategies for boss encounters and trash pulls
- Button-based strategy panel with keybind support (1-0 keys)
- Role-filtered strategy output (tank, healer, DPS, interrupt, all)
- Multiple output channels (instance chat, party, say, whisper, self)
- Per-instance strategy databases with group organization

---

## File Structure

| File | Purpose |
|------|---------|
| `Strategy.toc` | Manifest (library loading order) |
| `Core/Core.lua` | Main addon initialization |
| `Core/DefaultsManager.lua` | Settings UI and defaults |
| `Core/StrategyPanel.lua` | v2.0 button panel UI |
| `Core/StrategyEngine.lua` | Output formatting |
| `Core/DatabaseManager.lua` | Strategy data management |
| `Core/InstanceDetector.lua` | Zone/instance detection |
| `Core/KeybindManager.lua` | Keybind system (1-0) |
| `Database/StrategyDatabase.lua` | Database registry |
| `Database/TWW/Dungeon/*.lua` | Per-instance strategy files |

---

## Architecture

### Data Flow

1. InstanceDetector detects zone change → loads instance data
2. StrategyPanel displays strategies as clickable buttons
3. User clicks button or presses keybind (1-0)
4. StrategyPanel calls StrategyEngine to format output
5. Output sent to configured channel

### Strategy Data Format

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
                tank = { "Face away from group" },
                dps = { "Kill adds quickly" },
                healer = { "Tank takes heavy damage" },
                all = { "Move as a group" }
            }
        },
    }
}
```

**Group naming:** `"Before Boss N"`, `"Boss N"`, `"After Boss N"`

### Output Format

```
=== Big M.O.M.M.A. ===
[!] • Interrupt Hydraulic Blast
[T] • Face away from group
[D] • Kill adds quickly
[H] • Tank takes heavy damage
[A] • Move as a group
```

**Role tags:** `[!]` Interrupt, `[T]` Tank, `[D]` DPS, `[H]` Healer, `[A]` All

---

## SavedVariables

- **Root**: `StrategyDB` (AceDB-3.0 managed)
- **Key settings**:
  - `enabled` – Enable/disable addon
  - `outputMode` – Where to send strategies
  - `roleFilter` – Which roles to show
  - `autoShowStrategyPanel` – Auto-show on instance enter
  - `strategyPanel` – UI styling settings

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/ff` or `/ff help` | Show command list |
| `/ff settings` | Open settings panel |
| `/ff panel` | Toggle strategy panel |
| `/ff 1-10` | Announce strategy by keybind (0 = 10) |
| `/ff diagnose` | Show diagnostic info |

---

## API Notes

Uses Midnight-safe APIs only:

```lua
local name, instanceType, difficultyID, difficultyName,
      maxPlayers, dynamicDifficulty, isDynamic, instanceID,
      instanceGroupSize, lfgDungeonID = GetInstanceInfo()
```

**Avoided (Midnight restrictions):**
- `UnitName("mouseover")` – Not available in combat
- `UnitGUID("target")` – Not available in combat

---

## Decisions Log

| Date | Decision |
|------|----------|
| 2025-12-11 | v2.0: Switch to manual keybind-based announcements |
| 2025-12-11 | Use instanceID for reliable instance matching |
| 2025-12-13 | Add "self" and "whisper" output modes |
