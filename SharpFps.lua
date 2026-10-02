-- SharpFps
-- Made by Sharpedge_Gaming
-- v5.0 - 12.1.0

local addonName = "SharpFps"

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
local AceDBOptions = LibStub("AceDBOptions-3.0", true) -- optional, enables the Profiles tab
local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)         -- optional, enables Titan/ChocolateBar/etc feed

local SharpFps = AceAddon:NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

-- Upvalues
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local format = string.format
local concat = table.concat
local ceil = math.ceil
local floor = math.floor
local abs = math.abs
local max = math.max
local min = math.min
local wipe = wipe
local tostring = tostring

local WHITE = "Interface\\Buttons\\WHITE8X8"
local PAD = 4
local SAMPLE_SIZE = 60
local GRAPH_MAX = 60
local SCANLINE_MAX = 120
local WARMUP_SECONDS = 5

local GOOD = { 0.20, 1.00, 0.30 }
local WARN = { 1.00, 0.82, 0.00 }
local BAD  = { 1.00, 0.20, 0.20 }
local LAT_LINE = { 0.45, 0.75, 1.00 }

---------------------------------------------------------------------
-- Themes
---------------------------------------------------------------------
local THEMES = {
    MIDNIGHT = {
        name = "Midnight",
        bgTop = { 0.09, 0.10, 0.16, 0.92 }, bgBottom = { 0.03, 0.03, 0.07, 0.92 },
        border = { 0.25, 0.35, 0.60, 0.80 },
        accentMode = "STATUS", accent = { 0.30, 0.70, 1.00, 1 },
        text = { 0.75, 0.80, 0.95, 1 },
        glow = true, glowAlpha = 0.35,
        graphStyle = "FILL",
    },
    NEON = {
        name = "Neon",
        bgTop = { 0.06, 0.00, 0.10, 0.95 }, bgBottom = { 0.00, 0.00, 0.00, 0.95 },
        border = { 1.00, 0.10, 0.80, 1.00 },
        accentMode = "CUSTOM", accent = { 0.00, 1.00, 0.95, 1 },
        text = { 1.00, 0.60, 1.00, 1 },
        glow = true, glowAlpha = 0.70,
        graphStyle = "LINE",
    },
    SYNTHWAVE = {
        name = "Synthwave",
        bgTop = { 0.20, 0.04, 0.28, 0.94 }, bgBottom = { 0.02, 0.00, 0.08, 0.94 },
        border = { 0.95, 0.30, 0.85, 0.90 },
        accentMode = "CHROMA", accent = { 1.00, 0.30, 0.80, 1 },
        text = { 1.00, 0.75, 0.95, 1 },
        glow = true, glowAlpha = 0.60,
        shine = true, scanlines = true,
        graphStyle = "FILL",
    },
    GLASS = {
        name = "Glass",
        bgTop = { 1, 1, 1, 0.14 }, bgBottom = { 1, 1, 1, 0.04 },
        border = { 1, 1, 1, 0.25 },
        accentMode = "STATUS", accent = { 1, 1, 1, 1 },
        text = { 1, 1, 1, 0.90 },
        glow = false, glowAlpha = 0.25,
        shine = true,
        graphStyle = "BARS",
    },
    FROST = {
        name = "Frost",
        bgTop = { 0.12, 0.20, 0.28, 0.90 }, bgBottom = { 0.03, 0.07, 0.12, 0.90 },
        border = { 0.60, 0.85, 1.00, 0.70 },
        accentMode = "CUSTOM", accent = { 0.55, 0.90, 1.00, 1 },
        text = { 0.80, 0.93, 1.00, 1 },
        glow = true, glowAlpha = 0.40,
        shine = true,
        graphStyle = "FILL",
    },
    TERMINAL = {
        name = "Terminal",
        bgTop = { 0.00, 0.07, 0.00, 0.95 }, bgBottom = { 0.00, 0.02, 0.00, 0.95 },
        border = { 0.10, 0.60, 0.10, 0.80 },
        accentMode = "CUSTOM", accent = { 0.20, 1.00, 0.20, 1 },
        text = { 0.30, 1.00, 0.30, 1 },
        glow = true, glowAlpha = 0.30,
        scanlines = true,
        graphStyle = "LINE",
        font = "Arial Narrow",
    },
    EMBER = {
        name = "Ember",
        bgTop = { 0.16, 0.05, 0.02, 0.92 }, bgBottom = { 0.05, 0.01, 0.00, 0.92 },
        border = { 0.80, 0.35, 0.10, 0.80 },
        accentMode = "CUSTOM", accent = { 1.00, 0.50, 0.10, 1 },
        text = { 1.00, 0.85, 0.70, 1 },
        glow = true, glowAlpha = 0.45,
        graphStyle = "BARS",
    },
    GOLD = {
        name = "Gilded",
        bgTop = { 0.14, 0.11, 0.05, 0.94 }, bgBottom = { 0.04, 0.03, 0.01, 0.94 },
        border = { 1.00, 0.80, 0.30, 0.90 },
        accentMode = "CUSTOM", accent = { 1.00, 0.82, 0.30, 1 },
        text = { 1.00, 0.90, 0.60, 1 },
        glow = true, glowAlpha = 0.40,
        shine = true,
        graphStyle = "FILL",
        font = "Morpheus",
    },
    CLASS = {
        name = "Class Pride",
        bgTop = { 0.08, 0.08, 0.08, 0.92 }, bgBottom = { 0.02, 0.02, 0.02, 0.92 },
        border = { 0.30, 0.30, 0.30, 0.80 },
        accentMode = "CLASS", accent = { 1, 1, 1, 1 },
        text = { 0.90, 0.90, 0.90, 1 },
        glow = true, glowAlpha = 0.45,
        graphStyle = "FILL",
    },
}

local THEME_ORDER = { "MIDNIGHT", "NEON", "SYNTHWAVE", "GLASS", "FROST", "TERMINAL", "EMBER", "GOLD", "CLASS" }

local THEME_VALUES = { CUSTOM = "Custom" }
for key, t in pairs(THEMES) do THEME_VALUES[key] = t.name end

local THEME_SORTING = {}
for i, key in ipairs(THEME_ORDER) do THEME_SORTING[i] = key end
THEME_SORTING[#THEME_SORTING + 1] = "CUSTOM"

-- Changing any of these by hand flips the theme selector to Custom
local THEME_KEYS = { bgTop = true, bgBottom = true, hudBorderColor = true, accentColor = true, textColor = true }

local defaults = {
    profile = {
        enabled = true,
        locked = false,
        style = "HUD",
        theme = "MIDNIGHT",

        font = "Friz Quadrata TT",
        outline = "OUTLINE",
        scale = 1,
        textColor = { r = 0.75, g = 0.80, b = 0.95, a = 1 },
        colorCode = true,
        smoothColors = true,

        showFps = true,
        showHome = true,
        showWorld = true,

        -- HUD
        hudWidth = 180,
        hudFontSize = 26,
        smoothNumbers = true,
        showMood = true,
        showFrametime = true,
        showGauge = true,
        showAvgTick = true,
        fpsCap = 144,
        showGraph = true,
        graphStyle = "FILL",
        graphBars = 40,
        graphHeight = 30,
        lineThickness = 1.5,
        graphLatency = false,
        bgTop = { r = 0.09, g = 0.10, b = 0.16, a = 0.92 },
        bgBottom = { r = 0.03, g = 0.03, b = 0.07, a = 0.92 },
        hudBorderColor = { r = 0.25, g = 0.35, b = 0.60, a = 0.80 },

        -- Accent and effects
        accentMode = "STATUS",
        accentColor = { r = 0.30, g = 0.70, b = 1.00, a = 1 },
        chromaSpeed = 0.08,
        showGlow = true,
        glowAlpha = 0.35,
        glowSize = 8,
        pulseOnBad = true,
        combatGlow = true,
        shine = false,
        shineInterval = 6,
        shineAlpha = 0.15,
        scanlines = false,
        scanlineAlpha = 0.18,
        fadeOutOfCombat = false,
        fadeAlpha = 0.4,

        -- Text mode
        fontSize = 12,
        layout = "VERTICAL",
        justify = "CENTER",
        showBackground = false,
        bgColor = { r = 0, g = 0, b = 0, a = 0.5 },
        showBorder = false,
        borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 },

        updateInterval = 0.5,
        fpsGood = 60,
        fpsWarn = 30,
        latGood = 100,
        latWarn = 250,
        combatMode = "ALWAYS",
        showTooltip = true,
        position = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 },
    },
}

