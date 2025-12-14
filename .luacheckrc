-- Luacheck configuration for Fen Frame WoW Addon
-- Install luacheck: `luarocks install luacheck`
-- Run: `luacheck .` from project root

-- Basic configuration
std = "max"
max_line_length = 120
codes = true

-- WoW API globals (common ones used by addons)
globals = {
    -- Ace3 Framework
    "LibStub",
    
    -- WoW API Functions
    "GetSpecializationRole", "GetSpecialization", "UnitName", "UnitGUID", 
    "GetZoneText", "GetInstanceInfo", "SendChatMessage", "GetAddOnMetadata",
    "IsInGroup", "IsInRaid", "IsInInstance", "InCombatLockdown",
    "GetTime", "InterfaceOptionsFrame_OpenToCategory", "Settings",
    
    -- WoW Constants
    "LE_PARTY_CATEGORY_INSTANCE",
    
    -- Global addon namespace
    "FenFrame", "FenFrameDB", "FenFrameDatabase",
    
    -- Standard Lua extensions WoW provides
    "collectgarbage", "pcall", "pairs", "ipairs", "next", "type", "tostring",
    "table", "string", "math", "print"
}

-- Read-only globals (don't warn about not setting these)
read_globals = {
    -- WoW API that we read but don't modify
    "_G"
}

-- Files to exclude from checking
exclude_files = {
    "Libs/**/*.lua",          -- Third-party libraries
    "Fen.lua.backup",         -- Backup file
}

-- Ignore specific warnings
ignore = {
    "211",  -- Unused local variable (sometimes needed for API calls)
    "212",  -- Unused argument (common in WoW callback functions)
    "213",  -- Unused loop variable
    "631",  -- max_line_length (for long strategy strings)
}

-- Files with special rules
files["Core/Core.lua"] = {
    globals = {"FenFrame"}  -- FenFrame is created in this file
}

files["Core/Utils.lua"] = {
    globals = {"addon"}     -- Uses addon reference
}

files["Core/Events.lua"] = {
    globals = {"addon"}     -- Uses addon reference  
}

files["Core/Commands.lua"] = {
    globals = {"addon"}     -- Uses addon reference
}

files["Core/Config.lua"] = {
    globals = {"addon"}     -- Uses addon reference
}
