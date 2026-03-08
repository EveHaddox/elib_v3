
Elib.RegisterFont("UI.Toast.Title", "Space Grotesk Bold", 16)
Elib.RegisterFont("UI.Toast.Body", "Space Grotesk", 15)

Elib.Toasts = Elib.Toasts or {}
Elib.ToastAnchor = Elib.ToastAnchor or "bottom-right"

local toasts = Elib.Toasts

local TOAST_MAX_WIDTH   = 340
local TOAST_PADDING     = 10
local TOAST_SPACING     = 8
local TOAST_EDGE_MARGIN = 16
local TOAST_ACCENT_W    = 4
local TOAST_ICON_SIZE   = 18
local TOAST_MAX_VISIBLE = 6

local ANIM_SLIDE_IN  = 0.25
local ANIM_SLIDE_OUT = 0.20
local ANIM_FADE_OUT  = 0.20

local DEFAULT_DURATION = 4

local function GetTypeColor(toastType)
    if toastType == "success" then
        return Elib.Colors.Positive
    elseif toastType == "error" then
        return Elib.Colors.Negative
    elseif toastType == "warning" then
        return Elib.Colors.Gold
    end
    return Elib.Colors.Primary
end

local TYPE_ICONS = {
    success = "https://construct-cdn.physgun.com/images/2b2f5ea0-3cb3-4207-82db-bb8484da738a.png", -- checkmark
    error   = "https://construct-cdn.physgun.com/images/204e6270-1a86-4af6-9350-66cfd5dd8b5a.png", -- X close
    warning = "https://construct-cdn.physgun.com/images/5fa7c9c8-d9d5-4c77-aed6-975b4fb039b5.png", -- reset/warning
}

local nextID = 0

local function CreateToast(text, toastType, duration, iconURL)
    nextID = nextID + 1
    toastType = toastType or "info"

    local maxTextW = Elib.Scale(TOAST_MAX_WIDTH)
        - Elib.Scale(TOAST_PADDING) * 2
        - Elib.Scale(TOAST_ACCENT_W)
        - Elib.Scale(4)

    local hasIcon = iconURL or TYPE_ICONS[toastType]
    if hasIcon then
        maxTextW = maxTextW - Elib.Scale(TOAST_ICON_SIZE) - Elib.Scale(6)
    end

    local wrappedText = Elib.WrapText(text, maxTextW, "UI.Toast.Body")

    Elib.SetFont("UI.Toast.Body")
    local _, lineH = Elib.GetTextSize("Tg")
    local lines = 1
    for _ in wrappedText:gmatch("\n") do
        lines = lines + 1
    end

    local textH = lineH * lines
    local toastH = math.max(textH + Elib.Scale(TOAST_PADDING) * 2, Elib.Scale(40))

    local now = RealTime()

    return {
        id        = nextID,
        text      = text,
        wrapped   = wrappedText,
        type      = toastType,
        duration  = duration or DEFAULT_DURATION,
        iconURL   = iconURL or TYPE_ICONS[toastType],
        height    = toastH,
        width     = Elib.Scale(TOAST_MAX_WIDTH),

        spawnTime   = now,
        expireTime  = now + (duration or DEFAULT_DURATION),
        removeTime  = nil, -- set when starting exit anim

        -- Animation state
        slideIn   = 0, -- 0 = offscreen, 1 = fully visible
        fadeOut   = 1, -- 1 = opaque, 0 = gone

        -- Hover pause
        hovered = false,
    }
end


-- text: message you want to display
-- toastType: "info", "success", "error", or "warning" (defaults to "info")
-- duration: how long it stays visible in seconds (default is 4)
-- iconURL: optional custom icon URL, otherwise the default icon for the type is used
function Elib.Toast(text, toastType, duration, iconURL)
    if not text or text == "" then return end

    local toast = CreateToast(text, toastType, duration, iconURL)

    table.insert(toasts, toast)

    while #toasts > TOAST_MAX_VISIBLE do
        table.remove(toasts, 1)
    end
end

function Elib.ClearToasts()
    table.Empty(toasts)
end

-- anchor: "bottom-right", "bottom-left", "top-right", "top-left", "bottom-center"
function Elib.SetToastPosition(anchor)
    Elib.ToastAnchor = anchor or "bottom-right"
end

local function IsMouseInRect(x, y, w, h)
    local mx, my = gui.MouseX(), gui.MouseY()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