---------------------------------------------------------------------
-- State
---------------------------------------------------------------------
local current = { fps = 0, home = 0, world = 0, bwIn = 0, bwOut = 0 }
local shownFps = 0

local samples = {}
local sampleIndex, sampleCount, sampleSum = 0, 0, 0
local sessionMin, sessionMax
local statsReadyAt = 0

local graphRing = {}
local latRing = {}
local graphIndex = 0

local textParts = {}
local ldbObject
local inCombat = false
local classColor

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function Clamp(v, lo, hi)
    if v < lo then return lo elseif v > hi then return hi end
    return v
end

local function Mix(c1, c2, t)
    return c1[1] + (c2[1] - c1[1]) * t, c1[2] + (c2[2] - c1[2]) * t, c1[3] + (c2[3] - c1[3]) * t
end

local function Hex(r, g, b)
    return format("ff%02x%02x%02x", floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5))
end

local function HSV(h, s, v)
    local i = floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    end
    return v, p, q
end

local gradA, gradB = CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 1)
local function Grad(tex, orient, r1, g1, b1, a1, r2, g2, b2, a2)
    gradA:SetRGBA(r1, g1, b1, a1)
    gradB:SetRGBA(r2, g2, b2, a2)
    tex:SetGradient(orient, gradA, gradB)
end

local function NewTex(parent, layer, sub)
    local t = parent:CreateTexture(nil, layer, nil, sub)
    t:SetTexture(WHITE)
    return t
end

local function GetClassColor()
    if not classColor then
        local _, class = UnitClass("player")
        local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        classColor = c and { r = c.r, g = c.g, b = c.b } or { r = 1, g = 1, b = 1 }
    end
    return classColor
end

-- FPS: higher is better
local function FpsRGB(v, p)
    if not p.colorCode then
        local c = p.textColor
        return c.r, c.g, c.b
    end
    local good, warn = p.fpsGood, p.fpsWarn
    if v >= good then return GOOD[1], GOOD[2], GOOD[3] end
    if not p.smoothColors or warn >= good then
        if v >= warn then return WARN[1], WARN[2], WARN[3] end
        return BAD[1], BAD[2], BAD[3]
    end
    if v >= warn then
        return Mix(WARN, GOOD, (v - warn) / (good - warn))
    end
    local bottom = warn * 0.5
    return Mix(BAD, WARN, Clamp((v - bottom) / max(warn - bottom, 1), 0, 1))
end

-- Latency: lower is better
local function LatRGB(v, p)
    if not p.colorCode then
        local c = p.textColor
        return c.r, c.g, c.b
    end
    local good, warn = p.latGood, p.latWarn
    if v <= good then return GOOD[1], GOOD[2], GOOD[3] end
    if not p.smoothColors or warn <= good then
        if v <= warn then return WARN[1], WARN[2], WARN[3] end
        return BAD[1], BAD[2], BAD[3]
    end
    if v <= warn then
        return Mix(GOOD, WARN, (v - good) / (warn - good))
    end
    local top = warn * 1.5
    return Mix(WARN, BAD, Clamp((v - warn) / max(top - warn, 1), 0, 1))
end

local function FormatFps(v, p)
    local text = format("%.0f", v)
    if not p.colorCode then return text end
    return format("|c%s%s|r", Hex(FpsRGB(v, p)), text)
end

local function FormatLatency(v, p)
    local text = format("%d ms", v)
    if not p.colorCode then return text end
    return format("|c%s%s|r", Hex(LatRGB(v, p)), text)
end

local function SignalLevel(v, p)
    if v <= p.latGood * 0.5 then return 4 end
    if v <= p.latGood then return 3 end
    if v <= p.latWarn then return 2 end
    return 1
end

local function MoodWord(v, p)
    if v >= p.fpsGood then return "SMOOTH" end
    if v >= p.fpsWarn then return "OKAY" end
    return "CHUG"
end

local function NotifyOptions()
    if AceConfigRegistry then
        AceConfigRegistry:NotifyChange(addonName)
    end
end

---------------------------------------------------------------------
-- Stats
---------------------------------------------------------------------
local function ResetStats()
    wipe(samples)
    sampleIndex, sampleCount, sampleSum = 0, 0, 0
    sessionMin, sessionMax = nil, nil
    statsReadyAt = GetTime() + WARMUP_SECONDS
end

local function RecordSample(fps, latency)
    -- Graph always records so it shows loading hitches too
    graphIndex = graphIndex % GRAPH_MAX + 1
    graphRing[graphIndex] = fps
    latRing[graphIndex] = latency

    -- Stats skip the first few seconds after a loading screen
    if GetTime() < statsReadyAt then return end

    sampleIndex = sampleIndex % SAMPLE_SIZE + 1
    local old = samples[sampleIndex]
    if old then
        sampleSum = sampleSum - old
    else
        sampleCount = sampleCount + 1
    end
    samples[sampleIndex] = fps
    sampleSum = sampleSum + fps

    if not sessionMin or fps < sessionMin then sessionMin = fps end
    if not sessionMax or fps > sessionMax then sessionMax = fps end
end

local function GetAverage()
    if sampleCount == 0 then return nil end
    return sampleSum / sampleCount
end

local function RingIndex(i, n)
    return (graphIndex - n + i - 1) % GRAPH_MAX + 1
end

---------------------------------------------------------------------
-- Root frame
---------------------------------------------------------------------
local frame = CreateFrame("Frame", "SharpFpsFrame", UIParent, "BackdropTemplate")
frame:SetSize(80, 20)
frame:SetFrameStrata("MEDIUM")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:SetDontSavePosition(true) -- we save position ourselves, keep layout cache out of it
frame:RegisterForDrag("LeftButton")
frame:Hide()
frame.targetAlpha = 1
frame.tweening = false
frame.chromaElapsed = 0

-- Classic text mode
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("CENTER")

---------------------------------------------------------------------
-- Glow (soft gradient halo around the frame, works in both styles)
---------------------------------------------------------------------
local glow = CreateFrame("Frame", nil, frame)
glow:SetAllPoints(frame)
glow:SetFrameLevel(frame:GetFrameLevel())

local glowTex = {
    TOP = NewTex(glow, "BACKGROUND"),
    BOTTOM = NewTex(glow, "BACKGROUND"),
    LEFT = NewTex(glow, "BACKGROUND"),
    RIGHT = NewTex(glow, "BACKGROUND"),
}

local pulse = glow:CreateAnimationGroup()
pulse:SetLooping("BOUNCE")
local pulseFade = pulse:CreateAnimation("Alpha")
pulseFade:SetFromAlpha(1)
pulseFade:SetToAlpha(0.2)
pulseFade:SetDuration(0.55)
pulseFade:SetSmoothing("IN_OUT")

---------------------------------------------------------------------
-- HUD
---------------------------------------------------------------------
local hud = CreateFrame("Frame", nil, frame, "BackdropTemplate")
hud:SetAllPoints(frame)
hud:SetFrameLevel(frame:GetFrameLevel() + 2)
hud:Hide()
hud.innerW = 100
hud.barW = 2
hud.barGap = 1

hud.bg = NewTex(hud, "BACKGROUND", -7)
hud.bg:SetPoint("TOPLEFT", 1, -1)
hud.bg:SetPoint("BOTTOMRIGHT", -1, 1)

hud.accent = NewTex(hud, "ARTWORK")
hud.accent:SetPoint("TOPLEFT", 1, -1)
hud.accent:SetPoint("BOTTOMLEFT", 1, 1)
hud.accent:SetWidth(3)

hud.fps = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.fpsLabel = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.fpsLabel:SetText("FPS")
hud.mood = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.avg = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.avg:SetJustifyH("RIGHT")
hud.low = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.low:SetJustifyH("RIGHT")
hud.ft = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hud.ft:SetJustifyH("RIGHT")

