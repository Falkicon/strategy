--[[
    StrategyPanel.lua
    Main Strategy Panel UI for Strategy addon (Midnight-compatible)
    
    Responsibilities:
    - Display strategy panel with instance-specific strategies
    - Handle sidebar for detailed content display (replaces tooltips)
    - Support tabbed content for multi-phase strategies
    - Handle announcement via side panel
]]--

local AceAddon = LibStub("AceAddon-3.0")
local StrategyPanel = {}

-- Local references
local CreateFrame = CreateFrame
local PlaySound = PlaySound

-- Panel state
StrategyPanel.frame = nil
StrategyPanel.sidePanel = nil
StrategyPanel.selectedStrategyId = nil
StrategyPanel.instanceData = nil
StrategyPanel.strategies = {}
StrategyPanel.announcedStrategies = {}
StrategyPanel.strategyButtons = {}
StrategyPanel.groupHeaders = {}
StrategyPanel.addon = nil

--[[
    Get panel settings
]]
function StrategyPanel:GetSettings()
    if self.addon and self.addon.db and self.addon.db.profile and self.addon.db.profile.strategyPanel then
        return self.addon.db.profile.strategyPanel
    end
    -- Fallbacks
    return {
        width = 300,
        backgroundColor = {0.1, 0.1, 0.1, 0.9},
        borderColor = {0.3, 0.3, 0.3, 1},
        detailsPanel = { width = 300, anchor = "RIGHT", fontSize = 12 },
        padding = 10,
        buttonHeight = 28,
        font = "Fonts\\ARIALN.TTF",
    }
end

--[[
    Initialize the Strategy Panel
]]
function StrategyPanel:Initialize(addon)
    self.addon = addon
    self:CreateMainFrame()
    -- Side panel created on demand or with main frame
    self:CreateSidePanel() 
    
    if addon then
        addon:Debug("StrategyPanel: Initialized")
    end
end

--[[
    UI Helper: Apply standard backdrop
]]
function StrategyPanel:ApplyBackdrop(frame, bgColor, borderColor, edgeSize)
    edgeSize = edgeSize or 1
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
    }
    
    if edgeSize > 0 then
        backdrop.edgeFile = "Interface\\Buttons\\WHITE8x8"
        backdrop.edgeSize = edgeSize
    end
    
    frame:SetBackdrop(backdrop)
    
    if bgColor then 
        frame:SetBackdropColor(unpack(bgColor))
    else
        frame:SetBackdropColor(0, 0, 0, 0) -- Default transparent
    end
    
    if edgeSize > 0 then
        if borderColor then 
            frame:SetBackdropBorderColor(unpack(borderColor)) 
        else
            frame:SetBackdropBorderColor(0, 0, 0, 0) -- Default transparent
        end
    end
end

--[[
    UI Helper: Create standard title bar
]]
function StrategyPanel:CreateTitleBar(parent, title, icon)
    local settings = self:GetSettings()
    local titleBar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    titleBar:SetHeight(settings.titleBarHeight or 28)
    titleBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    
    self:ApplyBackdrop(titleBar, settings.titleBarColor or {0,0,0,0}, nil, 0)
    
    -- Icon
    if icon then
        local iconTexture = titleBar:CreateTexture(nil, "OVERLAY")
        iconTexture:SetSize(16, 16)
        iconTexture:SetPoint("LEFT", titleBar, "LEFT", settings.padding, 0)
        iconTexture:SetTexture(icon)
        titleBar.icon = iconTexture
    end
    
    -- Text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetFont(settings.font, 12, "OUTLINE") -- Force Sans-Serif
    if icon then
        titleText:SetPoint("LEFT", titleBar.icon, "RIGHT", 6, 0)
    else
        titleText:SetPoint("LEFT", titleBar, "LEFT", settings.padding, 0)
    end
    titleText:SetPoint("RIGHT", titleBar, "RIGHT", -30, 0) -- Constraint against Close Button
    titleText:SetJustifyH("LEFT")
    titleText:SetWordWrap(false)
    titleText:SetText(title)
    titleText:SetTextColor(1, 0.82, 0, 1) -- Gold title
    titleBar.text = titleText
    
    return titleBar
end

