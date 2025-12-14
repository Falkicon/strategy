--[[
InstanceDetector.lua
Instance detection module for Strategy addon (Midnight-compatible)

Responsibilities:
- Detect current instance via GetInstanceInfo() (safe in Midnight)
- Map instance names to instanceIDs for reliable matching
- Trigger strategy panel show/hide based on instance type
- Handle zone change events
- No dependency on UnitName() or UnitGUID()

Design: Uses only Midnight-safe APIs (GetInstanceInfo, IsInInstance, GetZoneText)
]]--

local AceAddon = LibStub("AceAddon-3.0")
local InstanceDetector = AceAddon:NewAddon("StrategyInstanceDetector", "AceEvent-3.0")

-- Local WoW API references (all Midnight-safe)
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetZoneText = GetZoneText
local C_ChallengeMode = C_ChallengeMode

-- Module state
InstanceDetector.currentInstanceID = nil
InstanceDetector.currentInstanceName = nil
InstanceDetector.currentInstanceType = nil
InstanceDetector.isInSupportedInstance = false
InstanceDetector.addon = nil  -- Reference to main Strategy addon

--[[
    Initialize the module
]]
function InstanceDetector:OnInitialize()
    self.currentInstanceID = nil
    self.currentInstanceName = nil
    self.currentInstanceType = nil
    self.isInSupportedInstance = false
    self.addon = nil
end

--[[
    Set reference to main addon
    @param addon - The main Strategy addon object
]]
function InstanceDetector:SetAddon(addon)
    self.addon = addon
end

--[[
    Register events for zone/instance changes
]]
function InstanceDetector:RegisterEvents()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChanged")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("CHALLENGE_MODE_START", "OnChallengeModeStart")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "OnChallengeModeEnd")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "OnChallengeModeEnd")
    
    if self.addon then
        self.addon:Debug("InstanceDetector: Events registered")
    end
end

--[[
    Get current instance information (Midnight-safe)
    @return table with instanceName, instanceType, difficultyID, instanceID, etc.
]]
function InstanceDetector:GetInstanceInfo()
    local name, instanceType, difficultyID, difficultyName, 
          maxPlayers, dynamicDifficulty, isDynamic, instanceID,
          instanceGroupSize, lfgDungeonID = GetInstanceInfo()
    
    return {
        name = name,
        instanceType = instanceType,      -- "none", "party", "raid", "pvp", "arena", "scenario"
        difficultyID = difficultyID,
        difficultyName = difficultyName,
        maxPlayers = maxPlayers,
        instanceID = instanceID,          -- Numeric ID for reliable matching
        instanceGroupSize = instanceGroupSize,
        lfgDungeonID = lfgDungeonID,
        isInstance = instanceType ~= "none"
    }
end

--[[
    Check if current instance is a supported dungeon/raid
    @return boolean - true if in a dungeon or raid
]]
function InstanceDetector:IsInSupportedInstance()
    local inInstance, instanceType = IsInInstance()
    
    if not inInstance then
        return false
    end
    
    -- Support dungeons and raids
    return instanceType == "party" or instanceType == "raid"
end

--[[
    Get Mythic+ keystone level if in M+
    @return number|nil - keystone level or nil if not in M+
]]
function InstanceDetector:GetKeystoneLevel()
    if not C_ChallengeMode then
        return nil
    end
    
    local activeInfo = C_ChallengeMode.GetActiveKeystoneInfo and C_ChallengeMode.GetActiveKeystoneInfo()
    if activeInfo then
        return activeInfo
    end
    
    return nil
end

--[[
    Check if in Mythic+ dungeon
    @return boolean
]]
function InstanceDetector:IsInMythicPlus()
    if not C_ChallengeMode or not C_ChallengeMode.IsChallengeModeActive then
        return false
    end
    
    return C_ChallengeMode.IsChallengeModeActive()
end

--[[
    Find strategy data for current instance
    @return table|nil - Instance strategy data or nil if not found
]]
function InstanceDetector:GetCurrentInstanceData()
    if not StrategyDatabase or not StrategyDatabase.Instances then
        return nil
    end
    
    local info = self:GetInstanceInfo()
    
    if not info.isInstance then
        return nil
    end
    
    -- Try to find by instance name first (most reliable)
    local instanceData = StrategyDatabase.Instances[info.name]
    if instanceData then
        return instanceData, info.name
    end
    
    -- Fallback: search by instanceID if we have it in the data
    for instanceName, data in pairs(StrategyDatabase.Instances) do
        if data.instanceID and data.instanceID == info.instanceID then
            return data, instanceName
        end
    end
    
    -- Fallback: try zone text (for edge cases)
    local zoneText = GetZoneText()
    instanceData = StrategyDatabase.Instances[zoneText]
    if instanceData then
        return instanceData, zoneText
    end
    
    return nil