-- Pop when the FPS number changes mood bracket
hud.pop = hud.fps:CreateAnimationGroup()
local popUp = hud.pop:CreateAnimation("Scale")
popUp:SetScaleFrom(1, 1)
popUp:SetScaleTo(1.25, 1.25)
popUp:SetDuration(0.09)
popUp:SetOrder(1)
popUp:SetOrigin("LEFT", 0, 0)
local popDown = hud.pop:CreateAnimation("Scale")
popDown:SetScaleFrom(1.25, 1.25)
popDown:SetScaleTo(1, 1)
popDown:SetDuration(0.18)
popDown:SetOrder(2)
popDown:SetOrigin("LEFT", 0, 0)

hud.gaugeBg = NewTex(hud, "ARTWORK", 1)
hud.gaugeBg:SetVertexColor(1, 1, 1, 0.08)
hud.gaugeFill = NewTex(hud, "ARTWORK", 2)
hud.gaugeFill:SetPoint("TOPLEFT", hud.gaugeBg, "TOPLEFT")
hud.gaugeFill:SetPoint("BOTTOMLEFT", hud.gaugeBg, "BOTTOMLEFT")
hud.gaugeTick = NewTex(hud, "ARTWORK", 4)
hud.gaugeTick:SetVertexColor(1, 1, 1, 0.85)

hud.graphBg = NewTex(hud, "ARTWORK", 1)
hud.graphBg:SetVertexColor(1, 1, 1, 0.04)
hud.graphLine = NewTex(hud, "ARTWORK", 4)
hud.graphLine:SetHeight(1)
hud.graphLine:SetVertexColor(1, 1, 1, 0.25)

hud.graphBars = {}
for i = 1, GRAPH_MAX do
    hud.graphBars[i] = NewTex(hud, "ARTWORK", 3)
end

hud.fpsLines = {}
hud.latLines = {}
for i = 1, GRAPH_MAX - 1 do
    local l = hud:CreateLine(nil, "ARTWORK", nil, 5)
    l:SetTexture(WHITE)
    l:Hide()
    hud.fpsLines[i] = l

    local ll = hud:CreateLine(nil, "ARTWORK", nil, 6)
    ll:SetTexture(WHITE)
    ll:Hide()
    hud.latLines[i] = ll
end

local function NewRow(key, label)
    local row = { key = key }
    row.label = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.label:SetText(label)
    row.value = hud:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.value:SetJustifyH("RIGHT")
    row.bars = {}
    for j = 1, 4 do
        row.bars[j] = NewTex(hud, "ARTWORK", 2)
    end
    return row
end

hud.rows = {
    NewRow("world", "WORLD"),
    NewRow("home", "HOME"),
}

-- Effects layer: clipped so the shine and scanlines stay inside the panel
hud.fx = CreateFrame("Frame", nil, hud)
hud.fx:SetAllPoints(hud)
hud.fx:SetClipsChildren(true)

hud.shine = CreateFrame("Frame", nil, hud.fx)
hud.shine:SetSize(50, 50)
hud.shineL = NewTex(hud.shine, "OVERLAY")
hud.shineL:SetPoint("TOPLEFT")
hud.shineL:SetPoint("BOTTOMLEFT")
hud.shineL:SetWidth(25)
hud.shineR = NewTex(hud.shine, "OVERLAY")
hud.shineR:SetPoint("TOPRIGHT")
hud.shineR:SetPoint("BOTTOMRIGHT")
hud.shineR:SetWidth(25)

hud.shineAnim = hud.shine:CreateAnimationGroup()
hud.shineAnim:SetLooping("REPEAT")
hud.shineMove = hud.shineAnim:CreateAnimation("Translation")
hud.shineMove:SetDuration(0.9)
hud.shineMove:SetSmoothing("IN_OUT")

hud.scan = {}
for i = 1, SCANLINE_MAX do
    local t = NewTex(hud.fx, "OVERLAY", 7)
    t:SetHeight(1)
    t:Hide()
    hud.scan[i] = t
end

---------------------------------------------------------------------
-- Frame scripts
---------------------------------------------------------------------
local function FitFrame(force)
    local w = max(ceil(frame.text:GetStringWidth()) + PAD * 2, 20)
    local h = max(ceil(frame.text:GetStringHeight()) + PAD * 2, 10)
    -- Grow freely, only shrink on a forced refit so digit widths don't make it jitter
    if force or w > frame:GetWidth() or abs(h - frame:GetHeight()) > 0.5 then
        frame:SetSize(w, h)
    end
end

frame:SetScript("OnDragStart", function(self)
    if SharpFps.db.profile.locked then return end
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    local pos = SharpFps.db.profile.position
    pos.point = point
    pos.relativePoint = relativePoint
    pos.x = floor(x + 0.5)
    pos.y = floor(y + 0.5)
end)

frame:SetScript("OnEnter", function(self)
    self.hovered = true
    SharpFps:UpdateFade()
    if SharpFps.db.profile.showTooltip then
        SharpFps:ShowTooltip()
    end
end)

frame:SetScript("OnLeave", function(self)
    self.hovered = false
    SharpFps:UpdateFade()
    if GameTooltip:IsOwned(self) then
        GameTooltip:Hide()
    end
end)

frame:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" then
        if IsShiftKeyDown() then
            SharpFps:ToggleStyle()
        else
            SharpFps:OpenConfig()
        end
    elseif button == "MiddleButton" then
        SharpFps:CycleTheme()
    end
end)

-- Mouse wheel resizes while unlocked
frame:SetScript("OnMouseWheel", function(_, delta)
    local p = SharpFps.db.profile
    if p.locked then return end
    p.scale = Clamp(floor((p.scale + delta * 0.05) * 100 + 0.5) / 100, 0.5, 2)
    frame:SetScale(p.scale)
    NotifyOptions()
end)

-- Per frame work: smooth fading, the rolling FPS number, and chroma cycling
frame:SetScript("OnUpdate", function(self, elapsed)
    local a = self:GetAlpha()
    local target = self.targetAlpha
    if a ~= target then
        if abs(a - target) < 0.01 then
            self:SetAlpha(target)
        else
            self:SetAlpha(a + (target - a) * min(1, elapsed * 6))
        end
    end

    if self.tweening then
        local diff = current.fps - shownFps
        if abs(diff) < 0.5 then
            shownFps = current.fps
            self.tweening = false
        else
            shownFps = shownFps + diff * min(1, elapsed * 8)
        end
        SharpFps:DrawFpsValue()
    end

    if SharpFps.db.profile.accentMode == "CHROMA" then
        self.chromaElapsed = self.chromaElapsed + elapsed
        if self.chromaElapsed >= 0.033 then
            self.chromaElapsed = 0
            SharpFps:PaintAccent(SharpFps:GetAccentRGB())
        end
    end
end)

---------------------------------------------------------------------
-- Update driver (separate from the display so the broker feed keeps
-- updating even when the display is hidden by combat settings)
---------------------------------------------------------------------
local driver = CreateFrame("Frame")
driver:Hide()
driver.elapsed = 0
driver:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < SharpFps.db.profile.updateInterval then return end
    self.elapsed = 0
    SharpFps:Sample()
end)

---------------------------------------------------------------------
-- Sampling and drawing
---------------------------------------------------------------------
function SharpFps:Sample()
    local p = self.db.profile

    current.fps = GetFramerate()
    local bwIn, bwOut, home, world = GetNetStats()
    current.bwIn = bwIn or 0
    current.bwOut = bwOut or 0
    current.home = home or 0
    current.world = world or 0

    RecordSample(current.fps, current.world)

    if p.style == "HUD" and p.smoothNumbers then
        frame.tweening = true
    else
        shownFps = current.fps
    end

    self:RefreshDisplay()

    if GameTooltip:IsOwned(frame) then
        self:ShowTooltip()
    end
end

