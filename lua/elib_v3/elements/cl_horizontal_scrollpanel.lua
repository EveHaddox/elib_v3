// Script made by Eve Haddox
// discord evehaddox


/////////////////////////////
// Horizontal Scroll Panel //
/////////////////////////////
local PANEL = {}

AccessorFunc(PANEL, "Padding", "Padding")
AccessorFunc(PANEL, "Canvas", "Canvas")
AccessorFunc(PANEL, "ScrollbarTop", "ScrollbarTopSide")
AccessorFunc(PANEL, "BarDockShouldOffset", "BarDockShouldOffset", FORCE_BOOL)

function PANEL:Init()
    self.Canvas = vgui.Create("Panel", self)
    self.Canvas.OnMousePressed = function(s, code) s:GetParent():OnMousePressed(code) end
    self.Canvas:SetMouseInputEnabled(true)
    self.Canvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    self.HBar = vgui.Create("Elib.HorizontalScrollbar", self)
    self.HBar:Dock(BOTTOM)

    self:SetPadding(0)
    self:SetMouseInputEnabled(true)

    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)

    self.ScrollDelta = 0
    self.ScrollReturnWait = 0

    self:SetBarDockShouldOffset(true)
    self.HBar:SetTall(Elib.Scale(8))

    self.Canvas.PerformLayout = function(s, w, h)
        self:LayoutContent(w, h)
    end
end

function PANEL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

function PANEL:OnChildAdded(child)
    self:AddItem(child)
end

function PANEL:SizeToContents()
    self:SetSize(self.Canvas:GetSize())
end

function PANEL:GetHBar()
    return self.HBar
end

function PANEL:GetCanvas()
    return self.Canvas
end

function PANEL:InnerHeight()
    return self:GetCanvas():GetTall()
end

function PANEL:Rebuild()
    self:GetCanvas():SizeToChildren(true, false)

    if self.m_bNoSizing and self:GetCanvas():GetWide() < self:GetWide() then
        self:GetCanvas():SetPos((self:GetWide() - self:GetCanvas():GetWide()) * 0.5, 0)
    end
end

function PANEL:Think()
    if not self.lastThink then self.lastThink = CurTime() end
    local elapsed = CurTime() - self.lastThink
    self.lastThink = CurTime()

    if self.ScrollDelta > 0 then
        self.HBar:OnMouseWheeled(self.ScrollDelta / 1)

        if self.HBar.Scroll >= 0 then
            self.ScrollDelta = self.ScrollDelta - 10 * elapsed
        end
        if self.ScrollDelta < 0 then self.ScrollDelta = 0 end
    elseif self.ScrollDelta < 0 then
        self.HBar:OnMouseWheeled(self.ScrollDelta / 1)

        if self.HBar.Scroll <= self.HBar.CanvasSize then
            self.ScrollDelta = self.ScrollDelta + 10 * elapsed
        end
        if self.ScrollDelta > 0 then self.ScrollDelta = 0 end
    end

    if self.ScrollReturnWait >= 1 then
        if self.HBar.Scroll < 0 then
            if self.HBar.Scroll <= -75 and self.ScrollDelta > 0 then self.ScrollDelta = self.ScrollDelta / 2 end

            self.ScrollDelta = self.ScrollDelta + (self.HBar.Scroll / 1500 - 0.01) * 100 * elapsed

        elseif self.HBar.Scroll > self.HBar.CanvasSize then
            if self.HBar.Scroll >= self.HBar.CanvasSize + 75 and self.ScrollDelta < 0 then self.ScrollDelta = self.ScrollDelta / 2 end

            self.ScrollDelta = self.ScrollDelta + ((self.HBar.Scroll - self.HBar.CanvasSize) / 1500 + 0.01) * 100 * elapsed
        end
    else
        self.ScrollReturnWait = self.ScrollReturnWait + 10 * elapsed
    end
end

function PANEL:OnMouseWheeled(delta)
    if (delta > 0 and self.HBar.Scroll <= self.HBar.CanvasSize * 0.005) or
            (delta < 0 and self.HBar.Scroll >= self.HBar.CanvasSize * 0.995) then
        self.ScrollDelta = self.ScrollDelta + delta / 10
        return
    end

    self.ScrollDelta = delta / 2
    self.ScrollReturnWait = 0
end

function PANEL:OnHScroll(iOffset)
    self.Canvas:SetPos(iOffset, 0)
end

function PANEL:ScrollToChild(panel)
    self:PerformLayout()

    local x = self.Canvas:GetChildPosition(panel) + panel:GetWide() * 0.5
    x = x - self:GetWide() * 0.5

    self.HBar:AnimateTo(x, 0.5, 0, 0.5)
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
    if self:GetScrollbarTopSide() then
        self.HBar:Dock(TOP)
    else
        self.HBar:Dock(BOTTOM)
    end

    local tall = self:GetTall()
    local xPos = 0
    local yPos = 0

    self:Rebuild()

    self.HBar:SetUp(self:GetWide(), self.Canvas:GetWide())
    xPos = self.HBar:GetOffset()

    if self.HBar.Enabled or not self:GetBarDockShouldOffset() then
        tall = tall - self.HBar:GetTall()

        if self:GetScrollbarTopSide() then
            yPos = self.HBar:GetTall()
        end
    end

    self.Canvas:SetPos(xPos, yPos)
    self.Canvas:SetTall(tall)

    self:Rebuild()
end

function PANEL:Clear()
    return self.Canvas:Clear()
end

function PANEL:Paint(w, h) end

vgui.Register("Elib.HorizontalScrollPanel", PANEL, "DPanel")