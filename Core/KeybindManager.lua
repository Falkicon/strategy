--[[
    KeybindManager.lua
    Keybind management for Strategy addon (Midnight-compatible)
    
    Updated: Keybinds disabled by user request. Functions kept as no-ops to prevent errors.
]]--

local AceAddon = LibStub("AceAddon-3.0")
local KeybindManager = {}

--[[
    Initialize the KeybindManager
]]
function KeybindManager:Initialize(addon)
    self.addon = addon
    -- No-op: Keybinds removed
    if addon then
        addon:Debug("KeybindManager: Initialized (Disabled)")
    end
end

--[[
    Enable keybinds (No-op)
]]
function KeybindManager:EnableKeybinds()
    return false
end

--[[
    Disable keybinds (No-op)
]]
function KeybindManager:DisableKeybinds()
    return true
end

--[[
    Refresh keybinds (No-op)
]]
function KeybindManager:RefreshKeybinds()
    return
end

--[[
    Get the modifier prefix (No-op)
]]
function KeybindManager:GetModifierPrefix()
    return ""
end

--[[
    Handle a keybind press (No-op)
]]
function KeybindManager:HandleKeybindPress(number)
    return false
end

--[[
    Check if keybinds are currently active
]]
function KeybindManager:AreKeybindsActive()
    return false
end

--[[
    Get list of current keybinds for display
]]
function KeybindManager:GetKeybindList()
    return {}
end

-- Export for global access
_G["StrategyKeybindManager"] = KeybindManager
