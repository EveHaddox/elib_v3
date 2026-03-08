
Elib.RegisterFont("UI.Tooltip.Title", "Space Grotesk Bold", 15)
Elib.RegisterFont("UI.Tooltip.Body", "Space Grotesk", 14)

local TOOLTIP_MAX_WIDTH = 260
local TOOLTIP_PADDING   = 8
local TOOLTIP_OFFSET_X  = 14
local TOOLTIP_OFFSET_Y  = 18
local TOOLTIP_DELAY     = 0.35   -- seconds before showing
local TOOLTIP_FADE_IN   = 0.12
local TOOLTIP_FADE_OUT  = 0.08

local registeredTooltips = {}
local activeTooltip = nil
local hoverStart = 0
local currentAlpha = 0
local lastPanel = nil

function Elib.SetTooltip(panel, data, delay)
    if not IsValid(panel) then return end

    if isstring(data) then
        data = { body = data }
    end

    registeredTooltips[panel] = {
        title = data.title,
        body  = data.body or "",
        icon  = data.icon,
        delay = delay or TOOLTIP_DELAY,
    }

    local oldRemove = panel.OnRemove
    panel.OnRemove = function(self, ...)
        registeredTooltips[self] = nil
        if lastPanel == self then
            lastPanel = nil
            activeTooltip = nil
        end
        if oldRemove then return oldRemove(self, ...) end
    end
end

function Elib.RemoveTooltip(panel)
    registeredTooltips[panel] = nil
    if lastPanel == panel then
        lastPanel = nil
        activeTooltip = nil
    end
end

function Elib.HasTooltip(panel)
    return registeredTooltips[panel] ~= nil
end

-- because nicely done right? I hate this.
local function ComputeTooltipSize(data)
    local maxW = Elib.Scale(TOOLTIP_MAX_WIDTH)
    local pad = Elib.Scale(TOOLTIP_PADDING)
    local innerW = maxW - pad * 2

    local hasIcon = data.icon and data.icon ~= ""
    local iconSz = Elib.Scale(16)
    local textAreaW = innerW
    if hasIcon then
        textAreaW = textAreaW - iconSz - Elib.Scale(6)
    end

    local totalH = pad
    local actualW = 0

    -- title
    if data.title and data.title ~= "" then
        Elib.SetFont("UI.Tooltip.Title")
        local tw = Elib.GetTextSize(data.title)
        local _, th = Elib.GetTextSize("Tg")
        actualW = math.max(actualW, tw)
        totalH = totalH + th + Elib.Scale(3)
    end

    -- body
    if data.body and data.body ~= "" then
        local wrappedBody = Elib.WrapText(data.body, textAreaW, "UI.Tooltip.Body")
        data._wrappedBody = wrappedBody

        Elib.SetFont("UI.Tooltip.Body")
        local _, lineH = Elib.GetTextSize("Tg")
        local lines = 1
        for _ in wrappedBody:gmatch("\n") do
            lines = lines + 1
        end

        -- fattest boy wins
        for line in (wrappedBody .. "\n"):gmatch("(.-)\n") do
            local lw = Elib.GetTextSize(line)
            actualW = math.max(actualW, lw)
        end

        totalH = totalH + lineH * lines
    end

    totalH = totalH + pad

    -- do we need an icon? Make fatter...
    if hasIcon then
        actualW = actualW + iconSz + Elib.Scale(6)
    end

    local finalW = math.min(actualW + pad * 2, maxW)
    finalW = math.max(finalW, Elib.Scale(60))

    return finalW, totalH
end

-- which panel do we find here?
local function FindHoveredTooltipPanel()
    if not vgui.CursorVisible() then return nil end

    local pnl = vgui.GetHoveredPanel()
    local check = pnl
    local depth = 0

    while IsValid(check) and depth < 10 do
        if registeredTooltips[check] then
            return check
        end
        check = check:GetParent()
        depth = depth + 1
    end

    return nil
end