--[[
    UI Helper: Create standard close button
]]
function StrategyPanel:CreateCloseButton(parent, callback)
    local closeBtn = CreateFrame("Button", nil, parent)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
    closeBtn:SetNormalFontObject("GameFontNormalSmall")
    local fontString = closeBtn:GetFontString()
    if fontString then
        fontString:SetFont(self:GetSettings().font, 10, "OUTLINE")
    end
    closeBtn:SetText("X")
    if callback then
        closeBtn:SetScript("OnClick", callback)
    end
    return closeBtn
end

--[[
    UI Helper: Create standard action button
]]
function StrategyPanel:CreateActionButton(parent, text, callback, width, colorTheme)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 80, 22)
    
    local bgColor = colorTheme and colorTheme.bg or {0.3, 0.3, 0.3, 1}
    local borderColor = colorTheme and colorTheme.border or {0.4, 0.4, 0.4, 1}
    
    self:ApplyBackdrop(btn, bgColor, borderColor, 1)
    
    btn:SetNormalFontObject("GameFontNormalSmall")
    -- Access the font string directly to set font without modifying the global object
    local fontString = btn:GetFontString()
    if fontString then
        fontString:SetFont(self:GetSettings().font, 10, "OUTLINE")
    end
    btn:SetText(text)
    
    if callback then
        btn:SetScript("OnClick", callback)
    end
    
    -- Hover effect
    btn:SetScript("OnEnter", function(b) 
        b:SetBackdropColor(unpack(colorTheme and colorTheme.hover or {0.4, 0.4, 0.4, 1})) 
    end)
    btn:SetScript("OnLeave", function(b) 
        b:SetBackdropColor(unpack(bgColor)) 
    end)
    
    return btn
end

--[[
    UI Helper: Create standard footer container
]]
function StrategyPanel:CreatePanelFooter(parent, height)
    local footer = CreateFrame("Frame", nil, parent)
    footer:SetHeight(height or 32)
    footer:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    return footer
end

--[[
    Create the main panel frame
    (Refactored to use helper methods)
]]

function StrategyPanel:CreateMainFrame()
    if self.frame then return end
    
    local settings = self:GetSettings()
    
    -- Main frame
    local frame = CreateFrame("Frame", "StrategyPanelFrame", UIParent, "BackdropTemplate")
    frame:SetSize(settings.width, 150)
    frame:SetPoint(settings.point or "RIGHT", UIParent, settings.relativePoint or "RIGHT", settings.xOffset or -50, settings.yOffset or 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(100)
    
    self:ApplyBackdrop(frame, settings.backgroundColor, settings.borderColor, 1)
    
    -- Title bar
    local titleBar = self:CreateTitleBar(frame, "Strategy", "Interface\\Icons\\Ability_Warrior_BattleShout")
    
    -- Drag handlers
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() 
        frame:StopMovingOrSizing() 
        self:SavePosition()
    end)
    frame.titleBar = titleBar
    frame.titleText = titleBar.text
    
    -- Close button
    self:CreateCloseButton(titleBar, function() self:Hide() end)
    
    -- Content container
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    local topPadding = (settings.titleBarHeight or 28) + settings.padding
    local bottomPadding = (settings.footerHeight or 32) + settings.padding
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", settings.padding, -topPadding)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -settings.padding - 20, bottomPadding)
    frame.scrollFrame = scrollFrame
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(settings.width - settings.padding * 2 - 20, 10)
    scrollFrame:SetScrollChild(content)
    frame.content = content
    
    -- Footer
    local footer = self:CreatePanelFooter(frame, settings.footerHeight or 32)
    
    -- Reset Button
    local resetBtn = self:CreateActionButton(footer, "Reset All", function() self:ResetAnnounced() end, 80)
    resetBtn:SetPoint("LEFT", footer, "LEFT", settings.padding, 0)
    
    -- Include Trash Checkbox
    local trashCheck = CreateFrame("CheckButton", nil, footer, "UICheckButtonTemplate")
    trashCheck:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    trashCheck:SetSize(20, 20)
    
    local trashText = trashCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    trashText:SetFont(settings.font, 10, "OUTLINE")
    trashText:SetPoint("LEFT", trashCheck, "RIGHT", 4, 1)
    trashText:SetText("Include Trash")
    trashText:SetTextColor(0.8, 0.8, 0.8)
    
    trashCheck:SetScript("OnClick", function(cb)
        local checked = cb:GetChecked()
        if self.addon and self.addon.db then
            self.addon.db.profile.includeTrashMobs = checked
            self:RebuildContent()
        end
    end)
    
    -- Sync initial state
    if self.addon and self.addon.db then
        trashCheck:SetChecked(self.addon.db.profile.includeTrashMobs)
    end
    self.trashCheck = trashCheck
    
    self.frame = frame
    self:LoadPosition()
    frame:Hide()
