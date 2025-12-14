# Plater Addon Conflict Resolution

## Problem

Strategy was causing conflicts with the Plater nameplate addon. When both were loaded, Plater would stop functioning properly.

## Root Causes Identified

### 1. **LibStub Version Conflicts**

- Both addons embed their own copies of LibStub and Ace3 libraries
- Multiple library registrations can cause conflicts
- Different library versions may overwrite each other

### 2. **Global Namespace Pollution**

- Strategy was assigning `_G["Strategy"]` in multiple places
- Multiple global assignments can interfere with other addon loading

### 3. **Library Loading Order Issues**

- No explicit load order dependency declared
- Libraries might be loaded in conflicting order

## Fixes Implemented

### 1. **Defensive Library Loading**

```lua
-- OLD (aggressive loading)
local AceAddon = LibStub("AceAddon-3.0")

-- NEW (defensive loading with conflict detection)
local AceAddon = LibStub("AceAddon-3.0", true)
if not AceAddon then
    error("Strategy: AceAddon-3.0 library not found. Library conflict detected.")
end
```

### 2. **Clean Global Namespace Management**

```lua
-- OLD (multiple assignments)
_G["Strategy"] = Strategy  -- Line 19
-- ... later ...
_G["Strategy"] = Strategy  -- Line 460

-- NEW (single defensive assignment)
if not _G["Strategy"] then
    _G["Strategy"] = Strategy
else
    -- Merge carefully if another addon created this global
    for k, v in pairs(Strategy) do
        if not _G["Strategy"][k] then
            _G["Strategy"][k] = v
        end
    end
end
```

### 3. **TOC File Improvements**

```toml
## OptionalDeps: Plater
## LoadOnDemand: 0
## X-Conflict-Check: 1
```

### 4. **Conflict Detection System**

- Added `ConflictCheck.lua` module
- Automatic detection of Plater conflicts
- Diagnostic reporting via `/ff diagnose`
- Error reporting with helpful messages

## Testing Steps

### 1. Enable Both Addons

```console
/console reloadui
```

### 2. Run Diagnostics

```console
/ff diagnose
```

Look for:

- `Plater addon = LOADED (potential conflict source)`
- `Conflicts detected = 0`
- `AceGUI-3.0 available = true`

### 3. Test Plater Functionality

- Check nameplate display
- Test Plater settings UI
- Verify no Lua errors in BugSack

### 4. Test Strategy Functionality

```console
/ff test
/ff window
/ff settings
```

## Expected Results After Fixes

- ✅ Plater loads and functions normally
- ✅ Strategy loads and functions normally
- ✅ No LibStub or Ace3 library conflicts
- ✅ No global namespace pollution
- ✅ Conflict detection reports "0 conflicts"
- ✅ Both addons coexist peacefully

## Prevention Measures

1. **Always use defensive library loading** with `LibStub("Library", true)`
2. **Minimize global variable assignments** and use defensive patterns
3. **Declare addon dependencies** in TOC files where appropriate
4. **Include conflict detection** in addon initialization
5. **Test with popular addons** like Plater, WeakAuras, ElvUI

## If Problems Persist

1. Check load order: Plater should load before or after Strategy (either works)
2. Temporarily disable other addons to isolate the conflict
3. Use `/ff diagnose` to identify specific library conflicts
4. Check BugSack for detailed error messages
5. Consider using `## LoadAfter: Plater` if issues persist