function SharpFps:BuildText()
    local p = self.db.profile
    wipe(textParts)
    if p.showFps then textParts[#textParts + 1] = "FPS: " .. FormatFps(current.fps, p) end
    if p.showHome then textParts[#textParts + 1] = "Home: " .. FormatLatency(current.home, p) end
    if p.showWorld then textParts[#textParts + 1] = "World: " .. FormatLatency(current.world, p) end
    local sep = (p.layout == "HORIZONTAL") and "   " or "\n"
    return concat(textParts, sep)
end

function SharpFps:DrawFpsValue()
    local p = self.db.profile
    if p.style ~= "HUD" or not p.showFps then return end

    local v = p.smoothNumbers and shownFps or current.fps
    local r, g, b = FpsRGB(v, p)

    local rounded = floor(v + 0.5)
    if rounded ~= hud.lastShown then
        hud.fps:SetText(tostring(rounded))
        hud.lastShown = rounded
    end
    hud.fps:SetTextColor(r, g, b, 1)

    if p.showMood then
        local word = MoodWord(v, p)
        if word ~= hud.lastMood then
            if hud.lastMood and not hud.pop:IsPlaying() then
                hud.pop:Play()
            end
            hud.mood:SetText(word)
            hud.lastMood = word
        end
        hud.mood:SetTextColor(r, g, b, 1)
    end

    if p.showFrametime then
        hud.ft:SetText(format("%.1f MS", 1000 / max(v, 1)))
    end

    if p.showGauge then
        local pct = Clamp(v / max(p.fpsCap, 1), 0, 1)
        hud.gaugeFill:SetWidth(max(1, hud.innerW * pct))
        Grad(hud.gaugeFill, "HORIZONTAL", r * 0.3, g * 0.3, b * 0.3, 1, r, g, b, 1)
    end
end

function SharpFps:UpdateGaugeTick()
    local p = self.db.profile
    local avg = GetAverage()
    local on = p.showFps and p.showGauge and p.showAvgTick and avg ~= nil
    hud.gaugeTick:SetShown(on)
    if not on then return end
    local x = hud.innerW * Clamp(avg / max(p.fpsCap, 1), 0, 1)
    hud.gaugeTick:ClearAllPoints()
    hud.gaugeTick:SetPoint("CENTER", hud.gaugeBg, "LEFT", x, 0)
    hud.gaugeTick:SetSize(2, 9)
end

function SharpFps:UpdateGraph()
    local p = self.db.profile
    local n = p.graphBars
    local height = p.graphHeight
    local style = p.graphStyle
    local drawBars = (style == "BARS" or style == "FILL")
    local drawLine = (style == "LINE" or style == "FILL")
    local barW, gap = hud.barW, hud.barGap
    local thick = p.lineThickness

    local scaleMax = p.fpsGood
    local latMax = p.latWarn
    for i = 1, n do
        local idx = RingIndex(i, n)
        local v = graphRing[idx]
        if v and v > scaleMax then scaleMax = v end
        local l = latRing[idx]
        if l and l > latMax then latMax = l end
    end
    scaleMax = scaleMax * 1.1
    latMax = latMax * 1.1

    local prevX, prevY, prevLX, prevLY
    for i = 1, n do
        local idx = RingIndex(i, n)
        local v = graphRing[idx]
        local bar = hud.graphBars[i]
        local x = (i - 1) * (barW + gap) + barW / 2

        if v then
            local h = max(1, height * v / scaleMax)
            local r, g, b = FpsRGB(v, p)

            if drawBars then
                bar:SetHeight(h)
                if style == "FILL" then
                    Grad(bar, "VERTICAL", r, g, b, 0.04, r, g, b, 0.35)
                else
                    Grad(bar, "VERTICAL", r, g, b, 0.25, r, g, b, 0.95)
                end
                bar:Show()
            else
                bar:Hide()
            end

            if drawLine and i > 1 then
                local seg = hud.fpsLines[i - 1]
                if prevX then
                    seg:SetStartPoint("BOTTOMLEFT", hud.graphBg, prevX, prevY)
                    seg:SetEndPoint("BOTTOMLEFT", hud.graphBg, x, h)
                    seg:SetThickness(thick)
                    seg:SetVertexColor(r, g, b, 1)
                    seg:Show()
                else
                    seg:Hide()
                end
            end
            prevX, prevY = x, h
        else
            bar:Hide()
            if i > 1 then hud.fpsLines[i - 1]:Hide() end
            prevX, prevY = nil, nil
        end

        if p.graphLatency and i > 1 then
            local seg = hud.latLines[i - 1]
            local l = latRing[idx]
            if l and prevLX then
                local ly = max(1, height * l / latMax)
                seg:SetStartPoint("BOTTOMLEFT", hud.graphBg, prevLX, prevLY)
                seg:SetEndPoint("BOTTOMLEFT", hud.graphBg, x, ly)
                seg:SetThickness(1)
                seg:SetVertexColor(LAT_LINE[1], LAT_LINE[2], LAT_LINE[3], 0.85)
                seg:Show()
            else
                seg:Hide()
            end
        end
        local lv = latRing[idx]
        if lv then
            prevLX, prevLY = x, max(1, height * lv / latMax)
        else
            prevLX, prevLY = nil, nil
        end
    end

    if not drawLine then
        for i = 1, GRAPH_MAX - 1 do hud.fpsLines[i]:Hide() end
    end
    if not p.graphLatency then
        for i = 1, GRAPH_MAX - 1 do hud.latLines[i]:Hide() end
    end

    local lineY = floor(height * p.fpsGood / scaleMax + 0.5)
    hud.graphLine:ClearAllPoints()
    hud.graphLine:SetPoint("BOTTOMLEFT", hud.graphBg, "BOTTOMLEFT", 0, lineY)
    hud.graphLine:SetPoint("BOTTOMRIGHT", hud.graphBg, "BOTTOMRIGHT", 0, lineY)
end

function SharpFps:UpdateHUD()
    local p = self.db.profile

    if p.showFps then
        self:DrawFpsValue()

        local avg = GetAverage()
        hud.avg:SetText("AVG " .. (avg and FormatFps(avg, p) or "..."))
        hud.low:SetText("LOW " .. (sessionMin and FormatFps(sessionMin, p) or "..."))
        self:UpdateGaugeTick()

        if p.showGraph then
            self:UpdateGraph()
        end
    end

    for _, row in ipairs(hud.rows) do
        if row.active then
            local v = current[row.key]
            local r, g, b = LatRGB(v, p)
            row.value:SetText(format("%d ms", v))
            row.value:SetTextColor(r, g, b, 1)
            local level = SignalLevel(v, p)
            for j = 1, 4 do
                if j <= level then
                    row.bars[j]:SetVertexColor(r, g, b, 1)
                else
                    row.bars[j]:SetVertexColor(0.5, 0.5, 0.5, 0.25)
                end
            end
        end
    end
end

function SharpFps:GetAccentRGB()
    local p = self.db.profile
    if p.accentMode == "CLASS" then
        local c = GetClassColor()
        return c.r, c.g, c.b
    elseif p.accentMode == "CUSTOM" then
        local c = p.accentColor
        return c.r, c.g, c.b
    elseif p.accentMode == "CHROMA" then
        return HSV((GetTime() * p.chromaSpeed) % 1, 0.85, 1)
    end
    return FpsRGB(current.fps, p)
end

function SharpFps:PaintAccent(r, g, b)
    local p = self.db.profile

    if p.style == "HUD" then
        Grad(hud.accent, "VERTICAL", r, g, b, 0.2, r, g, b, 1)
    end

    if p.showGlow then
        if inCombat and p.combatGlow then
            r, g, b = 1, 0.15, 0.15
        end
        local a = p.glowAlpha
        Grad(glowTex.TOP, "VERTICAL", r, g, b, a, r, g, b, 0)
        Grad(glowTex.BOTTOM, "VERTICAL", r, g, b, 0, r, g, b, a)
        Grad(glowTex.LEFT, "HORIZONTAL", r, g, b, 0, r, g, b, a)
        Grad(glowTex.RIGHT, "HORIZONTAL", r, g, b, a, r, g, b, 0)
    end
end

function SharpFps:UpdateAccent()
    local p = self.db.profile
    self:PaintAccent(self:GetAccentRGB())

    local bad = p.showGlow and p.pulseOnBad and current.fps < p.fpsWarn
    if bad and not pulse:IsPlaying() then
        pulse:Play()
    elseif not bad and pulse:IsPlaying() then
        pulse:Stop()
    end
end

function SharpFps:RefreshDisplay(forceFit)
    local p = self.db.profile

    if p.style == "HUD" then
        self:UpdateHUD()
    else
        frame.text:SetText(self:BuildText())
        FitFrame(forceFit)
    end

    self:UpdateAccent()

    if ldbObject then
        ldbObject.text = format("%s fps  %s", FormatFps(current.fps, p), FormatLatency(current.world, p))
    end
end

---------------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------------
function SharpFps:FillTooltip(tt)
    local p = self.db.profile
    local avg = GetAverage()

    tt:AddLine("Sharp FPS")
    tt:AddDoubleLine("Framerate", FormatFps(current.fps, p) .. " fps", 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Frame time", format("%.1f ms", 1000 / max(current.fps, 1)), 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Recent average", avg and (FormatFps(avg, p) .. " fps") or "warming up", 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Session low", sessionMin and (FormatFps(sessionMin, p) .. " fps") or "warming up", 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Session high", sessionMax and (FormatFps(sessionMax, p) .. " fps") or "warming up", 1, 1, 1, 1, 1, 1)
    tt:AddLine(" ")
    tt:AddDoubleLine("Home latency", FormatLatency(current.home, p), 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("World latency", FormatLatency(current.world, p), 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Download", format("%.1f KB/s", current.bwIn), 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Upload", format("%.1f KB/s", current.bwOut), 1, 1, 1, 1, 1, 1)
    tt:AddLine(" ")
    if not p.locked then
        tt:AddLine("Left drag to move, mouse wheel to resize", 0.6, 0.6, 0.6)
    end
    tt:AddLine("Right click for options", 0.6, 0.6, 0.6)
    tt:AddLine("Shift right click to swap style", 0.6, 0.6, 0.6)
    tt:AddLine("Middle click to cycle themes", 0.6, 0.6, 0.6)
end

function SharpFps:ShowTooltip()
    GameTooltip:SetOwner(frame, "ANCHOR_TOP")
    GameTooltip:ClearLines()
    self:FillTooltip(GameTooltip)
    GameTooltip:Show()
end

---------------------------------------------------------------------
-- Appearance and layout
---------------------------------------------------------------------
function SharpFps:GetFont()
    local p = self.db.profile
    local path = LSM:Fetch("font", p.font) or STANDARD_TEXT_FONT
    local flags = (p.outline ~= "NONE") and p.outline or ""
    return path, flags
end

function SharpFps:ApplyTextMode()
    local p = self.db.profile
    local path, flags = self:GetFont()

    frame.text:SetFont(path, p.fontSize, flags)
    local c = p.textColor
    frame.text:SetTextColor(c.r, c.g, c.b, c.a)

    frame.text:ClearAllPoints()
    if p.justify == "LEFT" then
        frame.text:SetPoint("LEFT", frame, "LEFT", PAD, 0)
    elseif p.justify == "RIGHT" then
        frame.text:SetPoint("RIGHT", frame, "RIGHT", -PAD, 0)
    else
        frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    end
    frame.text:SetJustifyH(p.justify)

    if p.showBackground or p.showBorder then
        frame:SetBackdrop({
            bgFile = p.showBackground and WHITE or nil,
            edgeFile = p.showBorder and WHITE or nil,
            edgeSize = p.showBorder and 1 or nil,
        })
        local bg = p.bgColor
        frame:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
        local bc = p.borderColor
        frame:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a)
    else
        frame:SetBackdrop(nil)
    end
end

function SharpFps:LayoutHUD()
    local p = self.db.profile
    local path, flags = self:GetFont()
    local tc = p.textColor

    local W = p.hudWidth
    local pad = 8
    local left = pad + 4
    local innerW = W - left - pad
    hud.innerW = innerW

    local big = p.hudFontSize
    local small = max(9, floor(big * 0.42 + 0.5))

    -- Background and border
    hud:SetBackdrop({ edgeFile = WHITE, edgeSize = 1 })
    local bc = p.hudBorderColor
    hud:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a)
    local top, bottom = p.bgTop, p.bgBottom
    Grad(hud.bg, "VERTICAL", bottom.r, bottom.g, bottom.b, bottom.a, top.r, top.g, top.b, top.a)

    local y = -pad
    local lastGap = 0

    -- Big FPS block
    hud.fps:SetShown(p.showFps)
    hud.fpsLabel:SetShown(p.showFps)
    hud.avg:SetShown(p.showFps)
    hud.low:SetShown(p.showFps)
    hud.mood:SetShown(p.showFps and p.showMood)
    hud.ft:SetShown(p.showFps and p.showFrametime)

    if p.showFps then
        hud.fps:SetFont(path, big, flags)
        for _, fs in ipairs({ hud.fpsLabel, hud.mood, hud.avg, hud.low, hud.ft }) do
            fs:SetFont(path, small, flags)
        end

        hud.fpsLabel:SetTextColor(tc.r, tc.g, tc.b, tc.a * 0.8)
        hud.avg:SetTextColor(tc.r, tc.g, tc.b, tc.a * 0.7)
        hud.low:SetTextColor(tc.r, tc.g, tc.b, tc.a * 0.7)
        hud.ft:SetTextColor(tc.r, tc.g, tc.b, tc.a * 0.7)

        hud.fps:ClearAllPoints()
        hud.fps:SetPoint("TOPLEFT", hud, "TOPLEFT", left, y)
        hud.fpsLabel:ClearAllPoints()
        hud.fpsLabel:SetPoint("BOTTOMLEFT", hud.fps, "BOTTOMRIGHT", 3, 2)
        hud.mood:ClearAllPoints()
        hud.mood:SetPoint("BOTTOMLEFT", hud.fpsLabel, "TOPLEFT", 0, 1)

        hud.avg:ClearAllPoints()
        hud.avg:SetPoint("TOPRIGHT", hud, "TOPRIGHT", -pad, y - 1)
        hud.low:ClearAllPoints()
        hud.low:SetPoint("TOPRIGHT", hud.avg, "BOTTOMRIGHT", 0, -2)
        hud.ft:ClearAllPoints()
        hud.ft:SetPoint("TOPRIGHT", hud.low, "BOTTOMRIGHT", 0, -2)

        local cornerLines = p.showFrametime and 3 or 2
        local cornerH = cornerLines * small + (cornerLines - 1) * 2 + 1
        local blockH = max(big, cornerH)

        hud.lastShown = nil
        hud.lastMood = nil

        lastGap = 4
        y = y - blockH - lastGap
    end

    -- Gauge
    local gaugeOn = p.showFps and p.showGauge
    hud.gaugeBg:SetShown(gaugeOn)
    hud.gaugeFill:SetShown(gaugeOn)
    if not gaugeOn then hud.gaugeTick:Hide() end
    if gaugeOn then
        hud.gaugeBg:ClearAllPoints()
        hud.gaugeBg:SetPoint("TOPLEFT", hud, "TOPLEFT", left, y)
        hud.gaugeBg:SetSize(innerW, 4)
        lastGap = 6
        y = y - 4 - lastGap
    end

    -- Graph
    local graphOn = p.showFps and p.showGraph
    hud.graphBg:SetShown(graphOn)
    hud.graphLine:SetShown(graphOn)
    for i = 1, GRAPH_MAX do hud.graphBars[i]:Hide() end
    for i = 1, GRAPH_MAX - 1 do
        hud.fpsLines[i]:Hide()
        hud.latLines[i]:Hide()
    end

    if graphOn then
        local n = p.graphBars
        hud.graphBg:ClearAllPoints()
        hud.graphBg:SetPoint("TOPLEFT", hud, "TOPLEFT", left, y)
        hud.graphBg:SetSize(innerW, p.graphHeight)

        local gap = 1
        local barW = (innerW - (n - 1) * gap) / n
        hud.barW = barW
        hud.barGap = gap
        for i = 1, n do
            local bar = hud.graphBars[i]
            bar:ClearAllPoints()
            bar:SetPoint("BOTTOMLEFT", hud.graphBg, "BOTTOMLEFT", (i - 1) * (barW + gap), 0)
            bar:SetWidth(barW)
        end
        lastGap = 6
        y = y - p.graphHeight - lastGap
    end

    -- Latency rows
    hud.rows[1].active = p.showWorld
    hud.rows[2].active = p.showHome
    local rowH = max(small, 10)
    for _, row in ipairs(hud.rows) do
        row.label:SetShown(row.active)
        row.value:SetShown(row.active)
        for j = 1, 4 do row.bars[j]:SetShown(row.active) end

        if row.active then
            row.label:SetFont(path, small, flags)
            row.value:SetFont(path, small, flags)
            row.label:SetTextColor(tc.r, tc.g, tc.b, tc.a * 0.8)

            row.label:ClearAllPoints()
            row.label:SetPoint("TOPLEFT", hud, "TOPLEFT", left, y)
            row.value:ClearAllPoints()
            row.value:SetPoint("TOPRIGHT", hud, "TOPRIGHT", -pad, y)

            local unit = max(2, floor(rowH / 4))
            for j = 4, 1, -1 do
                local bar = row.bars[j]
                bar:ClearAllPoints()
                bar:SetSize(3, unit * j)
                if j == 4 then
                    bar:SetPoint("BOTTOMRIGHT", row.value, "BOTTOMLEFT", -6, 1)
                else
                    bar:SetPoint("BOTTOMRIGHT", row.bars[j + 1], "BOTTOMLEFT", -1, 0)
                end
            end

            lastGap = 5
            y = y - rowH - lastGap
        end
    end

    local height = max(-y - lastGap + pad, pad * 2)
    frame:SetSize(W, height)

    self:LayoutEffects(W, height)
end

function SharpFps:LayoutEffects(W, H)
    local p = self.db.profile

    -- Shine sweep
    hud.shineAnim:Stop()
    if p.shine then
        local a = p.shineAlpha
        Grad(hud.shineL, "HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, a)
        Grad(hud.shineR, "HORIZONTAL", 1, 1, 1, a, 1, 1, 1, 0)
        hud.shine:ClearAllPoints()
        hud.shine:SetPoint("TOPLEFT", hud, "TOPLEFT", -60, 0)
        hud.shine:SetSize(50, H)
        hud.shineMove:SetOffset(W + 120, 0)
        hud.shineMove:SetStartDelay(p.shineInterval)
        hud.shine:Show()
        hud.shineAnim:Play()
    else
        hud.shine:Hide()
    end

    -- CRT scanlines
    local count = p.scanlines and min(SCANLINE_MAX, floor(H / 3)) or 0
    for i = 1, SCANLINE_MAX do
        local t = hud.scan[i]
        if i <= count then
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", hud, "TOPLEFT", 1, -(i * 3) + 1)
            t:SetPoint("TOPRIGHT", hud, "TOPRIGHT", -1, -(i * 3) + 1)
            t:SetVertexColor(0, 0, 0, p.scanlineAlpha)
            t:Show()
        else
            t:Hide()
        end
    end
end

function SharpFps:LayoutGlow()
    local p = self.db.profile
    glow:SetShown(p.showGlow)
    if not p.showGlow then return end

    local s = p.glowSize
    local t = glowTex

    t.TOP:ClearAllPoints()
    t.TOP:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -s, 0)
    t.TOP:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", s, 0)
    t.TOP:SetHeight(s)

    t.BOTTOM:ClearAllPoints()
    t.BOTTOM:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -s, 0)
    t.BOTTOM:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", s, 0)
    t.BOTTOM:SetHeight(s)

    t.LEFT:ClearAllPoints()
    t.LEFT:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, 0)
    t.LEFT:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 0)
    t.LEFT:SetWidth(s)

    t.RIGHT:ClearAllPoints()
    t.RIGHT:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)
    t.RIGHT:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, 0)
    t.RIGHT:SetWidth(s)
