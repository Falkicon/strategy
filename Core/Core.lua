--[[
Strategy - Core Logic
Contains addon initialization, boss detection, strategy output, and database management
]]--

-- LOADING DIAGNOSTIC
-- Debug prints disabled for production
-- print("=== STRATEGY LOADING START ===")
-- print("1. Core.lua file loading...")
-- print("2. Checking LibStub availability: " .. tostring(LibStub ~= nil))
-- if LibStub then
--     print("3. LibStub version: " .. tostring(LibStub.minor or "unknown"))
-- end

-- Ace3 Integration (defensive loading to prevent conflicts with other addons)
-- Upvalue LibStub for cleaner VS Code linting
local LibStub = LibStub
-- print("4. Loading Ace3 libraries...")
local AceAddon = LibStub("AceAddon-3.0", true)
-- print("   AceAddon: " .. tostring(AceAddon ~= nil))

local AceConsole = LibStub("AceConsole-3.0", true)
-- print("   AceConsole: " .. tostring(AceConsole ~= nil))

local AceEvent = LibStub("AceEvent-3.0", true)
-- print("   AceEvent: " .. tostring(AceEvent ~= nil))

local AceDB = LibStub("AceDB-3.0", true)
-- print("   AceDB: " .. tostring(AceDB ~= nil))

local AceConfig = LibStub("AceConfig-3.0", true)
-- print("   AceConfig: " .. tostring(AceConfig ~= nil))

local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
-- print("   AceConfigDialog: " .. tostring(AceConfigDialog ~= nil))

local AceDBOptions = LibStub("AceDBOptions-3.0", true)
-- print("   AceDBOptions: " .. tostring(AceDBOptions ~= nil))

-- Ensure we have required libraries (but don't error immediately - let's debug)
if not AceAddon then
    print("STRATEGY ERROR: AceAddon-3.0 library not found. This may be due to a conflict with another addon.")
    return -- Stop loading but don't crash other addons
end

-- Create addon using Ace3
-- print("5. Creating Strategy addon object...")
local Strategy = AceAddon:NewAddon("Strategy", "AceConsole-3.0", "AceEvent-3.0")
-- print("6. Strategy created: " .. tostring(Strategy ~= nil))

-- Global addon reference (enhanced conflict protection)
local globalName = "Strategy"
if not _G[globalName] then
    _G[globalName] = Strategy
    -- Note: Can't call Debug() here - addon not initialized yet
else
    -- Another addon may have created this global - issue warning and use backup
    print("|cffff8000[Strategy] WARNING: Global 'Strategy' already exists - potential addon conflict!|r")
    local backupName = "Strategy_Main"
    _G[backupName] = Strategy
end

-- Load Strategy Engine module (loaded from TOC)
Strategy.StrategyEngine = _G["StrategyEngine"]

-- Upvalue frequently used globals for performance (only the ones actually used)
-- Note: Removed unused upvalues to clean up VS Code linter warnings
-- Individual modules upvalue their own required WoW API functions

