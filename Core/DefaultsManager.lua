--[[
StrategyDefaultsManager.lua
Configuration and settings management module for Strategy addon

Responsibilities:
- Default configuration templates
- Settings UI initialization
- Profile management
- Configuration validation
- Settings panel integration
--]]

local AceAddon = LibStub("AceAddon-3.0")

-- Local references for settings
local AceConfig = LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)

-- Create the DefaultsManager module
local DefaultsManager = AceAddon:NewAddon("StrategyDefaultsManager", "AceEvent-3.0")

function DefaultsManager:OnInitialize()
    -- Reference to main addon (will be set by Core.lua)
    self.addon = nil
end

-- Set reference to main addon
function DefaultsManager:SetAddon(addon)
    self.addon = addon
end

-- Default Configuration Template
function DefaultsManager:GetDefaults()
    return {
        profile = {
            enabled = true,

            outputMode = "instance", -- "instance", "whisper", "party", "say", "self"
            whisperTarget = "",

            roleFilter = "auto", -- "auto", "all", "tank", "dps", "healer", "tank,dps", etc.
            debugMode = false,
            includeTrashMobs = true,
            
            -- Visibility Overrides
            alwaysShowInterrupts = false,
            alwaysShowDispels = false,
            
            -- Strategy Panel settings
            autoShowStrategyPanel = true, -- Auto-show panel when entering dungeon
            autoHideStrategyPanel = true, -- Auto-hide panel when leaving dungeon
            
            -- Strategy Panel styling
            strategyPanel = {
                -- Dimensions
                width = 300,
                minHeight = 150,
                maxHeight = 425,
                
                -- Spacing
                padding = 4,
                buttonSpacing = 2,
                groupSpacing = 8,
                
                -- Element sizes
                buttonHeight = 20,
                titleBarHeight = 28,
                footerHeight = 32,
                dividerHeight = 1, -- dividerThickness maps to this or we use a new one
                dividerThickness = 2,
                
                -- Colors (RGBA 0-1)
                backgroundColor = {0.1, 0.1, 0.1, 0.5},
                borderColor = {0.3, 0.3, 0.3, 1},
                titleBarColor = {0, 0, 0, 0}, -- Transparent
                titleTextColor = {1, 0.82, 0, 1},
                dividerColor = {0.4, 0.4, 0.4, 0.6},
                buttonColor = {0, 0, 0, 0.5}, -- 50% opacity black
                buttonHighlightColor = {0, 0, 0, 0.3}, -- 30% opacity black (lighter than normal)
                buttonAnnouncedColor = {0.15, 0.15, 0.15, 0.7},
                textColor = {1, 1, 1, 1},
                textAnnouncedColor = {0.5, 0.5, 0.5, 1},
                keybindColor = {0.6, 0.8, 1, 1},
                
                -- Font
                font = "Fonts\\ARIALN.TTF", -- Sans-serif default
                fontSize = 10,
                titleFontSize = 13,
                
                -- Display options
                showDividers = true,
                dividerPadding = 0, -- Spacing around dividers
                showButtonBorder = false,
                buttonBorderWidth = 1,
                showGroupNames = true, -- false = just divider lines, true = show group names
                
                -- Details Panel settings (formerly Side Panel)
                detailsPanel = {
                    width = 300,
                    anchor = "RIGHT", -- "RIGHT" or "LEFT" of the main panel
                    fontSize = 10, -- Content font size
                },
                
                -- Position (saved automatically)
                point = "RIGHT",
                relativePoint = "RIGHT",
                xOffset = -50,
                yOffset = 0,
            },
            
            -- Minimap settings
            minimap = {
                hide = false,
            },
        }
    }
end

-- Settings UI Configuration
function DefaultsManager:InitializeSettings()
    if not self.addon then
        error("DefaultsManager: addon reference not set")
        return
    end

    -- Create comprehensive settings options
    local options = {
        name = "Strategy",
        type = "group",
        args = {
            general = self:GetGeneralOptions(),
            strategyPanel = self:GetStrategyPanelOptions(),
            detailsPanel = self:GetDetailsPanelOptions(),
            roleSettings = self:GetRoleOptions(),
            -- combat = self:GetCombatOptions(), -- REMOVED
            -- content = self:GetContentOptions(), -- REMOVED
            profiles = self:GetProfileOptions(),
            testing = self:GetTestingOptions()
        }
    }
    
    -- Register with AceConfig
    AceConfig:RegisterOptionsTable("Strategy", options)
    AceConfigDialog:AddToBlizOptions("Strategy", "Strategy")
    
    if self.addon then
        self.addon:Debug("Settings GUI initialized")
    end