end

function SharpFps:UpdateFramePosition()
    local pos = self.db.profile.position
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
end

function SharpFps:UpdateMouse()
    local p = self.db.profile
    -- Fully click through when locked with no tooltip
    frame:EnableMouse((not p.locked) or p.showTooltip)
    -- Only grab the wheel while unlocked so camera zoom still works over a locked frame
    frame:EnableMouseWheel(not p.locked)
end

function SharpFps:UpdateFade()
    local p = self.db.profile
    if p.fadeOutOfCombat and not inCombat and not frame.hovered then
        frame.targetAlpha = p.fadeAlpha
    else
        frame.targetAlpha = 1
    end
end

function SharpFps:UpdateVisibility()
    local p = self.db.profile
    if not p.enabled then
        frame:Hide()
        driver:Hide()
        return
    end

    driver:Show()

    local show
    if p.combatMode == "HIDE_IN_COMBAT" then
        show = not inCombat
    elseif p.combatMode == "ONLY_IN_COMBAT" then
        show = inCombat
    else
        show = true
    end
    frame:SetShown(show)
end

function SharpFps:ApplyAll()
    local p = self.db.profile

    frame:SetScale(p.scale)

    if p.style == "HUD" then
        frame.text:Hide()
        frame:SetBackdrop(nil)
        hud:Show()
        self:LayoutHUD()
    else
        hud:Hide()
        hud.shineAnim:Stop()
        frame.text:Show()
        frame.tweening = false
        self:ApplyTextMode()
    end

    self:LayoutGlow()
    self:UpdateFramePosition()
    self:UpdateMouse()
    self:UpdateVisibility()
    self:UpdateFade()

    shownFps = current.fps
    self:RefreshDisplay(true)
