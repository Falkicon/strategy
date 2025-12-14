--[[
StrategyDatabaseManager.lua
Database management module for Strategy addon (v2.0 Midnight-compatible)

Responsibilities:
- Instance data loading/unloading
- Strategy lookup by ID or index (v2.0)
- Zone change handling
- Database access methods
- Backward compatibility with v1.x encounters format

v2.0 Changes:
- Removed CheckAndOutputBoss (no longer using UnitName for detection)
- Added GetStrategy(), GetStrategiesForInstance() for button-based UI
- Added support for area-based strategies[] format
--]]

local AceAddon = LibStub("AceAddon-3.0")

-- Create the DatabaseManager module
local DatabaseManager = AceAddon:NewAddon("StrategyDatabaseManager", "AceEvent-3.0")

-- Local WoW API references for performance (Midnight-safe only)
local GetZoneText = GetZoneText
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetSpecializationRole = GetSpecializationRole
local GetSpecialization = GetSpecialization
local time = time
-- Removed: UnitName (blocked in Midnight combat/M+)

function DatabaseManager:OnInitialize()
    -- Initialize tracking data
    self.CurrentInstanceData = {}      -- Current instance's strategy data
    self.CurrentStrategies = {}        -- v2.0: strategies[] array for current instance
    self.LoadedInstance = nil
    self.LoadedInstanceID = nil        -- v2.0: numeric instance ID
    self.outputTracker = {}            -- Track announced strategies
    
    -- Reference to main addon (will be set by Core.lua)
    self.addon = nil
end

-- Set reference to main addon
function DatabaseManager:SetAddon(addon)
    self.addon = addon
end

-- Zone Detection
function DatabaseManager:GetCurrentZone()
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        local instanceName = GetInstanceInfo()
        return instanceName
    else
        local zoneName = GetZoneText()
        return zoneName
    end
end

-- Validation Functions


function DatabaseManager:IsInValidInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "party" or instanceType == "raid")
end

-- Database Access (v2.0 - strategy-based)

--[[
    Get strategy by ID from current instance
    @param strategyId - The unique strategy ID (e.g., "boss1_momma")
    @return table|nil - The strategy data or nil if not found
]]
function DatabaseManager:GetStrategy(strategyId)
    if not strategyId then return nil end
    
    for _, strategy in ipairs(self.CurrentStrategies) do
        if strategy.id == strategyId then
            return strategy
        end
    end
    
    return nil
end

--[[
    Get strategy by keybind number (1-10)
    @param keybindNumber - The keybind number
    @return table|nil - The strategy data or nil if not found
]]
function DatabaseManager:GetStrategyByKeybind(keybindNumber)
    if not keybindNumber then return nil end
    
    for _, strategy in ipairs(self.CurrentStrategies) do
        if strategy.keybind == keybindNumber then
            return strategy
        end
    end
    
    -- Fallback: use index if no explicit keybind match
    return self.CurrentStrategies[keybindNumber]
end

--[[
    Get all strategies for current instance
    @return table - Array of strategy data (empty if no instance loaded)
]]
function DatabaseManager:GetStrategiesForInstance()
    return self.CurrentStrategies or {}
end

--[[
    Get strategies grouped by their group field
    @return table - Table of {groupName = {strategies...}}
]]
function DatabaseManager:GetStrategiesGrouped()
    local groups = {}
    local groupOrder = {}
    
    for _, strategy in ipairs(self.CurrentStrategies) do
        local groupName = strategy.group or "Ungrouped"
        
        if not groups[groupName] then
            groups[groupName] = {}
            table.insert(groupOrder, groupName)
        end
        
        table.insert(groups[groupName], strategy)
    end
    
    return groups, groupOrder
end

-- Legacy: Get boss data (v1.x compatibility)
function DatabaseManager:GetBossData(unitName)
    -- MEDIUM FIX: Add initialization check
    if not StrategyDatabase then
        if self.addon then
            self.addon:Debug("Database not yet initialized")
        end
        return nil
    end
    
    -- Return data from current instance
    return self.CurrentInstanceData[unitName]
end

function DatabaseManager:FindBossInAllInstances(bossName)
    -- Try to find boss in all available instances (for testing)
    if not StrategyDatabase or not StrategyDatabase.Instances then
        return nil
    end
    
    for zoneName, instanceData in pairs(StrategyDatabase.Instances) do
        if instanceData.encounters and instanceData.encounters[bossName] then
            return instanceData.encounters[bossName]
        end
    end
    return nil
end

