local addonName = ...

-- Default SavedVariables settings
local DEFAULT_SETTINGS = {
    tintIcon = false,      -- true: tint the entire spell icon red when out of range
    thickFont = true,      -- true: apply THICKOUTLINE and font shadow
    showBackdrop = false,  -- true: display dark rectangular backdrop box behind numbers
    bgAlpha = 0.65,        -- Opacity of the background box (0.0 to 1.0)
    fontSize = 13,         -- Font size for keybind numbers (8-22)
    outOfRangeColor = { r = 1.0, g = 0.15, b = 0.15 }, -- Vivid neon red
    inRangeColor = { r = 1.0, g = 1.0, b = 1.0 },       -- Pure crisp white
}

-- List of standard action button prefixes to style
local BUTTON_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "BonusActionButton",
    "StanceButton",
    "PetActionButton",
}

-- Forward declarations
local optionsPanel
local RefreshAllButtons
local StyleAllButtons
local OpenOptions

-- Helper to safely retrieve hotkey font string for any button
local function GetButtonHotKey(button)
    if not button then return nil end
    return button.HotKey or _G[button:GetName() and (button:GetName() .. "HotKey")]
end

-- Helper to safely retrieve icon texture for any button
local function GetButtonIcon(button)
    if not button then return nil end
    return button.icon or _G[button:GetName() and (button:GetName() .. "Icon")]
end

-- Update the size and visibility of the optional dark square/box behind the hotkey
local function UpdateButtonBackdrop(button)
    local hotkey = GetButtonHotKey(button)
    local bg = button.SpellRangeBG
    if not bg or not hotkey then return end

    if SpellRangeDB.showBackdrop and hotkey:IsShown() then
        local text = hotkey:GetText()
        if text and text ~= "" then
            local strWidth = hotkey:GetStringWidth() or 0
            local strHeight = hotkey:GetStringHeight() or 0
            if strWidth > 0 then
                local alpha = SpellRangeDB.bgAlpha or DEFAULT_SETTINGS.bgAlpha
                bg:SetSize(math.max(strWidth + 4, 10), math.max(strHeight + 2, 10))
                bg:SetColorTexture(0, 0, 0, alpha)
                bg:Show()
                return
            end
        end
    end

    bg:Hide()
end

-- Style a button's hotkey font with clean THICKOUTLINE, font shadow, and optional square box
local function StyleButton(button)
    if not button then return end
    local hotkey = GetButtonHotKey(button)
    if not hotkey then return end

    local fontFile = NumberFontNormal and NumberFontNormal:GetFont() or hotkey:GetFont()
    local targetSize = SpellRangeDB.fontSize or DEFAULT_SETTINGS.fontSize
    local fontFlags = (SpellRangeDB.thickFont ~= false) and "THICKOUTLINE" or ""

    hotkey:SetFont(fontFile, targetSize, fontFlags)
    hotkey:SetShadowColor(0, 0, 0, 1)
    hotkey:SetShadowOffset(1.5, -1.5)
    hotkey:SetDrawLayer("OVERLAY", 7)

    -- Manage optional dark square box
    if SpellRangeDB.showBackdrop then
        if not button.SpellRangeBG then
            local bg = button:CreateTexture(nil, "OVERLAY", nil, 0)
            bg:SetPoint("TOPRIGHT", hotkey, "TOPRIGHT", 2, 1)
            button.SpellRangeBG = bg

            hooksecurefunc(hotkey, "Show", function()
                UpdateButtonBackdrop(button)
            end)
            hooksecurefunc(hotkey, "Hide", function()
                if button.SpellRangeBG then
                    button.SpellRangeBG:Hide()
                end
            end)
            hooksecurefunc(hotkey, "SetText", function()
                UpdateButtonBackdrop(button)
            end)
        end
        UpdateButtonBackdrop(button)
    else
        if button.SpellRangeBG then
            button.SpellRangeBG:Hide()
        end
    end
end

-- Apply styling to all standard action buttons
StyleAllButtons = function()
    for _, prefix in ipairs(BUTTON_PREFIXES) do
        for i = 1, 12 do
            local btn = _G[prefix .. i]
            if btn then
                StyleButton(btn)
            end
        end
    end
end

-- Determine whether an action is currently out of range
local function IsActionOutOfRange(button)
    if not button or not button.action then
        return false
    end

    -- If no target or dead target, action is NEVER considered out of range
    if not UnitExists("target") or UnitIsDeadOrGhost("target") then
        return false
    end

    -- IsActionInRange check:
    -- 0 or false = out of range / no line of sight
    -- 1 or true  = in range
    -- nil        = action has no range check on this target
    local inRange = IsActionInRange(button.action)
    if inRange == 0 or inRange == false then
        return true
    end

    return false