end

-- Helper: General Options
function DefaultsManager:GetGeneralOptions()
    return {
        name = "General Settings",
        type = "group",
        order = 1,
        args = {
            enabled = {
                name = "Enable Strategy",
                desc = "Enable or disable the addon",
                type = "toggle",
                order = 1,
                get = function() return self.addon.db.profile.enabled end,
                set = function(_, value) 
                    self.addon.db.profile.enabled = value
                    if value then
                        -- Re-enabling: show panel if in supported instance and auto-show is enabled
                        if self.addon.InstanceDetector and self.addon.InstanceDetector.isInSupportedInstance then
                            if self.addon.StrategyPanel and self.addon.db.profile.autoShowStrategyPanel then
                                self.addon.StrategyPanel:Show()
                            end
                            -- Re-enable keybinds if panel is visible
                            if self.addon.KeybindManager and self.addon.StrategyPanel and self.addon.StrategyPanel.frame and self.addon.StrategyPanel.frame:IsVisible() then
                                self.addon.KeybindManager:RefreshKeybinds()
                            end
                        end
                    else
                        -- Disabling: hide panel and disable keybinds
                        if self.addon.StrategyPanel then
                            self.addon.StrategyPanel:Hide()
                        end
                        if self.addon.KeybindManager then
                            self.addon.KeybindManager:DisableKeybinds()
                        end
                    end
                end,
            },
            outputMode = {
                name = "Output Channel",
                desc = "Where to output strategies",
                type = "select",
                order = 2,
                values = {
                    instance = "Instance Chat",
                    say = "Say", 
                    self = "Self (Chat Window)",
                    whisper = "Whisper"
                },
                get = function() return self.addon.db.profile.outputMode end,
                set = function(_, value) self.addon.db.profile.outputMode = value end,
            },
            whisperTarget = {
                name = "Whisper Target",
                desc = "Player name to whisper strategies to (when using whisper mode)",
                type = "input",
                order = 3,
                get = function() return self.addon.db.profile.whisperTarget end,
                set = function(_, value) self.addon.db.profile.whisperTarget = value end,
                disabled = function() return self.addon.db.profile.outputMode ~= "whisper" end,
            },
        }
    }
end

-- Helper: Role Options
function DefaultsManager:GetRoleOptions()
    return {
        name = "Role Settings", 
        type = "group",
        order = 4,
        args = {
            roleFilter = {
                name = "Role Filter",
                desc = "Which roles to show strategies for",
                type = "select",
                order = 1,
                values = {
                    auto = "Auto (Based on Spec)",
                    all = "All Roles",
                    tank = "Tank Only",
                    healer = "Healer Only", 
                    dps = "DPS Only"
                },
                get = function() return self.addon.db.profile.roleFilter end,
                set = function(_, value) self.addon.db.profile.roleFilter = value end,
            },

            filtersHeader = {
                type = "header",
                name = "Visibility Overrides",
                order = 10,
            },
            alwaysShowInterrupts = {
                name = "Always Show Interrupts",
                desc = "Always show interrupt instructions regardless of role",
                type = "toggle",
                order = 11,
                get = function() return self.addon.db.profile.alwaysShowInterrupts end,
                set = function(_, value) self.addon.db.profile.alwaysShowInterrupts = value end,
            },
            alwaysShowDispels = {
                name = "Always Show Dispels",
                desc = "Always show dispel instructions regardless of role",
                type = "toggle",
                order = 12,
                get = function() return self.addon.db.profile.alwaysShowDispels end,
                set = function(_, value) self.addon.db.profile.alwaysShowDispels = value end,
            },
        }
    }
end

-- Helper: Combat Options (REMOVED)

-- Helper: Content Options
-- Helper: Content Options (REMOVED - Moved to Main Panel)
-- function DefaultsManager:GetContentOptions() ... end