end

--[[
    Create the Side Panel
]]
--[[
    Create the Side Panel
]]
function StrategyPanel:CreateSidePanel()
    if self.sidePanel then return end
    
    local settings = self:GetSettings()
    local sideSettings = settings.detailsPanel or { width = 300, anchor = "RIGHT", fontSize = 12 }
    
    local panel = CreateFrame("Frame", "StrategySidePanel", self.frame, "BackdropTemplate")
    panel:SetSize(sideSettings.width, 300) -- H will match main frame
    panel:SetFrameStrata("MEDIUM")
    panel:SetFrameLevel(100)
    
    self:ApplyBackdrop(panel, settings.backgroundColor, settings.borderColor, 1)
    
    -- Title Bar (Consistent with Main Frame)
    local titleBar = self:CreateTitleBar(panel, "Strategy Detail", nil)
    panel.titleBar = titleBar
    panel.titleText = titleBar.text
    
    -- Close button
    self:CreateCloseButton(titleBar, function() self:CloseSidePanel() end)
    
    -- Tab Bar (Container)
    local tabBar = CreateFrame("Frame", nil, panel)
    tabBar:SetHeight(24)
    tabBar:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -5)
    tabBar:SetPoint("RIGHT", panel, "RIGHT", -10, 0)
    panel.tabBar = tabBar
    panel.tabs = {} -- Pool of tab buttons
    
    -- Content Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 40) -- Space for footer
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(sideSettings.width - 40, 100)
    scrollFrame:SetScrollChild(content)
    panel.scrollFrame = scrollFrame
    panel.content = content
    
    -- Announce Button (Footer)
    local footer = self:CreatePanelFooter(panel, settings.footerHeight or 32)
    
    local greenTheme = {
        bg = {0, 0.6, 0, 1},
        border = {0, 0.8, 0, 1},
        hover = {0, 0.7, 0, 1}
    }
    
    local announceBtn = self:CreateActionButton(footer, "Announce to Chat", function()
        if self.currentStrategy then
            self:AnnounceStrategy(self.currentStrategy)
        end
    end, 120, greenTheme)
    
    announceBtn:SetPoint("LEFT", footer, "LEFT", settings.padding, 0)
    panel.announceBtn = announceBtn
    
    self.sidePanel = panel
    self:UpdateSidePanelAnchor()
    panel:Hide()
end

--[[
    Update anchor of side panel based on settings
]]
function StrategyPanel:UpdateSidePanelAnchor()
    if not self.sidePanel or not self.frame then return end
    local settings = self:GetSettings()
    local sideSettings = settings.detailsPanel or { width = 300, anchor = "RIGHT", fontSize = 12 }
    
    self.sidePanel:ClearAllPoints()
    self.sidePanel:SetWidth(sideSettings.width)
    
    -- Update height to match main frame
    self.sidePanel:SetHeight(self.frame:GetHeight())
    
    -- Anchor to main frame
    if sideSettings.anchor == "LEFT" then
        self.sidePanel:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", -2, 0)
        self.sidePanel:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", -2, 0)
    else
        self.sidePanel:SetPoint("TOPLEFT", self.frame, "TOPRIGHT", 2, 0)
        self.sidePanel:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMRIGHT", 2, 0)
    end

    -- FIX: Update content width to ensure text wrapping works when resizing
    if self.sidePanel.content then
        self.sidePanel.content:SetWidth(sideSettings.width - 40)
    end
end

--[[
    Close the side panel and clear selection
]]
function StrategyPanel:CloseSidePanel()
    if self.sidePanel then
        self.sidePanel:Hide()
    end
    self.selectedStrategyId = nil
    self:RefreshButtonStates()
end

--[[
    Refresh visual state of main list buttons (highlight selected)
]]
function StrategyPanel:RefreshButtonStates()
    local settings = self:GetSettings()
    local showBorder = settings.showButtonBorder
    local defaultBorderColor = showBorder and settings.borderColor or {0, 0, 0, 0}
    
    for id, btn in pairs(self.strategyButtons) do
        local isSelected = (id == self.selectedStrategyId)
        local isAnnounced = self.announcedStrategies[id]
        
        -- Reset base color
        if isAnnounced then
            btn:SetBackdropColor(unpack(settings.buttonAnnouncedColor))
            btn:SetAlpha(0.5)
        else
            btn:SetBackdropColor(unpack(settings.buttonColor))
            btn:SetAlpha(1.0)
        end
        
        -- Selection highlight (Gold border)
        -- If borders are disabled, we still show selection border as important feedback
        if isSelected then
            btn:SetBackdropBorderColor(1, 0.82, 0, 1)
        else
            btn:SetBackdropBorderColor(unpack(defaultBorderColor))
        end
    end