-- Add essential slash command handler
function Strategy:SlashCommand(input)
    local command, arg = self:GetArgs(input, 2)
    command = command and command:lower() or ""
    
    -- Check for numeric strategy announcements (1-10)

    
    if command == "" or command == "help" then
        self:Print("Strategy Commands:")
        self:Print("  |cff00ccff/strat settings|r - Open settings panel")
        self:Print("  |cff00ccff/strat panel|r - Toggle strategy panel")

        self:Print("  |cff00ccff/strat diagnose|r - Show diagnostic info")
        self:Print("  |cff00ccff/strat enable|r - Enable the addon")
        self:Print("  |cff00ccff/strat disable|r - Disable the addon")
        self:Print("  |cff00ccff/strat toggle|r - Toggle addon on/off")
        self:Print("  |cff00ccff/strat reset|r - Reset announced strategies")
        
    elseif command == "settings" or command == "config" then
        self:OpenSettings()
    
    elseif command == "panel" then
        -- Toggle strategy panel
        if self.StrategyPanel then
            self.StrategyPanel:Toggle()
        else
            self:Print("Strategy Panel not loaded")
        end
        
    elseif command == "test" then
        self:TestRandomBoss()
        
    elseif command == "diagnose" then
        self:Print("=== STRATEGY DIAGNOSTIC ===")
        self:Print("1. Addon loaded: " .. tostring(self ~= nil))
        self:Print("2. Database loaded: " .. tostring(self.db ~= nil))
        
        -- Validate modules before accessing
        if self.DatabaseManager then
            local status = self.DatabaseManager:GetInstanceStatus()
            self:Print("3. Strategies loaded: " .. (status.strategyCount or status.encounterCount or 0))
            self:Print("4. Announced strategies: " .. (status.announcedCount or status.encounteredCount or 0))
        else
            self:Print("3. DatabaseManager: |cffff0000NOT LOADED|r")
        end
        
        -- Core modules
        self:Print("5. Core Modules: SE:" .. (self.StrategyEngine and "✓" or "✗") .. 
                   " DB:" .. (self.DatabaseManager and "✓" or "✗") .. 
                   " DM:" .. (self.DefaultsManager and "✓" or "✗"))
        -- Feature modules
        self:Print("6. Feature Modules: ID:" .. (self.InstanceDetector and "✓" or "✗") .. 
                   " SP:" .. (self.StrategyPanel and "✓" or "✗") .. 
                   " KB:" .. (self.KeybindManager and "✓" or "✗"))
        self:Print("7. LibStub version: " .. tostring(LibStub and LibStub.minor or "unknown"))
        
        -- Instance detection status
        if self.InstanceDetector then
            local instData = self.InstanceDetector:GetCurrentInstanceData()
            if instData and instData.isInstance then
                self:Print("8. Current instance: " .. (instData.name or "Unknown") .. " (" .. (instData.instanceID or "?") .. ")")
            else
                self:Print("8. Current instance: |cff888888Not in instance|r")
            end
        end
        self:Print("=== END DIAGNOSTIC ===")
        
    elseif command == "enable" then
        self.db.profile.enabled = true
        self:Print("Strategy |cff00ff00enabled|r")
        
    elseif command == "disable" then
        self.db.profile.enabled = false
        -- Hide panel when disabled
        if self.StrategyPanel then
            self.StrategyPanel:Hide()
        end
        -- Disable keybinds
        if self.KeybindManager then
            self.KeybindManager:DisableKeybinds()
        end
        self:Print("Strategy |cffff0000disabled|r")
        
    elseif command == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        local status = self.db.profile.enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        
        -- Hide panel and disable keybinds when toggling off
        if not self.db.profile.enabled then
            if self.StrategyPanel then
                self.StrategyPanel:Hide()
            end
            if self.KeybindManager then
                self.KeybindManager:DisableKeybinds()
            end
        end
        
        self:Print("Strategy " .. status)
        
    elseif command == "reset" then
        -- Reset announced strategies
        if self.DatabaseManager then
            self.DatabaseManager:ResetOutputTracker()
        end
        if self.StrategyPanel then
            self.StrategyPanel:ResetAnnouncedState()
        end
        -- Clear announced strategies tracking
        if self.db and self.db.profile then
            self.db.profile.announcedStrategies = {}
        end
        self:Print("Announced strategies reset - all strategies can be announced again")
        
    else
        self:Print("Unknown command: " .. command)
        self:Print("Type |cff00ccff/strat|r for help")
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function Strategy:TestRandomBoss()
    return self.DatabaseManager:TestRandomBoss()
end

function Strategy:GetCurrentZone()
    return self.DatabaseManager:GetCurrentZone()
end

function Strategy:GetTableKeys(tbl)
    local count = 0
    if tbl then
        for _ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end

function Strategy:Debug(message)
    if self.db and self.db.profile and self.db.profile.debugMode then
        self:Print("|cff888888[DEBUG]|r " .. tostring(message))
    end
end

-- Additional utility methods (delegate to StrategyEngine)
function Strategy:ParseRoles(roleFilter)
    return self.StrategyEngine:ParseRoles(roleFilter)
end

function Strategy:GetActiveRoles()
    return self.StrategyEngine:GetActiveRoles()
