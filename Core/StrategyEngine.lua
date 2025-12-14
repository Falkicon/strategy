--[[
Strategy - Strategy Engine
Handles strategy formatting, role detection, and output logic
]]--

-- Create strategy engine module
local StrategyEngine = {}

-- Make module globally accessible for addon loading
_G["StrategyEngine"] = StrategyEngine

-- Cache frequently used globals for performance
local GetSpecializationRole = GetSpecializationRole
local GetSpecialization = GetSpecialization
local SendChatMessage = SendChatMessage
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown

-- Role header color definitions
local ROLE_HEADERS = {
    tank = "|cff4A90E2[TANK]|r ",
    dps = "|cffE74C3C[DPS]|r ",
    healer = "|cff2ECC71[HEAL]|r ",
    all = "|cffFFD700[ALL]|r ",
    interrupt = "|cffFF6B35[INT]|r ",
    dispel = "|cff44ff44[DISP]|r "
}

--[[
    Get color-coded role header
    @param role - Role name (tank, dps, healer, all, interrupt)
    @return Formatted role header with color codes
]]--
function StrategyEngine:GetRoleHeader(role)
    return ROLE_HEADERS[role] or "|cffFFFFFF[" .. role:upper() .. "]|r "
end

--[[
    Parse comma-separated role filter string
    @param roleFilter - Role filter string (e.g., "tank,dps" or "auto")
    @return Table of active roles
]]--
function StrategyEngine:ParseRoles(roleFilter)
    if roleFilter == "auto" then
        return self:GetActiveRoles()
    elseif roleFilter == "all" then
        return {tank = true, healer = true, dps = true, all = true, dispel = true, interrupt = true}
    elseif roleFilter == "tank" then
        return {tank = true}
    elseif roleFilter == "healer" then
        return {healer = true}
    elseif roleFilter == "dps" then
        return {dps = true}
    else
        return {all = true}
    end
end

--[[
    Get active roles based on player's current specialization
    @return Table of active roles for the player
]]--
function StrategyEngine:GetActiveRoles()
    local roles = {}
    local spec = GetSpecialization()
    if spec then
        local role = GetSpecializationRole(spec)
        if role == "TANK" then
            roles.tank = true
        elseif role == "HEALER" then
            roles.healer = true
        elseif role == "DAMAGER" then
            roles.dps = true
        end
    end
    -- Always include "all" role
    roles.all = true
    roles.interrupt = true
    roles.dispel = true
    return roles
end

--[[
    Strip WoW color codes from text lines for say channel
    @param lines - Array of text lines with color codes
    @return Array of lines with color codes removed
]]--
function StrategyEngine:StripColorsForSay(lines)
    -- Nil safety check
    if not lines then return {} end
    
    local stripped = {}
    for _, line in ipairs(lines) do
        -- Remove WoW color codes |cffXXXXXX and |r
        local stripped_line = line:gsub("|c[fF][fF]%x%x%x%x%x%x", ""):gsub("|r", "")
        table.insert(stripped, stripped_line)
    end
    return stripped
end