end

--[[
    Update current instance state
    Called on zone changes and player entering world
]]
function InstanceDetector:UpdateInstanceState()
    local info = self:GetInstanceInfo()
    local wasInSupportedInstance = self.isInSupportedInstance
    local previousInstanceID = self.currentInstanceID
    
    -- Update state
    self.currentInstanceID = info.instanceID
    self.currentInstanceName = info.name
    self.currentInstanceType = info.instanceType
    self.isInSupportedInstance = self:IsInSupportedInstance()
    
    -- Check if instance changed
    local instanceChanged = previousInstanceID ~= self.currentInstanceID
    
    if self.addon then
        self.addon:Debug(string.format(
            "InstanceDetector: Updated - %s (%s), ID: %s, Supported: %s",
            tostring(self.currentInstanceName),
            tostring(self.currentInstanceType),
            tostring(self.currentInstanceID),
            tostring(self.isInSupportedInstance)
        ))
    end
    
    -- Notify listeners of state change
    if instanceChanged then
        self:OnInstanceChanged(wasInSupportedInstance)
    end
    
    return self.isInSupportedInstance
end

--[[
    Handle instance change
    @param wasInSupportedInstance - Whether we were previously in a supported instance
]]
function InstanceDetector:OnInstanceChanged(wasInSupportedInstance)
    local instanceData, instanceName = self:GetCurrentInstanceData()
    
    if self.addon then
        -- Reset announced tracking on instance change
        if self.addon.db and self.addon.db.profile then
            self.addon.db.profile.announcedStrategies = {}
        end
        
        -- Notify StrategyPanel to update
        if self.addon.StrategyPanel then
            if self.isInSupportedInstance and instanceData then
                self.addon.StrategyPanel:LoadInstance(instanceData, instanceName)
                
                -- Auto-show panel if enabled and addon is enabled
                if self.addon.db.profile.enabled and self.addon.db.profile.autoShowStrategyPanel then
                    self.addon.StrategyPanel:Show()
                end
            else
                -- Auto-hide panel if enabled
                if self.addon.db.profile.autoHideStrategyPanel then
                    self.addon.StrategyPanel:Hide()
                end
                self.addon.StrategyPanel:ClearInstance()
            end
        end
        
        self.addon:Debug(string.format(
            "InstanceDetector: Instance changed - Data found: %s",
            tostring(instanceData ~= nil)
        ))
    end
end

--[[
    Event: Zone changed
]]
function InstanceDetector:OnZoneChanged()
    self:UpdateInstanceState()
end

--[[
    Event: Player entering world (login, reload, instance load)
]]
function InstanceDetector:OnPlayerEnteringWorld()
    -- Delay slightly to ensure APIs are ready
    C_Timer.After(0.5, function()
        self:UpdateInstanceState()
    end)
end

--[[
    Event: Challenge mode (M+) started
]]
function InstanceDetector:OnChallengeModeStart()
    self:UpdateInstanceState()
    
    if self.addon then
        self.addon:Debug("InstanceDetector: M+ started")
    end
end

--[[
    Event: Challenge mode ended or reset
]]
function InstanceDetector:OnChallengeModeEnd()
    -- Reset announced tracking when M+ ends
    if self.addon and self.addon.db and self.addon.db.profile then
        self.addon.db.profile.announcedStrategies = {}
    end
    
    if self.addon then
        self.addon:Debug("InstanceDetector: M+ ended - tracking reset")
    end
end

--[[
    Get formatted status string for debugging
    @return string
]]
function InstanceDetector:GetStatusString()
    local info = self:GetInstanceInfo()
    local keystoneLevel = self:GetKeystoneLevel()
    local isMythicPlus = self:IsInMythicPlus()
    
    local status = string.format(
        "Instance: %s | Type: %s | ID: %s | M+: %s",
        tostring(info.name),
        tostring(info.instanceType),
        tostring(info.instanceID),
        isMythicPlus and ("Yes, +" .. tostring(keystoneLevel or "?")) or "No"
    )
    
    return status
end

-- Export for global access
_G["StrategyInstanceDetector"] = InstanceDetector