end

function Strategy:GetRoleHeader(role)
    return self.StrategyEngine:GetRoleHeader(role)
end

function Strategy:StripColorsForSay(lines)
    return self.StrategyEngine:StripColorsForSay(lines)
end

-- ============================================================================
-- DELEGATION FUNCTIONS
-- ============================================================================

-- String utility function for profiles
if not string.trim then
    function string.trim(s)
        return s:match("^%s*(.-)%s*$")
    end
end

function Strategy:FormatStrategy(bossName, bossData)
    -- Delegate to StrategyEngine
    return self.StrategyEngine:FormatStrategy(bossName, bossData, self)
end

-- Default configuration
-- Core validation functions


function Strategy:IsInValidInstance()
    return self.DatabaseManager:IsInValidInstance()
end

-- Role detection and filtering
-- Strategy output (delegate to StrategyEngine)
function Strategy:OutputStrategy(bossName, bossData)
    return self.StrategyEngine:OutputStrategy(bossName, bossData, self)
end

-- Output minimal critical mechanics only (delegate to StrategyEngine)
function Strategy:OutputMinimalStrategy(bossName, bossData)
    return self.StrategyEngine:OutputMinimalStrategy(bossName, bossData, self)
end

-- Helper for debugging
function Strategy:GetDebugMethodList()
    local methods = {}
    for k, v in pairs(self) do
        if type(v) == "function" then
            table.insert(methods, k)
        end
    end
    return methods
end



-- Strategy access (area-based, not boss-based)
function Strategy:GetStrategy(strategyId)
    if self.DatabaseManager then
        return self.DatabaseManager:GetStrategy(strategyId)
    end
    return nil
end

function Strategy:GetStrategiesForInstance(instanceID)
    if self.DatabaseManager then
        return self.DatabaseManager:GetStrategiesForInstance(instanceID)
    end
    return {}
end

function Strategy:FindBossInAllInstances(bossName)
    return self.DatabaseManager:FindBossInAllInstances(bossName)
end

-- Instance Loading System
function Strategy:LoadCurrentInstance()
    return self.DatabaseManager:LoadCurrentInstance()
end

-- Database Access Methods (for StrategyPanel)
function Strategy:GetEncounteredBosses()
    return self.DatabaseManager.encounteredBosses or {}
end

function Strategy:GetCurrentInstanceData()
    return self.DatabaseManager.CurrentInstanceData
end