--[[
    Format strategy data into readable text lines (Compact Format)
    @param bossName - Name of the boss/encounter
    @param bossData - Strategy data for the encounter
    @param addon - Reference to main addon for settings access
    @param forceFull - If true, ignores role filters and includes all roles
    @return Array of formatted text lines
]]--
function StrategyEngine:FormatStrategy(bossName, bossData, addon, forceFull)
    -- Nil safety checks
    if not bossName or not bossData then return {} end
    if not addon or not addon.db or not addon.db.profile then return {} end
    
    local lines = {}
    
    -- Boss header based on mob type
    local bossHeader = ">>> " .. bossName
    if bossData.mobType == "trash" then
        bossHeader = bossHeader .. " |cffFFD700(TRASH)|r"
    end
    bossHeader = bossHeader .. " STRATEGY <<<"
    table.insert(lines, bossHeader)
    
    if bossData.tank or bossData.dps or bossData.healer or bossData.all or bossData.interrupt or bossData.dispel then
        local activeRoles = self:GetActiveRoles()
        
        -- Role processing order (ALL, TANK, DPS, HEALER, INTERRUPT, DISPEL)
        local roleOrder = {"all", "tank", "dps", "healer", "interrupt", "dispel"}
        
        for _, role in ipairs(roleOrder) do
            local roleStrategies = bossData[role]
            if roleStrategies and #roleStrategies > 0 then
                -- Check if we should show this role based on settings
                local shouldShow = true
                if not forceFull and addon.db.profile.roleFilter ~= "all" and role ~= "interrupt" and role ~= "dispel" then
                    local userRoles = self:ParseRoles(addon.db.profile.roleFilter)
                    shouldShow = userRoles[role] or false
                end
                
                if shouldShow then
                    -- Compact Single-Line Format: [ROLE] Strat 1 | Strat 2
                    local roleHeader = self:GetRoleHeader(role)
                    local content = table.concat(roleStrategies, " |cff999999 // |r ")
                    -- DEBUG: Trace output generation
                    -- addon:Print("FormatStrategy: Adding line for " .. role .. " len=" .. #content)
                    table.insert(lines, roleHeader .. content)
                else
                     -- addon:Print("FormatStrategy: Skipping role " .. role .. " (shouldShow=false)")
                end
            end
        end
    else
        -- addon:Print("FormatStrategy: No role keys found in bossData")
        -- Fallback for old format
        local strategy = bossData.strategy
        if strategy and #strategy > 0 then
            table.insert(lines, table.concat(strategy, " |cff999999 // |r "))
        end
    end
    
    return lines
end

--[[
    Output strategy to appropriate chat channel
    @param bossName - Name of the boss/encounter
    @param bossData - Strategy data for the encounter
    @param addon - Reference to main addon for settings and tracking
    @return Boolean indicating if output was successful
]]--
function StrategyEngine:OutputStrategy(bossName, bossData, addon)
    -- Normal chat output
    local lines = self:FormatStrategy(bossName, bossData, addon, true)
    local channel = addon.db.profile.outputMode
    
    if channel == "self" then
        -- Output to addon's own print system
        for _, line in ipairs(lines) do
            addon:Print(line)
        end
        return true
    end
    
    if channel ~= "self" then
        lines = self:StripColorsForSay(lines)
    end
    
    -- Send to chat channels with length validation
    local queue = {}
    
    for _, line in ipairs(lines) do
        -- CRITICAL FIX: Validate chat message length (WoW limit is 255 characters)
        local processedLines = self:ValidateAndSplitChatMessage(line)
        
        for _, processedLine in ipairs(processedLines) do
            table.insert(queue, processedLine)
        end
    end
    
    -- Send messages with delay
    local SendNextMessage
    SendNextMessage = function()
        if #queue == 0 then return end
        
        local line = table.remove(queue, 1)
        
        local success, err = pcall(function()
            if channel == "instance" then
                if IsInRaid() then
                    SendChatMessage(line, "RAID")
                elseif IsInGroup() then
                    SendChatMessage(line, "PARTY")
                else
                    addon:Print(line)
                end
            elseif channel == "party" then
                if IsInRaid() then
                    SendChatMessage(line, "RAID")
                elseif IsInGroup() then
                    SendChatMessage(line, "PARTY")
                else
                    SendChatMessage(line, "SAY")
                end
            elseif channel == "say" then
                SendChatMessage(line, "SAY")
            elseif channel == "whisper" then
                local target = addon.db.profile.whisperTarget
                if target and target ~= "" then
                    SendChatMessage(line, "WHISPER", nil, target)
                else
                    addon:Print("No whisper target set - outputting to addon chat")
                    addon:Print(line)
                end
            end
        end)
        
        if not success then
            addon:Print("Error sending chat: " .. tostring(err))
        end
        
        -- Schedule next message
        if #queue > 0 then
            C_Timer.After(0.1, SendNextMessage)
        end
    end
    
    -- Start sending
    SendNextMessage()
    
    addon:Debug("Strategy output for " .. bossName .. " to " .. channel)
    return true
end

--[[
    Output minimal critical mechanics only (for strategy window integration)
    @param bossName - Name of the boss/encounter
    @param bossData - Strategy data for the encounter
    @param addon - Reference to main addon for settings access
    @return Boolean indicating if output was successful
]]--
function StrategyEngine:OutputMinimalStrategy(bossName, bossData, addon)
    addon:Debug("OutputMinimalStrategy called for: " .. bossName)
    
    -- Get only the most critical information
    local criticalInfo = {}
    
    -- Add interrupts if available (highest priority)
    if bossData.interrupt and #bossData.interrupt > 0 then
        table.insert(criticalInfo, self:GetRoleHeader("interrupt") .. " " .. bossData.interrupt[1])
    end
    
    -- Add one key tank mechanic if available
    if bossData.tank and #bossData.tank > 0 then
        table.insert(criticalInfo, "🛡️ " .. bossData.tank[1])
    end
    
    -- Add one critical mechanic from 'all' category if available  
    if bossData.all and #bossData.all > 0 then
        table.insert(criticalInfo, "⚠️ " .. bossData.all[1])
    end
    
    -- Output minimal info if we have any
    if #criticalInfo > 0 then
        local channel = addon.db.profile.outputMode
        local header = ">>> " .. bossName .. " (KEY MECHANICS) <<<"
        
        if channel == "self" then
            addon:Print(header)
            for _, info in ipairs(criticalInfo) do
                addon:Print(info)
            end
        else
            -- Send to appropriate chat channel
            local lines = {header}
            for _, info in ipairs(criticalInfo) do
                table.insert(lines, info)
            end
            
            if channel == "say" then
                lines = self:StripColorsForSay(lines)
            end
            
            for _, line in ipairs(lines) do
                if channel == "instance" then
                    if IsInRaid() then
                        SendChatMessage(line, "RAID")
                    elseif IsInGroup() then
                        SendChatMessage(line, "PARTY")
                    else
                        addon:Print(line)
                    end
                elseif channel == "party" then
                    if IsInRaid() then
                        SendChatMessage(line, "RAID")
                    elseif IsInGroup() then
                        SendChatMessage(line, "PARTY")
                    else
                        SendChatMessage(line, "SAY")
                    end
                elseif channel == "say" then
                    SendChatMessage(line, "SAY")
                elseif channel == "whisper" then
                    local target = addon.db.profile.whisperTarget
                    if target and target ~= "" then
                        SendChatMessage(line, "WHISPER", nil, target)
                    else
                        addon:Print(line)
                    end
                end
            end
        end
        
        addon:Debug("Minimal strategy output sent for: " .. bossName)
        return true
    end
    
    return false
end

--[[
    Validate and split chat messages that exceed WoW's character limit
    @param message - Message to validate and potentially split
    @return Array of message parts that fit within WoW's limits
]]--
function StrategyEngine:ValidateAndSplitChatMessage(message)
    if not message or message == "" then 
        return {}
    end
    
    local MAX_CHAT_LENGTH = 255
    local result = {}
    
    -- If message fits within limit, return as-is
    if #message <= MAX_CHAT_LENGTH then
        table.insert(result, message)
        return result
    end
    
    -- Split long messages at word boundaries when possible
    local current = ""
    local words = {}
    
    -- Split into words
    for word in message:gmatch("%S+") do
        table.insert(words, word)
    end
    
    for i, word in ipairs(words) do
        local testLine = current == "" and word or current .. " " .. word
        
        if #testLine > MAX_CHAT_LENGTH then
            -- Current line is full, start a new one
            if #current > 0 then
                table.insert(result, current)
            end
            
            -- Handle extremely long single words
            if #word > MAX_CHAT_LENGTH then
                -- Force split the word
                local remaining = word
                while #remaining > 0 do
                    local chunk = remaining:sub(1, MAX_CHAT_LENGTH)
                    table.insert(result, chunk)
                    remaining = remaining:sub(MAX_CHAT_LENGTH + 1)
                end
                current = ""
            else
                current = word
            end
        else
            current = testLine
        end
    end
    
    -- Add the final line if not empty
    if #current > 0 then
        table.insert(result, current)
    end
    
    return result
end

-- Make module available to main addon
_G["StrategyEngine"] = StrategyEngine