end

--[[
    Open/Update side panel with content
]]
function StrategyPanel:OpenStrategy(strategy)
    if not strategy then return end
    
    self.selectedStrategyId = strategy.id
    self.currentStrategy = strategy
    self:RefreshButtonStates()
    
    local panel = self.sidePanel
    panel:Show()
    self:UpdateSidePanelAnchor() -- Ensure size/pos match
    
    -- Set Title
    panel.titleText:SetText(strategy.name)
    
    -- Handle Content & Tabs
    -- Check if strategy has tabs (new format) or flat structure (legacy)
    local tabsData = nil
    if strategy.tabs then
        tabsData = strategy.tabs
    else
        -- Convert flat structure to single "General" tab
        tabsData = {
            { name = "General", content = strategy.strategy or {} }
        }
    end
    
    self:SetupTabs(tabsData)
end

--[[
    Setup tabs for the side panel
]]
function StrategyPanel:SetupTabs(tabsData)
    local panel = self.sidePanel
    local tabBar = panel.tabBar
    
    -- Hide existing tabs
    for _, tab in pairs(panel.tabs) do tab:Hide() end
    
    local activeTab = nil
    local prevTab = nil
    
    for i, tabData in ipairs(tabsData) do
        local tab = panel.tabs[i]
        if not tab then
            tab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
            tab:SetHeight(20)
            tab:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
            
            local t = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            t:SetPoint("CENTER")
            t:SetFont(self:GetSettings().font, 10, "OUTLINE") -- Use configured font
            tab.text = t
            
            panel.tabs[i] = tab
        end
        
        -- Always update click handler with current tabsData closure
        tab:SetScript("OnClick", function() self:SelectTab(i, tabsData) end)
        
        tab.text:SetText(tabData.name)
        tab:SetWidth(tab.text:GetStringWidth() + 14)
        tab:Show()
        
        -- Anchor
        if prevTab then
            tab:SetPoint("LEFT", prevTab, "RIGHT", 4, 0)
        else
            tab:SetPoint("LEFT", tabBar, "LEFT", 0, 0)
        end
        prevTab = tab
    end
    
    -- Toggle Tab Bar visibility
    if #tabsData > 1 then
        tabBar:Show()
        -- Adjust scrollframe anchor or height if needed? 
        -- For now, layout relies on fixed anchor to tabBar, which works even if hidden (space preserved).
        -- To collapse space we would need to dynamically re-anchor scrollFrame.
    else
        tabBar:Hide()
    end
    
    -- Select first tab by default (renders content)
    self:SelectTab(1, tabsData)
end