-- Helper: Details Panel Options
function DefaultsManager:GetDetailsPanelOptions()
    return {
        name = "Details Panel",
        type = "group",
        order = 3,
        args = {
            desc = {
                name = "Customize the persistent details panel (side panel) that displays strategy content.",
                type = "description",
                order = 0,
            },
            anchor = {
                type = "select",
                name = "Anchor Side",
                desc = "Where to attach the details panel relative to the main panel",
                order = 1,
                values = {
                    ["RIGHT"] = "Right",
                    ["LEFT"] = "Left",
                },
                get = function() return self.addon.db.profile.strategyPanel.detailsPanel.anchor end,
                set = function(_, value)
                    self.addon.db.profile.strategyPanel.detailsPanel.anchor = value
                    if self.addon.StrategyPanel then
                        self.addon.StrategyPanel:UpdateSidePanelAnchor()
                    end
                end,
            },
            width = {
                type = "range",
                name = "Width",
                desc = "Width of the details panel",
                order = 2,
                min = 200, max = 500, step = 10,
                get = function() return self.addon.db.profile.strategyPanel.detailsPanel.width end,
                set = function(_, value)
                    self.addon.db.profile.strategyPanel.detailsPanel.width = value
                    if self.addon.StrategyPanel then
                        self.addon.StrategyPanel:UpdateSidePanelAnchor()
                    end
                end,
            },
            fontSize = {
                type = "range",
                name = "Font Size",
                desc = "Size of the strategy text",
                order = 3,
                min = 9, max = 16, step = 1,
                get = function() return self.addon.db.profile.strategyPanel.detailsPanel.fontSize end,
                set = function(_, value)
                    self.addon.db.profile.strategyPanel.detailsPanel.fontSize = value
                    if self.addon.StrategyPanel then
                        self.addon.StrategyPanel:ApplySettings()
                    end
                end,
            },
        },
    }
end