hook.Add("HUDPaint", "Elib.Toasts.Render", function()
    if #toasts == 0 then return end

    local now = RealTime()
    local scrW, scrH = ScrW(), ScrH()
    local anchor = Elib.ToastAnchor or "bottom-right"

    local edgeMargin = Elib.Scale(TOAST_EDGE_MARGIN)
    local spacing = Elib.Scale(TOAST_SPACING)
    local padding = Elib.Scale(TOAST_PADDING)
    local accentW = Elib.Scale(TOAST_ACCENT_W)
    local cornerR = Elib.Scale(6)
    local iconSz = Elib.Scale(TOAST_ICON_SIZE)

    local stackUp = anchor:find("bottom") ~= nil
    local alignRight = anchor:find("right") ~= nil
    local alignCenter = anchor:find("center") ~= nil

    local baseY
    if stackUp then
        baseY = scrH - edgeMargin
    else
        baseY = edgeMargin
    end

    local cursorActive = vgui.CursorVisible()
    local toRemove = {}

    for i, toast in ipairs(toasts) do
        local dt = FrameTime()

        if toast.slideIn < 1 then
            toast.slideIn = math.Approach(toast.slideIn, 1, dt / ANIM_SLIDE_IN)
        end

        local toastW = toast.width
        local toastH = toast.height

        local toastX
        if alignCenter then
            toastX = scrW / 2 - toastW / 2
        elseif alignRight then
            local slideOffset = (1 - toast.slideIn) * (toastW + edgeMargin)
            toastX = scrW - edgeMargin - toastW + slideOffset
        else
            local slideOffset = (1 - toast.slideIn) * (toastW + edgeMargin)
            toastX = edgeMargin - slideOffset
        end

        if stackUp then
            baseY = baseY - toastH
        end

        local toastY = baseY

        if cursorActive and IsMouseInRect(toastX, toastY, toastW, toastH) then
            toast.hovered = true
            toast.expireTime = math.max(toast.expireTime, now + 0.5)
        else
            toast.hovered = false
        end

        if now >= toast.expireTime and not toast.removeTime then
            toast.removeTime = now
        end

        if toast.removeTime then
            local fadeProgress = (now - toast.removeTime) / ANIM_FADE_OUT
            toast.fadeOut = math.max(1 - fadeProgress, 0)

            if toast.fadeOut <= 0 then
                table.insert(toRemove, i)
            end
        end

        local alpha = 255 * toast.slideIn * toast.fadeOut
        if alpha <= 0 then
            if not stackUp then
                baseY = baseY + toastH + spacing
            else
                baseY = baseY - spacing
            end
            continue
        end

        local bgCol = Elib.OffsetColor(Elib.Colors.Background, 14)
        bgCol = Color(bgCol.r, bgCol.g, bgCol.b, alpha)

        local accentCol = GetTypeColor(toast.type)
        accentCol = Color(accentCol.r, accentCol.g, accentCol.b, alpha)

        local textCol = Color(Elib.Colors.PrimaryText.r, Elib.Colors.PrimaryText.g, Elib.Colors.PrimaryText.b, alpha)

        local shadowA = math.min(alpha * 0.15, 40)
        Elib.DrawRoundedBox(cornerR + 1, toastX + 1, toastY + 2, toastW, toastH, Color(0, 0, 0, shadowA))
        Elib.DrawRoundedBox(cornerR, toastX, toastY, toastW, toastH, bgCol)
        Elib.DrawRoundedBoxEx(cornerR, toastX, toastY, accentW, toastH, accentCol, true, false, true, false)

        local contentX = toastX + accentW + padding
        local contentY = toastY + padding

        if toast.iconURL then
            local iconY = toastY + (toastH - iconSz) / 2
            Elib.DrawImage(contentX, iconY, iconSz, iconSz, toast.iconURL, Color(accentCol.r, accentCol.g, accentCol.b, alpha))
            contentX = contentX + iconSz + Elib.Scale(6)
        end

        Elib.DrawText(toast.wrapped, "UI.Toast.Body", contentX, contentY, textCol)

        if toast.hovered then
            local hoverCol = Color(255, 255, 255, math.min(alpha * 0.05, 12))
            Elib.DrawRoundedBox(cornerR, toastX, toastY, toastW, toastH, hoverCol)
        end

        if not toast.removeTime then
            local elapsed = now - toast.spawnTime
            local total = toast.duration
            local progress = math.Clamp(1 - elapsed / total, 0, 1)

            if progress > 0 and progress < 1 then
                local barH = Elib.Scale(2)
                local barW = (toastW - accentW - cornerR) * progress
                local barX = toastX + accentW
                local barY = toastY + toastH - barH

                local barCol = Color(accentCol.r, accentCol.g, accentCol.b, alpha * 0.5)
                surface.SetDrawColor(barCol)
                surface.DrawRect(barX, barY, barW, barH)
            end
        end

        if not stackUp then
            baseY = baseY + toastH + spacing
        else
            baseY = baseY - spacing
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(toasts, toRemove[i])
    end
end)


hook.Add("Elib.FullyLoaded", "Elib:ToastConfig", function()
    local positions = { "bottom-right", "bottom-left", "top-right", "top-left", "bottom-center" }

    Elib.Config:AddValue(
        "Elib",
        "client",
        "general",
        "toast_position",
        "Toast Position",
        "bottom-right",
        "Dropdown",
        -90,
        function(value)
            if not value then return end
            Elib.SetToastPosition(value)
        end,
        false,
        positions
    )

    Elib.Config:AddValue(
        "Elib",
        "client",
        "general",
        "toast_duration",
        "Toast Duration (seconds)",
        4,
        "Number",
        -89,
        function(value)
            if not value then return end
            DEFAULT_DURATION = math.Clamp(tonumber(value) or 4, 1, 30)
        end,
        false
    )
end)

concommand.Add("elib_toast_test", function()
    Elib.Toast("This is an info toast.", "info")

    timer.Simple(0.3, function()
        Elib.Toast("Settings saved successfully!", "success")
    end)

    timer.Simple(0.6, function()
        Elib.Toast("Something went wrong. Please try again.", "error", 6)
    end)

    timer.Simple(0.9, function()
        Elib.Toast("Disk space is running low.", "warning", 5)
    end)
end)