end

function SharpFps:ApplyTheme(key)
    local theme = THEMES[key]
    local p = self.db.profile
    p.theme = key
    if not theme then return end

    local function copy(dst, src)
        dst.r, dst.g, dst.b, dst.a = src[1], src[2], src[3], src[4]
    end

    copy(p.bgTop, theme.bgTop)
    copy(p.bgBottom, theme.bgBottom)
    copy(p.hudBorderColor, theme.border)
    copy(p.accentColor, theme.accent)
    copy(p.textColor, theme.text)
    p.accentMode = theme.accentMode
    p.showGlow = theme.glow
    p.glowAlpha = theme.glowAlpha
    p.shine = theme.shine or false
    p.scanlines = theme.scanlines or false
    if theme.graphStyle then
        p.graphStyle = theme.graphStyle
    end
    if theme.font and LSM:IsValid("font", theme.font) then
        p.font = theme.font
    end
end

function SharpFps:CycleTheme()
    local p = self.db.profile
    local nextIndex = 1
    for i, key in ipairs(THEME_ORDER) do
        if key == p.theme then
            nextIndex = i % #THEME_ORDER + 1
            break
        end
    end
    local key = THEME_ORDER[nextIndex]
    self:ApplyTheme(key)
    self:ApplyAll()
    NotifyOptions()
    self:Print("Theme: " .. THEMES[key].name)
end

function SharpFps:ToggleStyle()
    local p = self.db.profile
    p.style = (p.style == "HUD") and "TEXT" or "HUD"
    self:ApplyAll()
    NotifyOptions()
end

function SharpFps:OpenConfig()
    AceConfigDialog:Open(addonName)
end

---------------------------------------------------------------------
-- Events and callbacks
---------------------------------------------------------------------
function SharpFps:PLAYER_ENTERING_WORLD()
    -- Pause stat collection briefly after any loading screen
    statsReadyAt = GetTime() + WARMUP_SECONDS
end

function SharpFps:PLAYER_REGEN_DISABLED()
    inCombat = true
    self:UpdateVisibility()
    self:UpdateFade()
    self:UpdateAccent()
end

function SharpFps:PLAYER_REGEN_ENABLED()
    inCombat = false
    self:UpdateVisibility()
    self:UpdateFade()
    self:UpdateAccent()
end

function SharpFps:OnMediaRegistered(_, mediaType, key)
    -- Fonts from other addons can register after we load
    if mediaType == "font" and key == self.db.profile.font then
        self:ApplyAll()
    end
end

function SharpFps:OnProfileChanged()
    self:ApplyAll()
end

