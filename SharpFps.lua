-- SharpFps
-- Made by Sharpedge_Gaming
-- v1.6

local addonName = "SharpFps"

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local SharpFps = AceAddon:NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local savedVariables = {
    profile = {
        font = "Friz Quadrata TT",  -- Default font
        enabled = true,  -- Default to enabled
        fontSize = 12,
        textColor = {r = 1, g = 1, b = 1, a = 1},
        showHome = true,
        showWorld = true,
        position = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 }  -- Default position
    }
}

local frame = CreateFrame("Frame", "SharpFpsFrame", UIParent)
frame:SetSize(200, 70)
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)

local db

function SharpFps:OnInitialize()
    db = LibStub("AceDB-3.0"):New("SharpFpsDB", savedVariables, true)
    
    local fontPath = LSM:Fetch("font", db.profile.font)
    frame.text:SetFont(fontPath, db.profile.fontSize, "OUTLINE")
    
    frame.text:SetTextColor(db.profile.textColor.r, db.profile.textColor.g, db.profile.textColor.b, db.profile.textColor.a)
    self:ToggleEnabled(db.profile.enabled)
    self:UpdateFramePosition()
end

function SharpFps:ToggleEnabled(value)
    if value then
        frame:Show()
    else
        frame:Hide()
    end
end

function SharpFps:UpdateFramePosition()
    frame:ClearAllPoints()
    frame:SetPoint(db.profile.position.point, UIParent, db.profile.position.relativePoint, db.profile.position.x, db.profile.position.y)
end

frame:SetScale(1)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    db.profile.position.point = point
    db.profile.position.relativePoint = relativePoint
    db.profile.position.x = xOfs
    db.profile.position.y = yOfs
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    local fps = GetFramerate()
    local homeLatency, worldLatency = select(3, GetNetStats()), select(4, GetNetStats())
    local text = string.format("FPS: %.0f", fps)
    if db.profile.showHome then
        text = text .. string.format("\nHome : %d ms", homeLatency)
    end
    if db.profile.showWorld then
        text = text .. string.format("\nWorld : %d ms", worldLatency)
    end
    self.text:SetText(text)
end)

local options = {
    name = "Sharp FPS",
    type = 'group',
    args = {
        generalHeader = {
            name = "General Settings",
            type = "header",
            order = 1,
        },
        enabled = {
            name = "Enabled",
            type = "toggle",
            desc = "Enable or disable the FPS counter",
            get = function()
                return db.profile.enabled
            end,
            set = function(info, value)
                db.profile.enabled = value
                SharpFps:ToggleEnabled(value)
            end,
            order = 2,
        },
        appearanceHeader = {
            name = "Appearance",
            type = "header",
            order = 3,
        },
        fontSize = {
            name = "Font Size",
            type = "range",
            desc = "Set the font size of the FPS counter",
            min = 8,
            max = 32,
            step = 1,
            get = function()
                return db.profile.fontSize
            end,
            set = function(info, value)
                db.profile.fontSize = value
                frame.text:SetFont("Fonts\\FRIZQT__.TTF", value, "OUTLINE")
            end,
            order = 4,
        },
        textColor = {
            name = "Text Color",
            type = "color",
            desc = "Set the text color of the FPS counter",
            get = function()
                local color = db.profile.textColor
                return color.r, color.g, color.b, color.a
            end,
            set = function(info, r, g, b, a)
                local color = db.profile.textColor
                color.r, color.g, color.b, color.a = r, g, b, a
                frame.text:SetTextColor(r, g, b, a)
            end,
            hasAlpha = true,
            order = 5,
        },
        font = {
            name = "Font",
            type = "select",
            desc = "Set the font of the FPS counter",
            values = LSM:HashTable("font"),
            dialogControl = "LSM30_Font",
            get = function()
                return db.profile.font
            end,
            set = function(info, value)
                db.profile.font = value
                local fontPath = LSM:Fetch("font", value)
                frame.text:SetFont(fontPath, db.profile.fontSize, "OUTLINE")
            end,
            order = 6,  -- Adjust the order value to position the option correctly
        },
        latencyHeader = {
            name = "Latency Display",
            type = "header",
            order = 7,
        },
        showHome = {
            name = "Show Home Latency",
            type = "toggle",
            desc = "Enable or disable the display of Home latency",
            get = function()
                return db.profile.showHome
            end,
            set = function(info, value)
                db.profile.showHome = value
            end,
            order = 8,
        },
        showWorld = {
            name = "Show World Latency",
            type = "toggle",
            desc = "Enable or disable the display of World latency",
            get = function()
                return db.profile.showWorld
            end,
            set = function(info, value)
                db.profile.showWorld = value
            end,
            order = 9,
        },
    },
}

AceConfig:RegisterOptionsTable("SharpFpsFrame", options)
AceConfigDialog:AddToBlizOptions("SharpFpsFrame", "Sharp FPS")