local function CreateOverlayPanel()
    if IsValid(Elib.TooltipOverlay) then
        Elib.TooltipOverlay:Remove()
    end

    local overlay = vgui.Create("DPanel")
    overlay:SetParent(vgui.GetWorldPanel())
    overlay:SetDrawOnTop(true)
    overlay:SetMouseInputEnabled(false)
    overlay:SetKeyboardInputEnabled(false)
    overlay:SetPaintBackgroundEnabled(false)
    overlay:SetPaintBorderEnabled(false)
    overlay:NoClipping(true)

    overlay:SetPos(0, 0)
    overlay:SetSize(0, 0)
    overlay:SetVisible(true)

    function overlay:Think()
        local dt = FrameTime()
        local now = RealTime()

        local hoveredPanel = FindHoveredTooltipPanel()

        if hoveredPanel ~= lastPanel then
            lastPanel = hoveredPanel
            hoverStart = now
            if hoveredPanel then
                activeTooltip = nil
            end
        end

        local shouldShow = false
        if IsValid(hoveredPanel) and registeredTooltips[hoveredPanel] then
            local data = registeredTooltips[hoveredPanel]
            local delay = data.delay or TOOLTIP_DELAY

            if now - hoverStart >= delay then
                shouldShow = true
                activeTooltip = data
            end
        end

        if shouldShow then
            currentAlpha = math.Approach(currentAlpha, 1, dt / TOOLTIP_FADE_IN)
        else
            currentAlpha = math.Approach(currentAlpha, 0, dt / TOOLTIP_FADE_OUT)
        end

        if currentAlpha <= 0 then
            activeTooltip = nil
        end

        if currentAlpha <= 0 or not activeTooltip then
            self:SetSize(0, 0)
            return
        end

        local tipW, tipH = ComputeTooltipSize(activeTooltip)

        local mx, my = gui.MouseX(), gui.MouseY()
        local offsetX = Elib.Scale(TOOLTIP_OFFSET_X)
        local offsetY = Elib.Scale(TOOLTIP_OFFSET_Y)

        local tipX = mx + offsetX
        local tipY = my + offsetY

        local scrW, scrH = ScrW(), ScrH()

        if tipX + tipW > scrW - 4 then
            tipX = mx - tipW - Elib.Scale(4)
        end
        if tipY + tipH > scrH - 4 then
            tipY = my - tipH - Elib.Scale(4)
        end
        tipX = math.max(tipX, 4)
        tipY = math.max(tipY, 4)

        self:SetPos(tipX, tipY)
        self:SetSize(tipW, tipH)
    end

    function overlay:Paint(w, h)
        if currentAlpha <= 0 or not activeTooltip then return end

        local data = activeTooltip
        local alpha = 255 * currentAlpha
        local pad = Elib.Scale(TOOLTIP_PADDING)
        local cornerR = Elib.Scale(5)

        local shadowA = math.min(alpha * 0.2, 50)
        Elib.DrawRoundedBox(cornerR + 1, 1, 2, w, h, Color(0, 0, 0, shadowA))

        local bgCol = Elib.OffsetColor(Elib.Colors.Background, 18)
        Elib.DrawRoundedBox(cornerR, 0, 0, w, h, Color(bgCol.r, bgCol.g, bgCol.b, alpha))

        local borderCol = Elib.OffsetColor(Elib.Colors.Background, 32)
        Elib.DrawRoundedBox(cornerR, 0, 0, w, h, Color(borderCol.r, borderCol.g, borderCol.b, alpha * 0.4), 1)

        local contentX = pad
        local contentY = pad

        local hasIcon = data.icon and data.icon ~= ""
        local iconSz = Elib.Scale(16)

        -- icin
        if hasIcon then
            local iconY = (h - iconSz) / 2
            local iconCol = Color(Elib.Colors.PrimaryText.r, Elib.Colors.PrimaryText.g, Elib.Colors.PrimaryText.b, alpha)
            Elib.DrawImage(contentX, iconY, iconSz, iconSz, data.icon, iconCol)
            contentX = contentX + iconSz + Elib.Scale(6)
        end

        -- title
        if data.title and data.title ~= "" then
            local titleCol = Color(Elib.Colors.PrimaryText.r, Elib.Colors.PrimaryText.g, Elib.Colors.PrimaryText.b, alpha)
            Elib.DrawSimpleText(data.title, "UI.Tooltip.Title", contentX, contentY, titleCol, TEXT_ALIGN_LEFT)
            Elib.SetFont("UI.Tooltip.Title")
            local _, titleH = Elib.GetTextSize("Tg")
            contentY = contentY + titleH + Elib.Scale(3)
        end

        -- body
        if data._wrappedBody and data._wrappedBody ~= "" then
            local bodyCol = Color(Elib.Colors.SecondaryText.r, Elib.Colors.SecondaryText.g, Elib.Colors.SecondaryText.b, alpha)
            Elib.DrawText(data._wrappedBody, "UI.Tooltip.Body", contentX, contentY, bodyCol)
        elseif data.body and data.body ~= "" then
            local bodyCol = Color(Elib.Colors.SecondaryText.r, Elib.Colors.SecondaryText.g, Elib.Colors.SecondaryText.b, alpha)
            Elib.DrawSimpleText(data.body, "UI.Tooltip.Body", contentX, contentY, bodyCol, TEXT_ALIGN_LEFT)
        end
    end

    Elib.TooltipOverlay = overlay
    return overlay