end

-- Update both hotkey text and icon vertex colors for a button
local function UpdateButtonVisuals(button)
    if not button then return end
    local hotkey = GetButtonHotKey(button)
    local icon = GetButtonIcon(button)

    local outOfRange = IsActionOutOfRange(button)

    -- 1. HotKey coloring: vivid red if out of range, crisp white if in range or idle
    if hotkey then
        if outOfRange then
            local c = SpellRangeDB.outOfRangeColor or DEFAULT_SETTINGS.outOfRangeColor
            hotkey:SetVertexColor(c.r, c.g, c.b)
        else
            local c = SpellRangeDB.inRangeColor or DEFAULT_SETTINGS.inRangeColor
            hotkey:SetVertexColor(c.r, c.g, c.b)
        end
    end

    -- 2. Icon coloring (only when tintIcon is enabled)
    if icon then
        if SpellRangeDB.tintIcon then
            if outOfRange then
                icon:SetVertexColor(1.0, 0.2, 0.2) -- Red icon when out of range
            else
                -- In range / no target: restore normal usable or mana state
                local isUsable, notEnoughMana = true, false
                if button.action and IsUsableAction then
                    isUsable, notEnoughMana = IsUsableAction(button.action)
                end

                if not isUsable then
                    icon:SetVertexColor(0.4, 0.4, 0.4) -- Unusable
                elseif notEnoughMana then
                    icon:SetVertexColor(0.5, 0.5, 1.0) -- Out of mana
                else
                    icon:SetVertexColor(1.0, 1.0, 1.0) -- Normal full color
                end
            end
        end
    end
end

-- Instantly refresh range status and icon states on all visible buttons
RefreshAllButtons = function()
    for _, prefix in ipairs(BUTTON_PREFIXES) do
        for i = 1, 12 do
            local btn = _G[prefix .. i]
            if btn and btn:IsShown() then
                UpdateButtonVisuals(btn)

                -- If tintIcon is disabled, ensure icon color is restored to Blizzard standard
                if not SpellRangeDB.tintIcon and ActionButton_UpdateUsable then
                    ActionButton_UpdateUsable(btn)
                end
            end
        end
    end
end

-- Initialize database and apply defaults
local function InitDB()
    SpellRangeDB = SpellRangeDB or {}
    for k, v in pairs(DEFAULT_SETTINGS) do
        if SpellRangeDB[k] == nil then
            SpellRangeDB[k] = v
        end
    end
end

-- Print helper for chat messages
local function PrintMessage(msg)
    print("|cff00ccffSpellRange:|r " .. msg)
end

-------------------------------------------------------------------------------
-- Blizzard Options Menu Panel Registration
-------------------------------------------------------------------------------