--[[
    Handle Tab Selection and Render Content
]]
function StrategyPanel:SelectTab(index, tabsData)
    local panel = self.sidePanel
    local settings = self:GetSettings()
    local sideSettings = settings.detailsPanel or { width = 300, anchor = "RIGHT", fontSize = 12 }
    
    -- Update Tab Visuals
    for i, tab in ipairs(panel.tabs) do
        if i == index then
            tab:SetBackdropColor(0.3, 0.3, 0.3, 1) -- Active
            tab.text:SetTextColor(1, 1, 1, 1)
        else
            tab:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Inactive
            tab.text:SetTextColor(0.6, 0.6, 0.6, 1)
        end
    end
    
    -- Determine Visibility based on Role Settings
    local roleFilter = self.addon.db.profile.roleFilter or "auto"
    local alwaysShowInterrupts = self.addon.db.profile.alwaysShowInterrupts
    local alwaysShowDispels = self.addon.db.profile.alwaysShowDispels
    
    local visibleRoles = { all = true } -- Everyone sees [A] ALL
    local effectiveRole = "ALL" -- Default to showing everything if "all"
    
    -- Resolve effective role
    if roleFilter == "all" then
        effectiveRole = "ALL"
    elseif roleFilter == "auto" then
        -- Auto-detect
        local ptrRole = "DAMAGER" -- fallback
        if GetSpecialization then
            local spec = GetSpecialization()
            if spec then
                ptrRole = GetSpecializationRole(spec)
            end
        end
        effectiveRole = ptrRole
    elseif roleFilter == "tank" then
        effectiveRole = "TANK"
    elseif roleFilter == "healer" then
        effectiveRole = "HEALER"
    elseif roleFilter == "dps" then
        effectiveRole = "DAMAGER"
    end
    
    -- Set visibilities
    if effectiveRole == "ALL" then
        visibleRoles.tank = true
        visibleRoles.dps = true
        visibleRoles.healer = true
        visibleRoles.interrupt = true
        visibleRoles.dispel = true
    elseif effectiveRole == "TANK" then
        visibleRoles.tank = true
        visibleRoles.interrupt = true
    elseif effectiveRole == "DAMAGER" then
        visibleRoles.dps = true
        visibleRoles.interrupt = true
    elseif effectiveRole == "HEALER" then
        visibleRoles.healer = true
        visibleRoles.dispel = true
    end
    
    -- Apply Overrides
    if alwaysShowInterrupts then
        visibleRoles.interrupt = true
    end
    if alwaysShowDispels then
        visibleRoles.dispel = true
    end
    
    -- Render Content
    local contentFrame = panel.content
    -- Clear existing content
    for _, child in pairs({contentFrame:GetRegions()}) do
        if child:GetObjectType() == "FontString" then child:Hide() end
    end
    
    local strategyContent = tabsData[index].content
    local yOffset = 0 -- Reduced from -5 to remove "big chunk" of top space
    
    -- Dynamic Role Order Logic
    -- Request: "If all roles are on, put the tank roll at top, then interupts, then dispells, all, then the other rolls"
    -- Request: "always sort the strat as role, interupts, dispells, all"
    local roleOrder = {}
    
    if roleFilter == "all" then
        -- Specific requested order for ALL
        roleOrder = {"tank", "interrupt", "dispel", "all", "dps", "healer"}
    else
        -- Filtered View: Active Role -> Interrupt -> Dispel -> All
        -- We determine the "Primary" role based on filter
        local primaryRole = nil
        if roleFilter == "tank" then primaryRole = "tank"
        elseif roleFilter == "dps" then primaryRole = "dps"
        elseif roleFilter == "healer" then primaryRole = "healer"
        elseif roleFilter == "auto" then
            -- Map effectiveRole (TANK/DAMAGER/HEALER) back to key
            if effectiveRole == "TANK" then primaryRole = "tank"
            elseif effectiveRole == "HEALER" then primaryRole = "healer"
            elseif effectiveRole == "DAMAGER" then primaryRole = "dps" 
            else primaryRole = "tank" end -- Fallback
        end
        
        roleOrder = {primaryRole, "interrupt", "dispel", "all"}
    end
    local roleLabels = {
        interrupt = "|cffff4444[INT]|r",
        dispel = "|cff44ff44[DISP]|r", 
        tank = "|cff4444ff[TANK]|r",
        dps = "|cffff4444[DPS]|r",
        healer = "|cff44ff44[HEAL]|r",
        all = "|cffffff00[ALL]|r"
    }
    
    local width = contentFrame:GetWidth()
    
    for _, role in ipairs(roleOrder) do
        -- ONLY show if visible for current role settings
        if visibleRoles[role] then
            local lines = strategyContent[role]
            if lines and #lines > 0 then
                -- Role Header
                local header = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)
                header:SetWidth(width - 10)
                header:SetJustifyH("LEFT")
                header:SetText(roleLabels[role])
                header:SetFont(settings.font, (sideSettings.fontSize or 10) + 1, "OUTLINE") -- Use configured font + 1
                header:Show()
                yOffset = yOffset - (sideSettings.fontSize or 10) - 4
                
                -- Lines
                for _, line in ipairs(lines) do
                    local text = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    -- Reduced indent from 15 to 8
                    text:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, yOffset)
                    text:SetWidth(width - 13) -- Adjusted width constraint accordingly
                    text:SetJustifyH("LEFT")
                    -- FIX: Enable text wrapping
                    text:SetWordWrap(true)
                    
                    text:SetText("• " .. line)
                    text:SetFont(settings.font, sideSettings.fontSize or 10, "OUTLINE") -- Use configured font
                    text:SetTextColor(0.8, 0.8, 0.8, 1)
                    text:Show()
                    
                    local h = text:GetStringHeight()
                    yOffset = yOffset - h - 4
                end
                yOffset = yOffset - 8
            end
        end
    end
    
    -- Resize content frame
    contentFrame:SetHeight(math.abs(yOffset))