-- Ace3 Initialization
function Strategy:OnInitialize()
    -- Debug: print("=== STRATEGY OnInitialize() CALLED ===")
    
    -- MEDIUM FIX: Enhanced module initialization with better error recovery
    local moduleLoadSuccess = true
    local loadedModules = {}
    
    -- Try to load each module with error protection
    local modules = {
        {name = "DefaultsManager", global = "StrategyDefaultsManager"},
        {name = "StrategyEngine", global = "StrategyEngine"},
        {name = "DatabaseManager", global = "StrategyDatabaseManager"},
        -- Feature modules
        {name = "InstanceDetector", global = "StrategyInstanceDetector"},
        {name = "StrategyPanel", global = "StrategyPanel"},
        {name = "KeybindManager", global = "StrategyKeybindManager"}
    }
    
    for _, module in ipairs(modules) do
        local success, moduleObj = pcall(function()
            return _G[module.global]
        end)
        
        if success and moduleObj then
            self[module.name] = moduleObj
            loadedModules[module.name] = true
            self:Debug("Module loaded successfully: " .. module.name)
        else
            self:Print("|cffff0000ERROR: " .. module.name .. " module failed to load!|r")
            moduleLoadSuccess = false
        end
    end
    
    -- If any critical modules failed, provide recovery options
    if not moduleLoadSuccess then
        self:Print("|cffff8000Strategy addon partially loaded. Available recovery options:|r")
        self:Print("  1. |cff00ccff/reload|r - Reload the UI")
        self:Print("  2. Disable conflicting addons and restart")
        self:Print("  3. Contact addon author if problem persists")
        
        -- Try to continue with whatever modules we have
        if not loadedModules.DefaultsManager then
            self:Print("|cffff0000Cannot continue without DefaultsManager - addon disabled|r")
            return
        end
    end
    
    -- Get defaults from DefaultsManager
    local defaults = self.DefaultsManager:GetDefaults()
    if not defaults then
        self:Print("|cffff0000ERROR: Failed to get default settings!|r")
        self:Print("|cffff8000This may indicate a module loading issue - try /reload|r")
        return
    end
    
    -- Initialize database with AceDB
    self.db = AceDB:New("StrategyDB", defaults, true)
    
    -- Set addon reference in modules
    if self.DefaultsManager and self.DefaultsManager.SetAddon then
        self.DefaultsManager:SetAddon(self)
    end
    if self.StrategyEngine then
        -- StrategyEngine is stateless, doesn't need SetAddon
        self.StrategyEngine.addon = self
    end
    if self.DatabaseManager and self.DatabaseManager.SetAddon then
        self.DatabaseManager:SetAddon(self)
    end
    -- Feature modules
    if self.InstanceDetector and self.InstanceDetector.SetAddon then
        self.InstanceDetector:SetAddon(self)
    end
    if self.StrategyPanel and self.StrategyPanel.Initialize then
        self.StrategyPanel:Initialize(self)
    end
    if self.KeybindManager and self.KeybindManager.Initialize then
        self.KeybindManager:Initialize(self)
    end
    
    -- Output tracker is now handled by DatabaseManager
    -- (removed redundant initialization)

    -- Register slash commands immediately (timing critical)
    -- Register slash commands immediately (timing critical)
    self:RegisterChatCommand("strat", "SlashCommand")
    self:RegisterChatCommand("strategy", "SlashCommand")


    -- Initialize settings GUI
    self:InitializeSettings()
    
    -- Initialize data broker integration
    self:InitializeDataBroker()
    
    -- Load initial instance data
    self:LoadCurrentInstance()
    
    self:Print("|cff00ff00Strategy loaded successfully!|r Type |cff00ccff/strat settings|r to open settings.")
end

function Strategy:OnEnable()
    -- Load initial instance data if in a dungeon
    self:LoadCurrentInstance()
    
    if self.db.profile.debugMode then
        self:Debug("Debug mode active")
    end
    
    -- Register InstanceDetector events (replaces target/mouseover handlers)
    if self.InstanceDetector then
        self.InstanceDetector:RegisterEvents()
    end
    
    -- Register zone/combat events
    -- Note: UPDATE_MOUSEOVER_UNIT and PLAYER_TARGET_CHANGED removed for Midnight compatibility
    -- self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd") -- REMOVED
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChanged")
    
    self:Debug("Addon enabled successfully")
end

-- Event handlers



    -- OnCombatEnd removed (feature retired)

function Strategy:OnZoneChanged()
    self:Debug("Zone changed - loading new instance data")
    
    -- InstanceDetector handles zone change detection
    -- This is a backup handler for additional processing
    
    -- Clear announced strategies if setting enabled
    if self.db.profile.clearWindowOnZoneChange then
        self.DatabaseManager:ResetOutputTracker()
        self.db.profile.announcedStrategies = {}
        self:Debug("Cleared announced strategies on zone change")
    end
    
    self:LoadCurrentInstance()
end

-- Settings GUI Integration
function Strategy:InitializeSettings()
    return self.DefaultsManager:InitializeSettings()
end

-- LibDataBroker Integration  
function Strategy:InitializeDataBroker()
    return self.DefaultsManager:InitializeDataBroker()
end

-- Settings panel opener
function Strategy:OpenSettings()
    return self.DefaultsManager:OpenSettings()
end

-- LOW PRIORITY FIX: Add OnDisable for proper cleanup
function Strategy:OnDisable()
    self:Debug("Strategy addon disabling - cleaning up")
    
    -- Unregister all events to prevent memory leaks
    self:UnregisterAllEvents()
    
    -- Clean up Strategy Panel
    if self.StrategyPanel and self.StrategyPanel.frame then
        self.StrategyPanel.frame:Hide()
    end
    
    self:Debug("Strategy addon cleanup complete")
end