local function CreateOptionsPanel()
    if optionsPanel then return optionsPanel end

    local panel = CreateFrame("Frame", "SpellRangeOptionsPanel", UIParent)
    panel.name = "SpellRange"

    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("SpellRange")

    -- Subtitle
    local subHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subHeader:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subHeader:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    subHeader:SetJustifyH("LEFT")
    subHeader:SetText("Enhances action bar range indicators with high-contrast keybinds, pure font shadows, and full icon tinting.")

    -- Helper to build styled checkboxes
    local function CreateCheckbox(name, labelText, subtextText, yOffset, onClick)
        local cb = CreateFrame("CheckButton", "SpellRangeOpt_" .. name, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)

        local text = _G[cb:GetName() .. "Text"]
        text:SetText(labelText)
        text:SetFontObject("GameFontNormal")

        if subtextText then
            local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            sub:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 28, -2)
            sub:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
            sub:SetJustifyH("LEFT")
            sub:SetText(subtextText)
            sub:SetTextColor(0.72, 0.72, 0.72)
            cb.Subtext = sub
        end

        cb:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            if type(checked) == "number" then checked = (checked == 1) end
            onClick(checked)
        end)

        return cb
    end

    -- Helper to build styled sliders
    local function CreateSlider(name, labelText, minVal, maxVal, step, yOffset, formatVal, onValChanged)
        local slider = CreateFrame("Slider", "SpellRangeOpt_" .. name, panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", panel, "TOPLEFT", 24, yOffset)
        slider:SetWidth(300)
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)

        local t = _G[slider:GetName() .. "Text"]
        t:SetFontObject("GameFontNormal")
        t:SetText(labelText)

        local low = _G[slider:GetName() .. "Low"]
        low:SetText(tostring(minVal))
        local high = _G[slider:GetName() .. "High"]
        high:SetText(tostring(maxVal))

        local valDisplay = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        valDisplay:SetPoint("LEFT", t, "RIGHT", 10, 0)
        slider.ValDisplay = valDisplay

        slider:SetScript("OnValueChanged", function(self, value)
            onValChanged(value)
            valDisplay:SetText(formatVal(value))
        end)

        return slider
    end

    -- 1. Checkbox: Whole icon tint
    local cbTint = CreateCheckbox("TintIcon", "Tint whole spell icon red", "When an action is out of range, colors the entire button icon red instead of just the number.", -75,
        function(checked)
            SpellRangeDB.tintIcon = checked
            RefreshAllButtons()
        end
    )

    -- 2. Checkbox: Thick keybind font with shadow
    local cbThick = CreateCheckbox("ThickFont", "Thick keybind numbers (THICKOUTLINE + Shadow)", "Applies a bold font with a clean THICKOUTLINE and drop shadow to keybind numbers (1-9, etc.).", -140,
        function(checked)
            SpellRangeDB.thickFont = checked
            StyleAllButtons()
            RefreshAllButtons()
        end
    )

    -- 3. Checkbox: Optional dark square box
    local cbBackdrop = CreateCheckbox("Backdrop", "Dark background box behind numbers (Optional)", "Displays a subtle dark rectangular backing box behind keybind numbers for extra contrast on bright icons.", -205,
        function(checked)
            SpellRangeDB.showBackdrop = checked
            StyleAllButtons()
        end
    )

    -- 4. Slider: Font Size
    local sliderSize = CreateSlider("FontSize", "Keybind Font Size", 8, 22, 1, -280,
        function(val) return "|cffffd100" .. math.floor(val) .. " pt|r" end,
        function(val)
            SpellRangeDB.fontSize = math.floor(val)
            StyleAllButtons()
        end
    )

    -- 5. Slider: Box Darkness (Opacity)
    local sliderAlpha = CreateSlider("BoxAlpha", "Background Box Darkness", 0, 100, 5, -335,
        function(val) return "|cffffd100" .. math.floor(val) .. "%|r" end,
        function(val)
            SpellRangeDB.bgAlpha = val / 100
            StyleAllButtons()
        end
    )

    -- 6. Button: Defaults
    local btnDefaults = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnDefaults:SetSize(120, 24)
    btnDefaults:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -395)
    btnDefaults:SetText("Defaults")
    btnDefaults:SetScript("OnClick", function()
        for k, v in pairs(DEFAULT_SETTINGS) do
            SpellRangeDB[k] = v
        end
        if panel.refresh then panel.refresh() end
        StyleAllButtons()
        RefreshAllButtons()
        PrintMessage("All settings reset to defaults.")
    end)

    -- Refresh panel controls from DB
    panel.refresh = function()
        cbTint:SetChecked(SpellRangeDB.tintIcon)
        cbThick:SetChecked(SpellRangeDB.thickFont ~= false)
        cbBackdrop:SetChecked(SpellRangeDB.showBackdrop == true)

        local curSize = SpellRangeDB.fontSize or DEFAULT_SETTINGS.fontSize
        sliderSize:SetValue(curSize)
        sliderSize.ValDisplay:SetText("|cffffd100" .. curSize .. " pt|r")

        local curAlpha = math.floor((SpellRangeDB.bgAlpha or DEFAULT_SETTINGS.bgAlpha) * 100)
        sliderAlpha:SetValue(curAlpha)
        sliderAlpha.ValDisplay:SetText("|cffffd100" .. curAlpha .. "%|r")
    end

    panel.default = function()
        for k, v in pairs(DEFAULT_SETTINGS) do
            SpellRangeDB[k] = v
        end
        if panel.refresh then panel.refresh() end
        StyleAllButtons()
        RefreshAllButtons()
    end

    -- Hook panel OnShow to sync controls
    panel:SetScript("OnShow", function()
        if panel.refresh then panel.refresh() end
    end)

    -- Register with Blizzard Settings / Interface Options
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        -- Modern Settings UI (WoW 10.0+, 11.0+, Classic Era 1.15+)
        local category = Settings.RegisterCanvasLayoutCategory(panel, "SpellRange")
        Settings.RegisterAddOnCategory(category)
        panel.settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        -- Classic / Legacy Interface Options
        InterfaceOptions_AddCategory(panel)
    end

    optionsPanel = panel
    return optionsPanel
end

-- Open options panel directly (opens Game Menu Settings to the SpellRange tab)
OpenOptions = function()
    local panel = CreateOptionsPanel()
    if not panel then return end

    local opened = false
    if Settings and Settings.OpenToCategory and panel.settingsCategory then
        local ok = pcall(function()
            Settings.OpenToCategory(panel.settingsCategory:GetID())
        end)
        if ok then opened = true end
    end

    if not opened and InterfaceOptionsFrame_OpenToCategory then
        pcall(function()
            InterfaceOptionsFrame_OpenToCategory(panel)
            InterfaceOptionsFrame_OpenToCategory(panel) -- Workaround for Blizzard double-call quirk
        end)
    end