end

--[[
    Create a strategy button (Updated for new interaction)
]]
function StrategyPanel:CreateStrategyButton(parent, strategy, index)
    local settings = self:GetSettings()
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetHeight(settings.buttonHeight)
    
    -- FIX: Apply Border Settings
    local edgeSize = settings.buttonBorderWidth or 1
    local borderColor = settings.showButtonBorder and settings.borderColor or {0, 0, 0, 0}
    
    self:ApplyBackdrop(btn, settings.buttonColor, borderColor, edgeSize)
    
    btn.strategy = strategy
    
    local nameText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", btn, "LEFT", 8, 0)
    nameText:SetPoint("RIGHT", btn, "RIGHT", -30, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetFont(settings.font, settings.fontSize, "OUTLINE")
    nameText:SetTextColor(unpack(settings.textColor))
    nameText:SetText(strategy.name or "Unknown")
    btn.nameText = nameText
    
    -- Status text
    local statusText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetFont(settings.font, settings.fontSize - 2, "OUTLINE")
    statusText:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
    statusText:SetText("")
    btn.statusText = statusText
    
    -- Click -> Open Side Panel
    btn:SetScript("OnClick", function()
        self:OpenStrategy(strategy)
    end)
    
    -- Hover -> Visual feedback only (no tooltip)
    btn:SetScript("OnEnter", function(b)
        if b.strategy.id ~= self.selectedStrategyId then
            b:SetBackdropColor(unpack(settings.buttonHighlightColor or {0.3, 0.3, 0.3, 1}))
        end
    end)
    btn:SetScript("OnLeave", function(b)
         self:RefreshButtonStates() -- Reset to correct state
    end)
    
    return btn
end

--[[
    Announce a strategy to chat (Called from Side Panel button)
]]
function StrategyPanel:AnnounceStrategy(strategy)
    if not strategy then return end
    
    -- If using tabs, flatten current content? Or announce all?
    -- V2 Simplification: Announce the legacy flat content if available,
    -- or construct announcable text from current view?
    -- For now, let's assume flat strategy output or announce active tab if implemented later.
    -- To keep it safe, we'll announce the "General" content if flat, or first tab.
    
    local contentToAnnounce = strategy.strategy
    if strategy.tabs then
        -- TODO: support announcing specific tabs. For now, announce first tab.
        contentToAnnounce = strategy.tabs[1].content
    end

    local success = self.addon:OutputStrategy(strategy.name, contentToAnnounce)
    if success then
        self:MarkAnnounced(strategy.id)
    end
end

function StrategyPanel:MarkAnnounced(strategyId)
    self.announcedStrategies[strategyId] = true
    self:RefreshButtonStates()
    
    -- Update status text on button if visible
    local btn = self.strategyButtons[strategyId]
    if btn and btn.statusText then
        btn.statusText:SetTextColor(0.5, 0.7, 0.5, 1)
        btn.statusText:SetText("Done")
    end
end

function StrategyPanel:ResetAnnounced()
    self.announcedStrategies = {}
    self:CloseSidePanel() -- Reset closes selection too
    self:RefreshButtonStates()
    
    for _, btn in pairs(self.strategyButtons) do
        if btn.statusText then btn.statusText:SetText("") end
    end
end

-- ... [Keep existing helper functions like LoadInstance, RebuildContent, etc. but update them to use new styles] ...

-- Helper utility for content rebuilding (simplified from previous)
function StrategyPanel:RebuildContent()
    -- Standard rebuild implementation ...
    -- (Keeping the logic from previous version but ensuring it uses CreateStrategyButton)
    -- To save context space, I will delegate to existing logic if mostly valid, but here I'm overwriting.
    -- So I must provide the implementation:
    
    self:ClearContent() -- Clear old buttons
    if not self.frame or not self.strategies then return end
    
    local settings = self:GetSettings()
    local content = self.frame.content
    local yOffset = 0
    local currentGroup = nil
    
     -- Build group display names map
    local groupDisplayNames = {}
    for _, strat in ipairs(self.strategies) do
        local group = strat.group or "Ungrouped"
        if not groupDisplayNames[group] then
            if group:match("^Boss %d+$") then
                 groupDisplayNames[group] = strat.name or group
            else
                 groupDisplayNames[group] = group
            end
        end
    end

    local buttonSpacing = settings.buttonSpacing or 2
    local includeTrash = self.addon.db.profile.includeTrashMobs

    for i, strategy in ipairs(self.strategies) do
        local group = strategy.group or "Ungrouped"
        
        -- Filter Trash if disabled
        -- We identify trash based on 'TRASH' in the group name (new convention)
        local isTrash = group:match("TRASH")
        if includeTrash or not isTrash then
            
        -- Header logic
        if group ~= currentGroup then
             yOffset = yOffset + (settings.dividerPadding or 4)
             
             local displayName = groupDisplayNames[group] or group
             local showName = settings.showGroupNames
             local showLine = settings.showDividers
             
             -- FIX: Only create divider if showName or showLine is true
             if showName or showLine then
                 local divider = self:CreateGroupDivider(content, displayName, showName, showLine)
                 divider:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
                 divider:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
                 table.insert(self.groupHeaders, divider)
                 
                 local headerHeight = showName and 16 or (settings.dividerThickness or 2)
                 yOffset = yOffset + headerHeight + (settings.dividerPadding or 4)
             end
             
              currentGroup = group
        end
        
        -- Button
        yOffset = yOffset + buttonSpacing
        local btn = self:CreateStrategyButton(content, strategy, i)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        btn:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
        self.strategyButtons[strategy.id] = btn
        
        yOffset = yOffset + settings.buttonHeight + buttonSpacing
        end -- End Filter Check
    end
    
    content:SetHeight(yOffset + 10)
    self:UpdatePanelHeight()
end

function StrategyPanel:ClearContent()
    if self.strategyButtons then
        for _, btn in pairs(self.strategyButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
    end
    
    if self.groupHeaders then
        for _, header in pairs(self.groupHeaders) do
            header:Hide()
            header:SetParent(nil)
        end
    end
    
    self.strategyButtons = {}
    self.groupHeaders = {}
end

-- Divider creation (Updated)
function StrategyPanel:CreateGroupDivider(parent, groupName, showName, showLine)
    local settings = self:GetSettings()
    local thickness = settings.dividerThickness or 2
    local height = showName and 16 or thickness
    
    local divider = CreateFrame("Frame", nil, parent)
    divider:SetHeight(height) 
    
    local lineStartY = 0
    local lineStartX = 0
    
    if showName then
        local text = divider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetFont(settings.font, 10, "OUTLINE")
        text:SetPoint("LEFT", divider, "LEFT", 0, 0)
        text:SetText(groupName:upper())
        text:SetTextColor(0.8, 0.8, 0.8, 1)
        
        lineStartX = text:GetStringWidth() + 5
    else
        lineStartY = 0
    end
    
    -- FIX: Only show line if enabled
    if showLine then
        local line = divider:CreateTexture(nil, "OVERLAY")
        -- FIX: Use configured thickness
        line:SetHeight(thickness)
        
        if showName then
            line:SetPoint("LEFT", divider, "LEFT", lineStartX, 0)
        else
            line:SetPoint("LEFT", divider, "LEFT", 0, 0)
        end
        line:SetPoint("RIGHT", divider, "RIGHT", 0, 0)
        line:SetColorTexture(0.5, 0.5, 0.5, 0.5)
    end
    
    return divider
end

--[[
    Apply current settings to the panel
    Call this when settings are changed to refresh appearance
]]
function StrategyPanel:ApplySettings()
    if not self.frame then return end
    
    local s = self:GetSettings()
    
    -- Update frame size
    self.frame:SetWidth(s.width)
    
    -- Update backdrop colors
    self.frame:SetBackdropColor(unpack(s.backgroundColor))
    self.frame:SetBackdropBorderColor(unpack(s.borderColor))
    
    -- Update title bar
    if self.frame.titleBar then
        self.frame.titleBar:SetBackdropColor(unpack(s.titleBarColor or {0,0,0,0}))
        self.frame.titleBar:SetHeight(s.titleBarHeight or 28)
        if self.frame.titleText then
            self.frame.titleText:SetFont(s.font, s.titleFontSize, "OUTLINE")
            self.frame.titleText:SetTextColor(unpack(s.titleTextColor))
        end
    end
    
    -- Update content width & Padding
    if self.frame.content then
        self.frame.content:SetWidth(s.width - s.padding * 2 - 20)
    end
    
    -- FIX: Update ScrollFrame anchors to respect new padding
    if self.frame.scrollFrame then
        local topPadding = (s.titleBarHeight or 28) + s.padding
        local bottomPadding = (s.footerHeight or 32) + s.padding
        self.frame.scrollFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", s.padding, -topPadding)
        self.frame.scrollFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -s.padding - 20, bottomPadding)
    end
    
    -- Update buttons (borders, etc) -- This handles "borders not working"
    -- We need to rebuild creation params or manually update
    -- Easiest is to force RebuildContent if structural things changed, but visual things we can loop
    
    local edgeSize = s.buttonBorderWidth or 1
    local borderColor = s.showButtonBorder and s.borderColor or {0,0,0,0}
    
    for _, btn in pairs(self.strategyButtons) do
        -- Update backdrop edge size require re-setting backdrop
        btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = edgeSize })
        -- Re-apply proper colors (RefreshButtonStates will handle focus/dimmed state, so just base defaults here?)
        -- Actually RefreshButtonStates writes specific colors, so we should call that instead of setting here directly
        -- But we need to update the height/font first
        btn:SetHeight(s.buttonHeight)
        
        if btn.nameText then
            btn.nameText:SetFont(s.font, s.fontSize, "OUTLINE")
            btn.nameText:SetTextColor(unpack(s.textColor))
        end
    end
    
    self:RefreshButtonStates() -- Re-applies correct border colors/alpha
    
    -- If structural changes (spacing, grouping) might have occurred, we should rebuild:
    -- But since this function is 'refresh appearance', maybe enough?
    -- Spacing changes require position updates.
    -- To be safe, let's just trigger a lightweight relayout/rebuild if we can.
    -- self:RebuildContent() is safe to call if strategies exist.
    if self.strategies and #self.strategies > 0 then
        self:RebuildContent() -- This handles ButtonSpacing updates, Dividers, etc.
    end
    self:UpdateSidePanelAnchor()
    
    -- Refresh side panel if open to apply font changes
    if self.sidePanel and self.sidePanel:IsShown() and self.currentStrategy then
        -- Re-open strategy to force redraw of text with new font settings
        -- If we tracked tab index we could restore it, for now resetting to general/tab 1 is acceptable
        self:OpenStrategy(self.currentStrategy)
    end
    
    if self.addon then
        self.addon:Debug("StrategyPanel: Settings applied")
        -- Sync trash check
        if self.trashCheck and self.addon.db then
            self.trashCheck:SetChecked(self.addon.db.profile.includeTrashMobs)
        end
    end