---------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------
function SharpFps:SlashCommand(input)
    local cmd = strtrim(input or ""):lower()
    local p = self.db.profile

    if cmd == "lock" then
        p.locked = not p.locked
        self:UpdateMouse()
        NotifyOptions()
        self:Print(p.locked and "Frame locked." or "Frame unlocked.")
    elseif cmd == "reset" then
        p.position.point = "CENTER"
        p.position.relativePoint = "CENTER"
        p.position.x = 0
        p.position.y = 0
        p.scale = 1
        frame:SetScale(1)
        self:UpdateFramePosition()
        NotifyOptions()
        self:Print("Position and scale reset.")
    elseif cmd == "stats" then
        ResetStats()
        self:Print("Session stats cleared.")
    elseif cmd == "toggle" then
        p.enabled = not p.enabled
        self:UpdateVisibility()
        NotifyOptions()
        self:Print(p.enabled and "Enabled." or "Disabled.")
    elseif cmd == "style" then
        self:ToggleStyle()
        self:Print("Style: " .. (p.style == "HUD" and "HUD" or "Classic Text"))
    elseif cmd == "theme" or cmd == "next" then
        self:CycleTheme()
    elseif THEMES[cmd:upper()] then
        self:ApplyTheme(cmd:upper())
        self:ApplyAll()
        NotifyOptions()
        self:Print("Theme: " .. THEMES[cmd:upper()].name)
    elseif cmd == "help" then
        self:Print("/sfps  open options")
        self:Print("/sfps lock  lock or unlock the frame")
        self:Print("/sfps reset  move the frame back to center at normal size")
        self:Print("/sfps stats  clear session low/high/average")
        self:Print("/sfps toggle  turn the display on or off")
        self:Print("/sfps style  swap between HUD and classic text")
        self:Print("/sfps theme  cycle to the next theme")
        self:Print("/sfps midnight, neon, synthwave, glass, frost, terminal, ember, gold, class  apply a theme")
    else
        self:OpenConfig()
    end
end