end

-------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------

local function HandleSlashCommand(msg)
    local cmd, arg = strsplit(" ", (msg or ""):trim():lower(), 2)

    if not cmd or cmd == "" or cmd == "options" or cmd == "config" or cmd == "menu" or cmd == "ui" then
        OpenOptions()

    elseif cmd == "tint" then
        if arg == "on" then
            SpellRangeDB.tintIcon = true
        elseif arg == "off" then
            SpellRangeDB.tintIcon = false
        else
            SpellRangeDB.tintIcon = not SpellRangeDB.tintIcon
        end
        PrintMessage("Full icon tinting: " .. (SpellRangeDB.tintIcon and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        RefreshAllButtons()

    elseif cmd == "box" or cmd == "bg" then
        if arg == "on" then
            SpellRangeDB.showBackdrop = true
        elseif arg == "off" then
            SpellRangeDB.showBackdrop = false
        else
            SpellRangeDB.showBackdrop = not SpellRangeDB.showBackdrop
        end
        StyleAllButtons()
        PrintMessage("Background box: " .. (SpellRangeDB.showBackdrop and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))

    elseif cmd == "size" then
        local size = tonumber(arg)
        if size and size >= 8 and size <= 22 then
            SpellRangeDB.fontSize = size
            StyleAllButtons()
            PrintMessage("Font size set to |cffffd100" .. size .. "|r.")
        else
            PrintMessage("Usage: |cffffd100/sr size <8-22>|r (current: " .. (SpellRangeDB.fontSize or DEFAULT_SETTINGS.fontSize) .. ")")
        end

    elseif cmd == "reset" then
        for k, v in pairs(DEFAULT_SETTINGS) do
            SpellRangeDB[k] = v
        end
        if optionsPanel and optionsPanel.refresh then
            optionsPanel.refresh()
        end
        StyleAllButtons()
        RefreshAllButtons()
        PrintMessage("Settings reset to default.")

    else
        PrintMessage("Available commands:")
        print("  |cffffd100/SpellRangeIndicator|r (or |cffffd100/sri|r, |cffffd100/sr|r) - Open options menu")
        print("  |cffffd100/sr tint|r - Toggle full spell icon red tinting (current: " .. (SpellRangeDB.tintIcon and "on" or "off") .. ")")
        print("  |cffffd100/sr box|r - Toggle background box behind numbers (current: " .. (SpellRangeDB.showBackdrop and "on" or "off") .. ")")
        print("  |cffffd100/sr size <8-22>|r - Set font size (current: " .. SpellRangeDB.fontSize .. ")")
        print("  |cffffd100/sr reset|r - Reset all settings to defaults")
    end
end

-------------------------------------------------------------------------------
-- Main Event Lifecycle & Hooks
-------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitDB()

        -- Hook range indicator updates
        if ActionButton_UpdateRangeIndicator then
            hooksecurefunc("ActionButton_UpdateRangeIndicator", function(button, checksRange, inRange)
                UpdateButtonVisuals(button)
            end)
        end

        -- Hook usability updates so out-of-range icon tint isn't prematurely cleared by mana updates
        if ActionButton_UpdateUsable then
            hooksecurefunc("ActionButton_UpdateUsable", function(button)
                if not button or not SpellRangeDB.tintIcon then return end
                if IsActionOutOfRange(button) then
                    local icon = GetButtonIcon(button)
                    if icon then
                        icon:SetVertexColor(1.0, 0.2, 0.2)
                    end
                end
            end)
        end

        -- Re-style buttons whenever hotkeys or actions are updated
        if ActionButton_UpdateHotkeys then
            hooksecurefunc("ActionButton_UpdateHotkeys", function(button)
                StyleButton(button)
            end)
        end
        if ActionButton_Update then
            hooksecurefunc("ActionButton_Update", function(button)
                StyleButton(button)
            end)
        end

        -- Initial styling
        StyleAllButtons()

        -- Register options panel into Blizzard Settings / Interface Options menu
        CreateOptionsPanel()

        -- Register slash commands: /SpellRangeIndicator, /sri, /spellrange, /sr
        SLASH_SPELLRANGEINDICATOR1 = "/spellrangeindicator"
        SLASH_SPELLRANGEINDICATOR2 = "/sri"
        SLASH_SPELLRANGEINDICATOR3 = "/spellrange"
        SLASH_SPELLRANGEINDICATOR4 = "/sr"
        SlashCmdList["SPELLRANGEINDICATOR"] = HandleSlashCommand

    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        -- Refresh range colors instantly when targeting/untargeting or engaging combat
        RefreshAllButtons()
    end
end)