end

hook.Add("InitPostEntity", "Elib.Tooltip.Init", function()
    timer.Simple(0, CreateOverlayPanel)
end)

hook.Add("OnScreenSizeChanged", "Elib.Tooltip.RecreateOverlay", function()
    timer.Simple(0, CreateOverlayPanel)
end)

timer.Create("Elib.Tooltip.Cleanup", 5, 0, function()
    for panel, _ in pairs(registeredTooltips) do
        if not IsValid(panel) then
            registeredTooltips[panel] = nil
        end
    end
end)

-- menu v2 compat
hook.Add("VGUICreated", "Elib.Tooltip.AutoRegister", function(name, panel)
    if not panel then return end

    timer.Simple(0, function()
        if not IsValid(panel) then return end

        if panel.GetTooltip and isfunction(panel.GetTooltip) then
            local tip = panel:GetTooltip()
            if tip and tip ~= "" then
                Elib.SetTooltip(panel, tip)
            end
        end
    end)
end)


-- force all panels to get this functions. makes my life easy.
local panelMeta = FindMetaTable("Panel")
if panelMeta then
    function panelMeta:SetElibTooltip(data, delay)
        Elib.SetTooltip(self, data, delay)
        return self
    end

    function panelMeta:RemoveElibTooltip()
        Elib.RemoveTooltip(self)
        return self
    end
end

-- testing shit ignore
concommand.Add("elib_tooltip_test", function()
    local frame = vgui.Create("Elib.Frame")
    frame:SetTitle("Tooltip Test")
    frame:SetSize(Elib.Scale(400), Elib.Scale(300))
    frame:Center()
    frame:MakePopup()

    local btn1 = vgui.Create("Elib.TextButton", frame)
    btn1:SetText("Simple Tooltip")
    btn1:Dock(TOP)
    btn1:DockMargin(10, 50, 10, 5)
    btn1:SetTall(Elib.Scale(36))
    btn1:SetElibTooltip("This is a simple text tooltip")

    local btn2 = vgui.Create("Elib.TextButton", frame)
    btn2:SetText("Rich Tooltip")
    btn2:Dock(TOP)
    btn2:DockMargin(10, 5, 10, 5)
    btn2:SetTall(Elib.Scale(36))
    btn2:SetElibTooltip({
        title = "Export Settings",
        body  = "Saves all current configuration values to a local file that can be shared with other players.",
    })

    local btn3 = vgui.Create("Elib.TextButton", frame)
    btn3:SetText("Icon Tooltip")
    btn3:Dock(TOP)
    btn3:DockMargin(10, 5, 10, 5)
    btn3:SetTall(Elib.Scale(36))
    btn3:SetElibTooltip({
        title = "Save",
        body  = "Write changes to disk.",
        icon  = "https://construct-cdn.physgun.com/images/2b2f5ea0-3cb3-4207-82db-bb8484da738a.png",
    })

    local btn4 = vgui.Create("Elib.TextButton", frame)
    btn4:SetText("Slow Tooltip (1.5s)")
    btn4:Dock(TOP)
    btn4:DockMargin(10, 5, 10, 5)
    btn4:SetTall(Elib.Scale(36))
    btn4:SetElibTooltip("This one took a while to appear!", 1.5)
end)