-- Instance Loading System (v2.0 - supports both formats)
function DatabaseManager:LoadCurrentInstance()
    local currentZone = self:GetCurrentZone()
    if not currentZone then return end
    
    -- Check if already loaded this instance
    if self.LoadedInstance == currentZone then
        if self.addon then
            self.addon:Debug("Instance already loaded: " .. currentZone)
        end
        return
    end
    
    -- Load from global database
    if not StrategyDatabase or not StrategyDatabase.Instances then
        if self.addon then
            self.addon:Debug("StrategyDatabase not available")
        end
        return
    end
    
    local instanceData = StrategyDatabase.Instances[currentZone]
    if not instanceData then
        if self.addon then
            self.addon:Debug("No instance data available for zone: " .. currentZone)
        end
        return
    end
    
    -- Load the data based on format version
    self.LoadedInstance = currentZone
    self.LoadedInstanceID = instanceData.instanceID
    
    -- v2.0 format: strategies[] array
    if instanceData.strategies and #instanceData.strategies > 0 then
        self.CurrentStrategies = instanceData.strategies
        self.CurrentInstanceData = {}  -- Legacy field empty for v2.0
        
        if self.addon then
            self.addon:Debug("Loaded " .. #self.CurrentStrategies .. " strategies for " .. currentZone .. " (v2.0 format)")
        end
    -- v1.x format: encounters{} table (legacy compatibility)
    elseif instanceData.encounters then
        self.CurrentInstanceData = instanceData.encounters
        self.CurrentStrategies = {}  -- No v2.0 strategies
        
        local encounterCount = 0
        for _ in pairs(self.CurrentInstanceData) do
            encounterCount = encounterCount + 1
        end
        
        if self.addon then
            self.addon:Debug("Loaded " .. encounterCount .. " encounters for " .. currentZone .. " (v1.x format)")
        end
    else
        if self.addon then
            self.addon:Debug("No strategies or encounters found for: " .. currentZone)
        end
    end
end

-- v1.x DEPRECATED: CheckAndOutputBoss
-- This function is removed in v2.0 because UnitName() returns secret values
-- in Midnight M+ and raids. Use StrategyPanel button clicks instead.
--[[
function DatabaseManager:CheckAndOutputBoss(unit)
    -- REMOVED: This functionality is blocked by Midnight API restrictions
    -- Players now use the StrategyPanel to click buttons to announce strategies
end
]]

-- Testing Functions
function DatabaseManager:TestRandomBoss()
    if not self.CurrentInstanceData or not next(self.CurrentInstanceData) then
        if self.addon then
            self.addon:Print("Boss database not loaded!")
        end
        return
    end
    
    -- Get all boss names
    local bosses = {}
    for name, _ in pairs(self.CurrentInstanceData) do
        table.insert(bosses, name)
    end
    
    if #bosses == 0 then
        if self.addon then
            self.addon:Print("No bosses available for testing!")
        end
        return
    end
    
    -- Pick random boss
    local randomBoss = bosses[math.random(#bosses)]
    local bossData = self.CurrentInstanceData[randomBoss]
    
    if self.addon then
        self.addon:Print("Testing with boss: " .. randomBoss)
        self.addon:OutputStrategy(randomBoss, bossData)
    end
end

-- Reset output tracking (useful for zone changes)
function DatabaseManager:ResetOutputTracker()
    self.outputTracker = {}
    if self.addon then
        self.addon:Debug("DatabaseManager: Reset output tracker")
    end
end

-- Mark strategy as announced
function DatabaseManager:MarkAnnounced(strategyId)
    if strategyId then
        self.outputTracker[strategyId] = true
    end
end

-- Check if strategy was announced
function DatabaseManager:IsAnnounced(strategyId)
    return self.outputTracker[strategyId] == true
end

-- Get current instance status
function DatabaseManager:GetInstanceStatus()
    local status = {
        currentZone = self:GetCurrentZone(),
        loadedInstance = self.LoadedInstance,
        loadedInstanceID = self.LoadedInstanceID,
        strategyCount = #self.CurrentStrategies,      -- v2.0 count
        encounterCount = 0,                            -- v1.x count (legacy)
        announcedCount = 0,
        formatVersion = "unknown"
    }
    
    -- Determine format version
    if self.CurrentStrategies and #self.CurrentStrategies > 0 then
        status.formatVersion = "v2.0"
        status.strategyCount = #self.CurrentStrategies
    elseif self.CurrentInstanceData and next(self.CurrentInstanceData) then
        status.formatVersion = "v1.x"
        for _ in pairs(self.CurrentInstanceData) do
            status.encounterCount = status.encounterCount + 1
        end
    end
    
    -- Count announced strategies
    for _ in pairs(self.outputTracker) do
        status.announcedCount = status.announcedCount + 1
    end
    
    return status
end

--[[
    Get instance data for the StrategyPanel
    @return table|nil - The full instance data or nil
]]
function DatabaseManager:GetCurrentInstanceData()
    if not self.LoadedInstance then
        return nil
    end
    
    if StrategyDatabase and StrategyDatabase.Instances then
        return StrategyDatabase.Instances[self.LoadedInstance]
    end
    
    return nil
end

-- Make the module globally accessible
_G["StrategyDatabaseManager"] = DatabaseManager
