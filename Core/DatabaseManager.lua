--[[
StrategyDatabaseManager.lua
Database management module for Strategy addon

Responsibilities:
- Instance data loading/unloading
- Strategy lookup by ID or index
- Zone change handling
- Database access methods
--]]

local AceAddon = LibStub("AceAddon-3.0")

-- Create the DatabaseManager module
local DatabaseManager = AceAddon:NewAddon("StrategyDatabaseManager", "AceEvent-3.0")

-- Local WoW API references for performance
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
    self.CurrentStrategies = {}        -- strategies[] array for current instance
    self.LoadedInstance = nil
    self.LoadedInstanceID = nil        -- numeric instance ID
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

-- Database Access

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

-- Legacy: Get boss data (Reserved for future use)
function DatabaseManager:GetBossData(unitName)
    return nil
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

-- Instance Loading System
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
    -- Load strategies
    self.LoadedInstance = currentZone
    self.LoadedInstanceID = instanceData.instanceID
    
    if instanceData.strategies and #instanceData.strategies > 0 then
        self.CurrentStrategies = instanceData.strategies
        
        if self.addon then
            self.addon:Debug("Loaded " .. #self.CurrentStrategies .. " strategies for " .. currentZone)
        end
    else
        if self.addon then
            self.addon:Debug("No strategies found for: " .. currentZone)
        end
    end
end

-- Deprecated: CheckAndOutputBoss (Functionality removed)

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
        strategyCount = #self.CurrentStrategies,
        announcedCount = 0
    }
    
    -- Count strategies
    if self.CurrentStrategies and #self.CurrentStrategies > 0 then
        status.strategyCount = #self.CurrentStrategies
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
