# Contributing to Strategy

Thanks for your interest in contributing! This addon is a Mythic+ strategy tool for World of Warcraft, and we welcome bug reports, feature suggestions, and new strategy contributions.

## Getting Started

1. **Fork and clone** the repository
2. **Place the addon** in your WoW addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\Strategy\
   ```
3. **Test in-game** with `/reload` after making changes

## Development Guidelines

### Read the Docs First

- [AGENTS.md](AGENTS.md) – Project intent, conventions, and decisions log
- [SPEC.md](spec.md) – Technical specification and architecture
- [ADDON_DEVELOPMENT_GUIDE](file:///c:/Program%20Files%20%28x86%29/World%20of%20Warcraft/_retail_/Interface/ADDON_DEV/ADDON_DEVELOPMENT_GUIDE.md) – Shared WoW addon best practices

### Code Style

- **Lua 5.1** syntax (WoW's embedded Lua version)
- **Local variables** – Prefer `local` for performance and scope control
- **Role Constants** – Use `[TANK]`, `[HEAL]`, `[DPS]`, `[INT]`, `[DISP]` tags

### Midnight Compatibility

The addon targets Interface 120000 (Midnight beta). When adding features:

- Assume APIs may be restricted in combat
- Fail gracefully – detailed strategies should simply not show if data is missing

## Submitting Changes

### Bug Reports

Open an issue with:

- WoW version and client (Retail/Beta)
- Steps to reproduce
- Output from `/strat debug` if relevant
- Any Lua errors from BugSack/BugGrabber

### New Strategies

We love new dungeon strategies!
1. Check `Database/README.md` for style guide.
2. Use existing files (e.g. `Database/TWW/Dungeon/operation-floodgate.lua`) as a template.
3. Keep text concise and button-friendly.

### Pull Requests

1. **Create a branch** from `main`
2. **Keep changes focused** – one feature or fix per PR
3. **Test in-game**
4. **Update docs** if adding settings or slash commands
5. **Describe your changes** in the PR description

## File Structure

| File | Purpose |
| --- | --- |
| `Strategy.toc` | Addon manifest |
| `Core/` | Main engine and UI logic |
| `Database/` | Strategy data files |
| `AGENTS.md` | Development log |

## Testing Checklist

Before submitting:

- [ ] Addon loads without errors (`/reload`)
- [ ] Panel appears when entering instance
- [ ] Panel hides when leaving
- [ ] Settings persist across sessions
- [ ] `/strat status` shows correct info
- [ ] No Lua errors

## Questions?

Open an issue or check the existing documentation. Thanks for helping make Strategy better!
