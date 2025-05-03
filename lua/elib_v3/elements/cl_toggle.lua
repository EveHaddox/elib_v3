// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()
    self:SetIsToggle(true)

    local boxSize = Elib.Scale(20)
    self:SetSize(boxSize * 1.8, boxSize)

    self.BackgroundCol = Elib.CopyColor(Elib.Colors.Primary)
    self.MainCol = Elib.OffsetColor(Elib.Colors.Header, 10)
end

function PANEL:PaintBackground(w, h)
    local bgCol = Elib.Colors.Negative

    if self:IsDown() or self:GetToggle() then
        bgCol = Elib.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = Elib.LerpColor(animTime, self.BackgroundCol, bgCol)

    Elib.DrawRoundedBox(Elib.Scale(h / 3.2), 2, h * .1, w - 4, h * .8, self.BackgroundCol)
end

function PANEL:Paint(w, h)
    self:PaintBackground(w, h)

    if self:IsDown() or self:GetToggle() then
        Elib.DrawCircle(w - h, 0, h, h, self.MainCol)
    else
        Elib.DrawCircle(0, 0, h, h, self.MainCol)
    end
    

    self:PaintExtra(w, h)
end

vgui.Register("Elib.Toggle", PANEL, "Elib.Button")