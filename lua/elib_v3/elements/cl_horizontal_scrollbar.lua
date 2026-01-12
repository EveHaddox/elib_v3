// Script made by Eve Haddox
// discord evehaddox


///////////////////////////
// Horizontal Scroll Bar //
///////////////////////////
local PANEL = {}

function PANEL:Init()
    self.NormalCol = Elib.Colors.Scroller
    self.HoverCol = Elib.OffsetColor(self.NormalCol, 15)

    self.Colour = Elib.CopyColor(self.NormalCol)
end

function PANEL:OnMousePressed()
    self:GetParent():Grip(1)
end

function PANEL:Paint(w, h)
    self.Colour = Elib.LerpColor(FrameTime() * 12, self.Colour,
        (self:IsHovered() or self:GetParent().Dragging) and self.HoverCol or self.NormalCol
    )

    Elib.DrawRoundedBox(h / 2, 0, 0, w, h, self.Colour)
end

vgui.Register("Elib.HorizontalScrollbarGrip", PANEL, "Panel")

PANEL = {}

AccessorFunc(PANEL, "m_bVisibleFullWidth", "VisibleFullWidth", FORCE_BOOL)

function PANEL:Init()
    self.Offset = 0
    self.Scroll = 0
    self.CanvasSize = 1
    self.BarSize = 1

    self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Background, 5)

    self.Scrollbar = vgui.Create("Elib.HorizontalScrollbarGrip", self)
    self:SetVisibleFullWidth(false)
end

function PANEL:SetEnabled(b)
    if not b then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end

    self:SetMouseInputEnabled(b)

    if not self:GetVisibleFullWidth() then
        self:SetVisible(b)
    end

    if self.Enabled != b then
        self:GetParent():InvalidateLayout()

        if self:GetParent().OnScrollbarAppear then
            self:GetParent():OnScrollbarAppear()
        end
    end

    self.Enabled = b
end

function PANEL:GetEnabled()
    return self.Enabled
end

function PANEL:Value()
    return self.Pos
end

function PANEL:BarScale()
    if self.BarSize == 0 then return 1 end
    return self.BarSize / (self.CanvasSize + self.BarSize)
end

function PANEL:SetUp(barSize, canvasSize)
    self.BarSize = barSize
    self.CanvasSize = math.max(canvasSize - barSize, 1)

    self:SetEnabled(canvasSize > barSize)

    self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
    if not self:IsVisible() then return false end
    return self:AddScroll(dlta * -2)
end

function PANEL:AddScroll(dlta)
    local oldScroll = self:GetScroll()

    dlta = dlta * 25
    self:SetScroll(oldScroll + dlta)

    return oldScroll != self:GetScroll()
end

function PANEL:SetScroll(scrll)
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp(scrll, 0, self.CanvasSize + 75)

    self:InvalidateLayout()

    local func = self:GetParent().OnHScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:LimitScroll()
    if self.Scroll < 0 or self.Scroll > self.CanvasSize then
        self.Scroll = math.Clamp(self.Scroll, -75, self.CanvasSize + 75)
    end
end

function PANEL:AnimateTo(scrll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function(an, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, an.StartPos, an.TargetPos))
    end
end

function PANEL:GetScroll()
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

function PANEL:GetOffset()
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

function PANEL:Think() end

function PANEL:OnMousePressed()
    local x = self:CursorPos()
    if x > self.Scrollbar.x then
        self:SetScroll(self:GetScroll() + self.BarSize)
    else
        self:SetScroll(self:GetScroll() - self.BarSize)
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)

    self.Scrollbar.Depressed = false
end

function PANEL:OnCursorMoved(x, y)
    if not self.Enabled or not self.Dragging then return end

    x = self:ScreenToLocal(gui.MouseX(), 0) - self.HoldPos

    local trackSize = self:GetWide() - self.Scrollbar:GetWide()
    x = x / trackSize

    self:SetScroll(math.Clamp(x * self.CanvasSize, 0, self.CanvasSize))
end

function PANEL:Grip()
    if not self.Enabled or self.BarSize == 0 then return end

    self:MouseCapture(true)
    self.Dragging = true

    self.HoldPos = self.Scrollbar:ScreenToLocal(gui.MouseX(), 0)

    self.Scrollbar.Depressed = true
end

function PANEL:PerformLayout(w, h)
    self:LimitScroll()

    local scroll = self:GetScroll() / self.CanvasSize
    local barSize = math.max(self:BarScale() * self:GetWide(), 10)
    local track = self:GetWide() - barSize
    track = track + 1

    scroll = scroll * track

    local barStart = math.max(scroll, 0)
    local barEnd = math.min(scroll + barSize, self:GetWide())

    self.Scrollbar:SetPos(barStart, 0)
    self.Scrollbar:SetSize(barEnd - barStart, h)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(h / 2, 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("Elib.HorizontalScrollbar", PANEL, "Panel")