--[[
    Strategy - Formatting Unit Tests
    Verifies that chat compression and coloring work as expected.
    Run from Addon root: lua Tests/test_formatting.lua
]]

-- 1. Mock WoW Environment
_G = _G or {}
GetSpecialization = function() return 1 end
GetSpecializationRole = function(spec) return "TANK" end
SendChatMessage = function() end
IsInGroup = function() return true end
IsInRaid = function() return false end
InCombatLockdown = function() return false end

-- 2. Load StrategyEngine
local function loadFile(path)
    local f = io.open(path, "r")
    if not f then 
        -- Try relative to Tests folder if running from there
        f = io.open("../" .. path, "r")
        if not f then error("Cannot open " .. path) end
    end
    local content = f:read("*a")
    f:close()
    local chunk, err = load(content, path)
    if not chunk then error(err) end
    chunk()
end

print("Loading StrategyEngine.lua...")
loadFile("Core/StrategyEngine.lua")
local StrategyEngine = _G["StrategyEngine"]

if not StrategyEngine then
    error("Failed to load StrategyEngine module")
end

-- 3. Test Setup
local function assert_equal(expected, actual, msg)
    if expected ~= actual then
        error(string.format("%s\nExpected: '%s'\nActual:   '%s'", msg or "Fail", expected, actual))
    end
end

-- 4. Execute Tests
print("Running Formatting Tests...")

local bossData = {
    mobType = "boss",
    tank = {"Tank Point 1", "Tank Point 2"},
    dps = {"DPS Point 1"},
    all = {"All Point 1"}
}

-- Mock Addon with settings
local addon = { 
    db = { 
        profile = { 
            roleFilter = "all" 
        } 
    } 
}

-- Format with forceFull=true
local lines = StrategyEngine:FormatStrategy("Test Boss", bossData, addon, true)

-- Assertions
-- Line 1: Header
assert_equal(">>> Test Boss STRATEGY <<<", lines[1], "Header Incorrect")

-- Line 2: All (First in role order)
-- Format: [ALL] All Point 1
assert_equal("|cffFFD700[ALL]|r All Point 1", lines[2], "ALL line incorrect")

-- Line 3: Tank
-- Format: [TANK] Tank Point 1 |cff999999 // |r Tank Point 2
assert_equal("|cff4A90E2[TANK]|r Tank Point 1 |cff999999 // |r Tank Point 2", lines[3], "TANK line separator incorrect")

-- Line 4: DPS
-- Format: [DPS] DPS Point 1
assert_equal("|cffE74C3C[DPS]|r DPS Point 1", lines[4], "DPS line incorrect")

print("SUCCESS: Chat formatting (compression & color) verified!")