end

function StrategyPanel:UpdatePanelHeight()
    -- Basic height calculation
    if not self.frame or not self.frame.content then return end
    local h = self.frame.content:GetHeight() + 60 -- Title + Footer buffer
    local max = self.addon and self.addon.db and self.addon.db.profile.strategyPanel.maxHeight or 500
    h = math.min(h, max)
    self.frame:SetHeight(math.max(150, h))
    
    -- Sync side panel height
    if self.sidePanel then
        self.sidePanel:SetHeight(self.frame:GetHeight())
    end
end

-- Position Management
function StrategyPanel:SavePosition()
    if self.addon and self.addon.db then
        local p, _, rp, x, y = self.frame:GetPoint()
        self.addon.db.profile.panelPosition = {point=p, relativePoint=rp, x=x, y=y}
    end
end

function StrategyPanel:LoadPosition()
    if self.addon and self.addon.db and self.addon.db.profile.panelPosition then
        local pos = self.addon.db.profile.panelPosition
        self.frame:ClearAllPoints()
        self.frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
end

-- Visibility Logic
function StrategyPanel:Hide()
    if self.frame then self.frame:Hide() end
    self:CloseSidePanel()
end

function StrategyPanel:Show()
    if self.frame then self.frame:Show() end
end

function StrategyPanel:Toggle()
    if self.frame and self.frame:IsShown() then self:Hide() else self:Show() end
end

function StrategyPanel:LoadInstance(instanceData, instanceName)
    self.strategies = instanceData.strategies or {}
    self.frame.titleText:SetText("Strategy: " .. (instanceName or "Unknown"))
    self:RebuildContent()
end

function StrategyPanel:ClearInstance()
    self.strategies = {}
    self:ClearContent()
    self.frame.titleText:SetText("Strategy")
end

-- Export
_G["StrategyPanel"] = StrategyPanel
