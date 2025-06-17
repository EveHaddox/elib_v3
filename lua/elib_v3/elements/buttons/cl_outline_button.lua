// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "OutlineThicness", "OutlineThicness", FORCE_NUMBER)

function PANEL:Init()
    self:SetOutlineThicness(Elib.Scale(2))
end

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        Elib.DrawOutlinedRoundedBox(Elib.Scale(4), 0, 0, w, h, self.DisabledCol, self:GetOutlineThicness())
        self:PaintExtra(w, h)
        return
    end

    local bgCol = self.NormalCol
    local fill = false

    if self:IsDown() or self:GetToggle() then
        bgCol = self.ClickedCol
        fill = true
    elseif self:IsHovered() then
        bgCol = self.HoverCol
        fill = true
    end

    self.BackgroundCol = Elib.LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)

    if fill then
        Elib.DrawRoundedBox(Elib.Scale(4), 0, 0, w, h, self.BackgroundCol)
    else
        Elib.DrawOutlinedRoundedBox(Elib.Scale(4), 0, 0, w, h, self.BackgroundCol, self:GetOutlineThicness())
    end
    
    self:PaintExtra(w, h)
end

vgui.Register("Elib.OutlineButton", PANEL, "Elib.Button")