---------------------------------------------------------------------
-- Options
---------------------------------------------------------------------
local function GetOpt(info)
    return SharpFps.db.profile[info[#info]]
end

local function SetOpt(info, value)
    SharpFps.db.profile[info[#info]] = value
    SharpFps:ApplyAll()
end

local function GetColor(info)
    local c = SharpFps.db.profile[info[#info]]
    return c.r, c.g, c.b, c.a
end

local function SetColor(info, r, g, b, a)
    local key = info[#info]
    local c = SharpFps.db.profile[key]
    c.r, c.g, c.b, c.a = r, g, b, a or 1
    if THEME_KEYS[key] then
        SharpFps.db.profile.theme = "CUSTOM"
    end
    SharpFps:ApplyAll()
end

local function SetThemed(info, value)
    SharpFps.db.profile[info[#info]] = value
    SharpFps.db.profile.theme = "CUSTOM"
    SharpFps:ApplyAll()
end

local function NotHUD() return SharpFps.db.profile.style ~= "HUD" end
local function NotText() return SharpFps.db.profile.style ~= "TEXT" end
local function ColorCodingOff() return not SharpFps.db.profile.colorCode end
local function GlowOff() return not SharpFps.db.profile.showGlow end
local function GraphOff() return NotHUD() or not SharpFps.db.profile.showGraph end

local function BuildOptions()
    local options = {
        name = "Sharp FPS",
        type = "group",
        childGroups = "tab",
        get = GetOpt,
        set = SetOpt,
        args = {
            general = {
                name = "General",
                type = "group",
                order = 1,
                args = {
                    enabled = { name = "Enabled", type = "toggle", order = 1 },
                    locked = { name = "Lock Frame", desc = "Prevent dragging and mouse wheel resizing.", type = "toggle", order = 2 },
                    showTooltip = {
                        name = "Hover Tooltip",
                        desc = "Show session stats and bandwidth on hover. With the frame locked and this off, the frame becomes fully click through.",
                        type = "toggle",
                        order = 3,
                    },
                    style = {
                        name = "Display Style",
                        desc = "HUD is the full panel with gauge, graph and signal bars. Classic Text is the original plain readout.",
                        type = "select",
                        values = { HUD = "HUD", TEXT = "Classic Text" },
                        order = 4,
                    },
                    showHeader = { name = "Shown Values", type = "header", order = 10 },
                    showFps = { name = "Show FPS", type = "toggle", order = 11 },
                    showWorld = { name = "Show World Latency", desc = "Latency to the game world server. This is the one that matters for combat.", type = "toggle", order = 12 },
                    showHome = { name = "Show Home Latency", desc = "Latency to the login and chat servers.", type = "toggle", order = 13 },
                    behaviorHeader = { name = "Behavior", type = "header", order = 20 },
                    combatMode = {
                        name = "Combat Behavior",
                        type = "select",
                        values = { ALWAYS = "Always Show", HIDE_IN_COMBAT = "Hide In Combat", ONLY_IN_COMBAT = "Only In Combat" },
                        order = 21,
                    },
                    updateInterval = {
                        name = "Update Interval",
                        desc = "Seconds between samples. Lower is more responsive, higher is lighter.",
                        type = "range", min = 0.1, max = 2, step = 0.1,
                        order = 22,
                    },
                    fadeOutOfCombat = { name = "Fade Out Of Combat", desc = "Dim the display while out of combat. Hovering brings it back.", type = "toggle", order = 23 },
                    fadeAlpha = {
                        name = "Faded Opacity",
                        type = "range", min = 0, max = 1, step = 0.05, isPercent = true,
                        disabled = function() return not SharpFps.db.profile.fadeOutOfCombat end,
                        order = 24,
                    },
                },
            },
            look = {
                name = "Look",
                type = "group",
                order = 2,
                args = {
                    theme = {
                        name = "Theme",
                        desc = "Applies a full preset: colors, glow, graph style and effects. Tweak any color afterward and it becomes Custom. Middle click the frame to cycle themes.",
                        type = "select",
                        values = THEME_VALUES,
                        sorting = THEME_SORTING,
                        set = function(_, value)
                            SharpFps:ApplyTheme(value)
                            SharpFps:ApplyAll()
                        end,
                        order = 1,
                    },
                    font = {
                        name = "Font",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        values = LSM:HashTable("font"),
                        order = 2,
                    },
                    outline = {
                        name = "Outline",
                        type = "select",
                        values = { NONE = "None", OUTLINE = "Outline", THICKOUTLINE = "Thick Outline" },
                        order = 3,
                    },
                    scale = { name = "Scale", desc = "You can also mouse wheel over the frame while unlocked.", type = "range", min = 0.5, max = 2, step = 0.05, isPercent = true, order = 4 },
                    colorHeader = { name = "Colors", type = "header", order = 10 },
                    textColor = { name = "Label Color", type = "color", hasAlpha = true, get = GetColor, set = SetColor, order = 11 },
                    colorCode = { name = "Color Code Values", desc = "Color values green, yellow or red using the Thresholds tab.", type = "toggle", order = 12 },
                    smoothColors = {
                        name = "Smooth Color Blending",
                        desc = "Blend gradually between green, yellow and red instead of hard steps.",
                        type = "toggle",
                        disabled = ColorCodingOff,
                        order = 13,
                    },
                    accentHeader = { name = "Accent", type = "header", order = 20 },
                    accentMode = {
                        name = "Accent Color Source",
                        desc = "Drives the side stripe and the glow. Chroma cycles through the rainbow.",
                        type = "select",
                        values = { STATUS = "Follows FPS", CLASS = "Class Color", CUSTOM = "Custom Color", CHROMA = "Chroma Cycle" },
                        set = SetThemed,
                        order = 21,
                    },
                    accentColor = {
                        name = "Custom Accent",
                        type = "color", hasAlpha = false,
                        get = GetColor, set = SetColor,
                        disabled = function() return SharpFps.db.profile.accentMode ~= "CUSTOM" end,
                        order = 22,
                    },
                    chromaSpeed = {
                        name = "Chroma Speed",
                        type = "range", min = 0.01, max = 0.5, step = 0.01,
                        disabled = function() return SharpFps.db.profile.accentMode ~= "CHROMA" end,
                        order = 23,
                    },
                    glowHeader = { name = "Glow", type = "header", order = 30 },
                    showGlow = { name = "Show Glow", type = "toggle", set = SetThemed, order = 31 },
                    glowAlpha = {
                        name = "Glow Intensity",
                        type = "range", min = 0.05, max = 1, step = 0.05, isPercent = true,
                        set = SetThemed,
                        disabled = GlowOff,
                        order = 32,
                    },
                    glowSize = { name = "Glow Size", type = "range", min = 2, max = 24, step = 1, disabled = GlowOff, order = 33 },
                    pulseOnBad = {
                        name = "Pulse On Low FPS",
                        desc = "Throb the glow when FPS drops below your Warning threshold.",
                        type = "toggle",
                        disabled = GlowOff,
                        order = 34,
                    },
                    combatGlow = {
                        name = "Red Glow In Combat",
                        desc = "Turn the glow red while you are in combat.",
                        type = "toggle",
                        disabled = GlowOff,
                        order = 35,
                    },
                },
            },
            hud = {
                name = "HUD",
                type = "group",
                order = 3,
                disabled = NotHUD,
                args = {
                    hudWidth = { name = "Width", type = "range", min = 120, max = 340, step = 1, order = 1 },
                    hudFontSize = { name = "FPS Number Size", type = "range", min = 14, max = 48, step = 1, order = 2 },
                    smoothNumbers = { name = "Rolling Number", desc = "Animate the FPS number toward each new reading.", type = "toggle", order = 3 },
                    showMood = { name = "Mood Word", desc = "SMOOTH, OKAY or CHUG next to the number. The number pops when it changes.", type = "toggle", order = 4 },
                    showFrametime = { name = "Frame Time", desc = "Milliseconds per frame under the AVG and LOW readouts.", type = "toggle", order = 5 },
                    gaugeHeader = { name = "Gauge", type = "header", order = 10 },
                    showGauge = { name = "Show Gauge", type = "toggle", order = 11 },
                    fpsCap = {
                        name = "Gauge Full At",
                        desc = "FPS that fills the gauge completely. Match it to your monitor refresh rate.",
                        type = "range", min = 30, max = 360, step = 1,
                        disabled = function() return NotHUD() or not SharpFps.db.profile.showGauge end,
                        order = 12,
                    },
                    showAvgTick = {
                        name = "Average Marker",
                        desc = "A small white tick on the gauge at your recent average.",
                        type = "toggle",
                        disabled = function() return NotHUD() or not SharpFps.db.profile.showGauge end,
                        order = 13,
                    },
                    graphHeader = { name = "Graph", type = "header", order = 20 },
                    showGraph = { name = "Show Graph", type = "toggle", order = 21 },
                    graphStyle = {
                        name = "Graph Style",
                        type = "select",
                        values = { BARS = "Bars", LINE = "Line", FILL = "Line + Fill" },
                        disabled = GraphOff,
                        order = 22,
                    },
                    graphLatency = {
                        name = "Latency Overlay",
                        desc = "Draw world latency as a blue line over the FPS graph, on its own scale.",
                        type = "toggle",
                        disabled = GraphOff,
                        order = 23,
                    },
                    graphBars = { name = "Graph Samples", type = "range", min = 10, max = GRAPH_MAX, step = 1, disabled = GraphOff, order = 24 },
                    graphHeight = { name = "Graph Height", type = "range", min = 12, max = 80, step = 1, disabled = GraphOff, order = 25 },
                    lineThickness = {
                        name = "Line Thickness",
                        type = "range", min = 1, max = 4, step = 0.5,
                        disabled = function() return GraphOff() or SharpFps.db.profile.graphStyle == "BARS" end,
                        order = 26,
                    },
                    panelHeader = { name = "Panel", type = "header", order = 30 },
                    bgTop = { name = "Background Top", type = "color", hasAlpha = true, get = GetColor, set = SetColor, order = 31 },
                    bgBottom = { name = "Background Bottom", type = "color", hasAlpha = true, get = GetColor, set = SetColor, order = 32 },
                    hudBorderColor = { name = "Border", type = "color", hasAlpha = true, get = GetColor, set = SetColor, order = 33 },
                    fxHeader = { name = "Effects", type = "header", order = 40 },
                    shine = { name = "Shine Sweep", desc = "A glossy highlight that sweeps across the panel.", type = "toggle", set = SetThemed, order = 41 },
                    shineInterval = {
                        name = "Shine Every (sec)",
                        type = "range", min = 1, max = 30, step = 1,
                        disabled = function() return NotHUD() or not SharpFps.db.profile.shine end,
                        order = 42,
                    },
                    shineAlpha = {
                        name = "Shine Strength",
                        type = "range", min = 0.05, max = 0.5, step = 0.01, isPercent = true,
                        disabled = function() return NotHUD() or not SharpFps.db.profile.shine end,
                        order = 43,
                    },
                    scanlines = { name = "CRT Scanlines", desc = "Retro monitor lines over the panel.", type = "toggle", set = SetThemed, order = 44 },
                    scanlineAlpha = {
                        name = "Scanline Strength",
                        type = "range", min = 0.05, max = 0.6, step = 0.01, isPercent = true,
                        disabled = function() return NotHUD() or not SharpFps.db.profile.scanlines end,
                        order = 45,
                    },
                },
            },
            text = {
                name = "Classic Text",
                type = "group",
                order = 4,
                disabled = NotText,
                args = {
                    fontSize = { name = "Font Size", type = "range", min = 8, max = 32, step = 1, order = 1 },
                    layout = { name = "Layout", type = "select", values = { VERTICAL = "Stacked", HORIZONTAL = "Single Line" }, order = 2 },
                    justify = { name = "Text Alignment", type = "select", values = { LEFT = "Left", CENTER = "Center", RIGHT = "Right" }, order = 3 },
                    backdropHeader = { name = "Background", type = "header", order = 10 },
                    showBackground = { name = "Show Background", type = "toggle", order = 11 },
                    bgColor = {
                        name = "Background Color",
                        type = "color", hasAlpha = true,
                        get = GetColor, set = SetColor,
                        disabled = function() return NotText() or not SharpFps.db.profile.showBackground end,
                        order = 12,
                    },
                    showBorder = { name = "Show Border", type = "toggle", order = 13 },
                    borderColor = {
                        name = "Border Color",
                        type = "color", hasAlpha = true,
                        get = GetColor, set = SetColor,
                        disabled = function() return NotText() or not SharpFps.db.profile.showBorder end,
                        order = 14,
                    },
                },
            },
            thresholds = {
                name = "Thresholds",
                type = "group",
                order = 5,
                disabled = ColorCodingOff,
                args = {
                    note = {
                        name = "Values at or better than Good show green, at or better than Warning show yellow, anything worse shows red. The Good FPS value also sets the reference line on the graph and the mood word.",
                        type = "description",
                        order = 1,
                    },
                    fpsHeader = { name = "Framerate", type = "header", order = 10 },
                    fpsGood = { name = "Good FPS", type = "range", min = 10, max = 240, step = 1, order = 11 },
                    fpsWarn = { name = "Warning FPS", type = "range", min = 5, max = 240, step = 1, order = 12 },
                    latHeader = { name = "Latency", type = "header", order = 20 },
                    latGood = { name = "Good Latency (ms)", type = "range", min = 10, max = 1000, step = 5, order = 21 },
                    latWarn = { name = "Warning Latency (ms)", type = "range", min = 10, max = 2000, step = 5, order = 22 },
                },
            },
        },
    }

    if AceDBOptions then
        local profiles = AceDBOptions:GetOptionsTable(SharpFps.db)
        profiles.order = 100
        options.args.profiles = profiles
    end

    return options
end

---------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------
function SharpFps:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SharpFpsDB", defaults, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

    AceConfig:RegisterOptionsTable(addonName, BuildOptions)
    AceConfigDialog:AddToBlizOptions(addonName, "Sharp FPS")

    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")

    self:RegisterChatCommand("sfps", "SlashCommand")
    self:RegisterChatCommand("sharpfps", "SlashCommand")

    if LDB then
        ldbObject = LDB:NewDataObject(addonName, {
            type = "data source",
            label = "FPS",
            text = "SharpFps",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            OnClick = function() SharpFps:OpenConfig() end,
            OnTooltipShow = function(tt) SharpFps:FillTooltip(tt) end,
        })
    end
end

function SharpFps:OnEnable()
    inCombat = InCombatLockdown() and true or false
    ResetStats()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self:ApplyAll()
    self:Sample()
end