-- Helper: Strategy Panel Options
function DefaultsManager:GetStrategyPanelOptions()
    return {
        name = "Strategy Panel",
        type = "group",
        order = 2, 
        args = {
            panelDescription = {
                name = "The Strategy Panel is the recommended interface for announcing strategies.\nIt uses buttons and keybinds (1-0) instead of targeting/mouseover.",
                type = "description",
                order = 0,
            },
            openPanel = {
                name = "Open Strategy Panel",
                desc = "Opens the Strategy Panel",
                type = "execute",
                order = 1,
                func = function()
                    if self.addon.StrategyPanel then
                        self.addon.StrategyPanel:Show()
                    else
                        self.addon:Print("Strategy Panel not available")
                    end
                end,
            },
            autoShowPanel = {
                name = "Auto-Show Panel in Dungeons",
                desc = "Automatically show the Strategy Panel when entering a dungeon instance",
                type = "toggle",
                order = 2,
                get = function() return self.addon.db.profile.autoShowStrategyPanel end,
                set = function(_, value) self.addon.db.profile.autoShowStrategyPanel = value end,
            },
            autoHidePanel = {
                name = "Auto-Hide Panel Outside Dungeons",
                desc = "Automatically hide the Strategy Panel when leaving a dungeon instance",
                type = "toggle",
                order = 3,
                get = function() return self.addon.db.profile.autoHideStrategyPanel end,
                set = function(_, value) self.addon.db.profile.autoHideStrategyPanel = value end,
            },
            resetAnnounced = {
                name = "Reset Announced Strategies",
                desc = "Clear the list of announced strategies (un-dim all buttons)",
                type = "execute",
                order = 4,
                func = function()
                    if self.addon.StrategyPanel then
                        self.addon.StrategyPanel:ResetAnnounced()
                        self.addon:Print("Reset announced strategies.")
                    end
                end,
            },
            panelStyling = {
                name = "Panel Appearance",
                type = "group",
                order = 5,
                inline = true,
                args = {
                    panelWidth = {
                        type = "range",
                        name = "Panel Width",
                        desc = "Width of the Strategy Panel",
                        order = 1,
                        min = 200,
                        max = 500,
                        step = 10,
                        get = function() return self.addon.db.profile.strategyPanel.width end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.width = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    panelMaxHeight = {
                        type = "range",
                        name = "Max Height",
                        desc = "Maximum height of the Strategy Panel",
                        order = 2,
                        min = 200,
                        max = 800,
                        step = 25,
                        get = function() return self.addon.db.profile.strategyPanel.maxHeight end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.maxHeight = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    buttonHeight = {
                        type = "range",
                        name = "Button Height",
                        desc = "Height of strategy buttons",
                        order = 3,
                        min = 20,
                        max = 40,
                        step = 2,
                        get = function() return self.addon.db.profile.strategyPanel.buttonHeight end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.buttonHeight = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    padding = {
                        type = "range",
                        name = "Padding",
                        desc = "Padding around content",
                        order = 4,
                        min = 0,
                        max = 10,
                        step = 2,
                        get = function() return self.addon.db.profile.strategyPanel.padding end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.padding = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    buttonSpacing = {
                        type = "range",
                        name = "Button Spacing",
                        desc = "Spacing between buttons",
                        order = 5,
                        min = 0,
                        max = 10,
                        step = 1,
                        get = function() return self.addon.db.profile.strategyPanel.buttonSpacing end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.buttonSpacing = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    fontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Size of button text",
                        order = 6,
                        min = 9,
                        max = 16,
                        step = 1,
                        get = function() return self.addon.db.profile.strategyPanel.fontSize end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.fontSize = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    backgroundOpacity = {
                        type = "range",
                        name = "Background Opacity",
                        desc = "Transparency of panel background",
                        order = 7,
                        min = 0.3,
                        max = 1.0,
                        step = 0.05,
                        get = function() return self.addon.db.profile.strategyPanel.backgroundColor[4] end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.backgroundColor[4] = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    showGroupNames = {
                        type = "toggle",
                        name = "Show Group Names",
                        order = 8,
                        get = function() return self.addon.db.profile.strategyPanel.showGroupNames end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.showGroupNames = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:RebuildContent()
                            end
                        end,
                    },
                    dividerHeader = {
                        type = "header",
                        name = "Dividers",
                        order = 11,
                    },
                    showDividers = {
                        type = "toggle",
                        name = "Show Dividers",
                        desc = "Show divider lines between groups",
                        order = 12,
                        get = function() return self.addon.db.profile.strategyPanel.showDividers end,
                        set = function(_, value) 
                            self.addon.db.profile.strategyPanel.showDividers = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:RebuildContent()
                            end
                        end,
                    },
                    dividerThickness = {
                        type = "range",
                        name = "Divider Thickness",
                        order = 13,
                        min = 1, max = 5, step = 1,
                        get = function() return self.addon.db.profile.strategyPanel.dividerThickness end,
                        set = function(_, value)
                            self.addon.db.profile.strategyPanel.dividerThickness = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:RebuildContent()
                            end
                        end,
                    },
                    dividerPadding = {
                        type = "range",
                        name = "Divider Spacing",
                        order = 14,
                        min = 0, max = 10, step = 2,
                        get = function() return self.addon.db.profile.strategyPanel.dividerPadding end,
                        set = function(_, value)
                            self.addon.db.profile.strategyPanel.dividerPadding = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:RebuildContent()
                            end
                        end,
                    },
                    borderHeader = {
                        type = "header",
                        name = "Borders",
                        order = 15,
                    },
                    showButtonBorder = {
                        type = "toggle",
                        name = "Show Button Borders",
                        order = 16,
                        get = function() return self.addon.db.profile.strategyPanel.showButtonBorder end,
                        set = function(_, value)
                            self.addon.db.profile.strategyPanel.showButtonBorder = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                    buttonBorderWidth = {
                        type = "range",
                        name = "Border Width",
                        order = 17,
                        min = 1, max = 4, step = 1,
                        get = function() return self.addon.db.profile.strategyPanel.buttonBorderWidth end,
                        set = function(_, value)
                            self.addon.db.profile.strategyPanel.buttonBorderWidth = value
                            if self.addon.StrategyPanel then
                                self.addon.StrategyPanel:ApplySettings()
                            end
                        end,
                    },
                },
            },
        }
    }
end

-- Helper: Profile Options
function DefaultsManager:GetProfileOptions()
    return {
        name = "Profiles",
        type = "group",
        order = 7,
        args = {
            desc = {
                name = "Profiles allow you to have different configurations for different characters or situations.",
                type = "description",
                order = 1,
            },
            choose = {
                name = "Current Profile",
                desc = "Select a profile to use",
                type = "select",
                order = 2,
                get = function() return self.addon.db:GetCurrentProfile() end,
                set = function(_, value) self.addon.db:SetProfile(value) end,
                values = function()
                    local profiles = {}
                    for _, profile in ipairs(self.addon.db:GetProfiles()) do
                        profiles[profile] = profile
                    end
                    return profiles
                end,
            },
            new = {
                name = "New Profile",
                desc = "Create a new profile",
                type = "input",
                order = 3,
                get = function() return "" end,
                set = function(_, value)
                    if value and value:trim() ~= "" then
                        self.addon.db:SetProfile(value)
                        self.addon:Print("Created and switched to profile: " .. value)
                    end
                end,
            },
            copy = {
                name = "Copy From",
                desc = "Copy settings from another profile",
                type = "select",
                order = 4,
                get = function() return "" end,
                set = function(_, value)
                    if value and value ~= "" then
                        self.addon.db:CopyProfile(value)
                        self.addon:Print("Copied settings from profile: " .. value)
                    end
                end,
                values = function()
                    local profiles = {}
                    for _, profile in ipairs(self.addon.db:GetProfiles()) do
                        if profile ~= self.addon.db:GetCurrentProfile() then
                            profiles[profile] = profile
                        end
                    end
                    return profiles
                end,
            },
            delete = {
                name = "Delete Profile",
                desc = "Delete the current profile (cannot delete the last profile)",
                type = "execute",
                order = 5,
                func = function()
                    local current = self.addon.db:GetCurrentProfile()
                    local profiles = self.addon.db:GetProfiles()
                    if #profiles > 1 then
                        self.addon.db:DeleteProfile(current)
                        self.addon:Print("Deleted profile: " .. current)
                    else
                        self.addon:Print("Cannot delete the last profile")
                    end
                end,
                confirm = true,
                confirmText = "Are you sure you want to delete this profile?",
            },
            reset = {
                name = "Reset Profile",
                desc = "Reset the current profile to default settings",
                type = "execute",
                order = 6,
                func = function()
                    self.addon.db:ResetProfile()
                    self.addon:Print("Profile reset to defaults")
                end,
                confirm = true,
                confirmText = "Are you sure you want to reset this profile to defaults?",
            },
        }
    }
end

-- Helper: Testing Options
function DefaultsManager:GetTestingOptions()
    return {
        name = "Testing & Debug",
        type = "group",
        order = 8,
        args = {
            debugMode = {
                name = "Debug Mode", 
                desc = "Enable debug messages",
                type = "toggle",
                order = 1,
                get = function() return self.addon.db.profile.debugMode end,
                set = function(_, value) self.addon.db.profile.debugMode = value end,
            },
            testButton = {
                name = "Test Random Boss",
                desc = "Test the addon with a random boss",
                type = "execute",
                order = 2,
                func = function() self.addon:TestRandomBoss() end,
            },
            resetTracker = {
                name = "Reset Output Tracker",
                desc = "Reset the tracker that prevents duplicate announcements",
                type = "execute",
                order = 3,
                func = function() 
                    self.addon.outputTracker = {}
                    self.addon:Print("Output tracker reset")
                end,
            },
        }
    }
end

-- Settings panel opener
function DefaultsManager:OpenSettings()
    if not self.addon then
        error("DefaultsManager: addon reference not set")
        return
    end

    self.addon:Debug("OpenSettings called")
    
    -- Try modern WoW settings first
    if Settings and Settings.OpenToCategory then
        self.addon:Debug("Using modern Settings.OpenToCategory")
        Settings.OpenToCategory("Strategy")
    -- Try legacy interface options
    elseif InterfaceOptionsFrame_OpenToCategory then
        self.addon:Debug("Using legacy InterfaceOptionsFrame_OpenToCategory")
        InterfaceOptionsFrame_OpenToCategory("Strategy")
        InterfaceOptionsFrame_OpenToCategory("Strategy") -- Call twice for proper focus
    -- AceConfigDialog as fallback
    else
        self.addon:Debug("Using AceConfigDialog fallback")
        AceConfigDialog:Open("Strategy")
    end
end

-- LibDataBroker Integration  
function DefaultsManager:InitializeDataBroker()
    if not self.addon then
        error("DefaultsManager: addon reference not set")
        return
    end

    -- Only initialize if libraries are available
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    
    if not LDB or not LibDBIcon then
        self.addon:Debug("LibDataBroker or LibDBIcon not available - skipping minimap icon")
        return
    end
    
    -- Create LibDataBroker object
    self.addon.ldb = LDB:NewDataObject("Strategy", {
        type = "launcher",
        text = "Strategy",
        icon = "Interface\\Icons\\Achievement_Boss_Kingymiron",
        OnClick = function(clickedframe, button)
            if button == "LeftButton" then
                self:OpenSettings()
            elseif button == "RightButton" then
                self.addon:TestRandomBoss()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("Strategy")
            tooltip:AddLine("|cffFFFFFFLeft-click|r to open settings", 0.2, 1, 0.2, 1)
            tooltip:AddLine("|cffFFFFFFRight-click|r to test random boss", 0.2, 1, 0.2, 1)
            
            local status = self.addon.DatabaseManager:GetInstanceStatus()
            if status.loadedInstance then
                tooltip:AddLine(" ")
                tooltip:AddLine("|cffFFD700Current Instance:|r " .. status.loadedInstance, 1, 1, 1, 1)
                tooltip:AddLine("|cffFFD700Strategies Loaded:|r " .. status.encounterCount, 1, 1, 1, 1)
            end
        end,
    })
    
    -- Create minimap icon
    LibDBIcon:Register("Strategy", self.addon.ldb, self.addon.db.profile.minimap)
    
    self.addon:Debug("Data broker and minimap icon initialized")
end

-- Make the module globally accessible
_G["StrategyDefaultsManager"] = DefaultsManager
