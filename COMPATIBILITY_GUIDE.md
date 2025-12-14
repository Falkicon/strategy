# WoW API Compatibility Guide for Strategy

## Overview

World of Warcraft frequently changes its addon API between versions. This guide documents known compatibility issues and their solutions.

> **Strategy 2.0**: This addon has been redesigned for Midnight (WoW 12.0) API compatibility. See the "Midnight API Restrictions" section for details on why we moved from target/mouseover detection to button-based announcements.

## Midnight (12.0) API Restrictions ⚠️

### The Problem

WoW 12.0 (Midnight) introduces "secret values" - API returns that are opaque and cannot be used in certain contexts. This affects addons that need to identify units.

### Affected APIs

| API                     | Restriction              | Impact on Strategy                 |
| ----------------------- | ------------------------ | ---------------------------------- |
| `UnitName("target")`    | Returns secret in combat | ❌ Cannot auto-detect boss name    |
| `UnitName("mouseover")` | Returns secret in combat | ❌ Cannot auto-detect mouseover    |
| `UnitGUID("target")`    | Returns secret in combat | ❌ Cannot identify unit by GUID    |
| `C_UnitAuras.*`         | Protected in combat      | ❌ Cannot check unit buffs/debuffs |

### AddOnRestrictionType

Blizzard defines restriction contexts beyond just "combat":

```lua
enum AddOnRestrictionType {
    Combat,        -- In combat
    Encounter,     -- Boss encounter active
    ChallengeMode, -- In M+ dungeon (ANY time, not just combat!)
    PvPMatch,      -- In rated PvP
    Map            -- Certain restricted zones
}
```

**Critical**: `ChallengeMode` restriction applies in M+ even when **out of combat**. This means the traditional "check unit name between pulls" approach doesn't work in the content Strategy is designed for.

### Blizzard's Stated Intent

From the Midnight Beta Update (Nov 13, 2025):

> "Simplifying enemy names (e.g., 'Healer'), cast names ('Frontal'), or colorizing unit nameplates based on priority" is explicitly blocked.

The Strategy addon's original use case (identify mob → show strategy) falls directly into this category.

### Our Solution

Strategy 2.0 uses a **button-based architecture** that doesn't require unit identification:

1. **Instance Detection** via `GetInstanceInfo()` (always works)
2. **Strategy Panel** shows all strategies for the current instance
3. **Player Clicks Button** to announce strategy (no unit detection needed)
4. **Keybinds** for quick announcements (1-0)

This approach aligns with Blizzard's guidelines:

- ✅ No auto-detection of enemies
- ✅ Player decides what to announce
- ✅ Not "making decisions for the player"

### Detection Pattern for Secret Values

```lua
-- issecretvalue() is a global in Midnight (nil in earlier clients)
local function isSecretValue(value)
    return issecretvalue and issecretvalue(value)
end

-- Safe API call pattern
local function GetUnitNameSafe(unit)
    local name = UnitName(unit)
    if isSecretValue(name) then
        return nil  -- Return nil instead of unusable secret
    end
    return name
end
```

---

## Known API Changes

### Settings/Interface Options (Fixed ✅)

**Issue:** `InterfaceOptionsFrame_OpenToCategory` removed in WoW 10.0+

**Error:** `attempt to call global 'InterfaceOptionsFrame_OpenToCategory' (a nil value)`

**Solution:** Progressive fallback system

```lua
function addon:OpenSettings()
    -- Modern WoW (10.0+)
    if Settings and Settings.OpenToCategory then
        local categoryID = "Strategy"
        local settingsCategory = Settings.GetCategory(categoryID)
        if settingsCategory then
            Settings.OpenToCategory(settingsCategory.ID)
        else
            Settings.OpenToCategory(categoryID)
        end
    -- Legacy WoW
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory("Strategy")
        InterfaceOptionsFrame_OpenToCategory("Strategy") -- Blizzard bug workaround
    -- Final fallback
    else
        AceConfigDialog:Open("Strategy")
    end
end
```

## Testing Strategy

### 1. API Existence Checks

Always check if APIs exist before using them:

```lua
if SomeAPI and SomeAPI.Method then
    -- Safe to use
    SomeAPI.Method()
else
    -- Fallback or error handling
end
```

### 2. Version-Specific Testing

Test with multiple interface versions in TOC:

```toml
## Interface: 110200, 110205
```

### 3. Graceful Degradation

Provide fallbacks for when APIs are unavailable:

- Modern API → Legacy API → Ace3 Fallback → User notification

## Common API Changes by Version

### WoW 11.x (Current)

- `Settings.OpenToCategory()` - Settings management
- Enhanced combat `lockdown` restrictions
- Updated event signatures

### WoW 10.x (`Dragonflight`)

- Removed `InterfaceOptionsFrame_OpenToCategory`
- New Settings framework introduced
- Major UI/UX framework changes

### WoW 9.x (Shadowlands)

- `C_ChatInfo` API updates
- Instance/zone detection changes
- Specialization API updates

## Best Practices

### 1. Defensive Programming

```lua
-- Bad
InterfaceOptionsFrame_OpenToCategory("Addon")

-- Good
if InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory("Addon")
else
    -- Handle gracefully
end
```

### 2. Feature Detection

```lua
-- Check for specific features, not version numbers
local hasModernSettings = Settings and Settings.OpenToCategory
local hasLegacyInterface = InterfaceOptionsFrame_OpenToCategory

if hasModernSettings then
    -- Use modern approach
elseif hasLegacyInterface then
    -- Use legacy approach
else
    -- Use Ace3 or other fallback
end
```

### 3. Error Logging

```lua
local success, error = pcall(function()
    -- Potentially breaking API call
    RiskyAPICall()
end)

if not success then
    addon:LogError("RiskyAPICall", error)
    -- Fallback behavior
end
```

## Testing Checklist

### Pre-Release API Testing

- [ ] Test on current WoW patch
- [ ] Test with `/framestack` to check UI integration
- [ ] Verify no Lua errors in BugSack
- [ ] Test settings GUI opens correctly
- [ ] Verify all slash commands work

### Regression Testing

- [ ] No taint errors with protected functions
- [ ] Memory usage remains stable
- [ ] Event handlers respond correctly
- [ ] SavedVariables load/save properly

### Cross-Version Testing (if possible)

- [ ] Test on PTR (Public Test Realm)
- [ ] Test with older addon versions
- [ ] Verify backward compatibility

## Monitoring for Changes

### 1. WoW API Documentation

- Watch `Wowpedia` for API changes
- Monitor WoW developer social media
- Check PTR patch notes

### 2. Community Resources

- Check popular addon frameworks (Ace3, LibStub)
- Monitor addon development forums
- Follow other addon developers

### 3. Proactive Detection

- Implement API existence checks
- Add debug logging for API calls
- Monitor user error reports

## Emergency Fixes

If a major API break occurs:

1. **Immediate Response**

   - Add safety checks around broken API
   - Implement temporary fallback
   - Push hotfix update

2. **Long-term Solution**

   - Research new API approach
   - Update compatibility layer
   - Add regression tests
   - Document changes

3. **Communication**
   - Update README with known issues
   - Inform users of workarounds
   - Provide timeline for fixes

## Integration with Our QA Process

This compatibility guide integrates with our testing strategy:

1. **Static Analysis** (`luacheck`) - Catches undefined globals
2. **Unit Tests** - Verify compatibility layer functions work
3. **Manual Testing** - Verify in-game functionality
4. **Error Monitoring** - Debug system tracks API failures

By following these practices, Strategy can maintain compatibility across WoW version updates while providing a robust user experience.
