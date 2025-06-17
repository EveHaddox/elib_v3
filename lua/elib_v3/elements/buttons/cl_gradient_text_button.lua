// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextSpacing", "TextSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)

Elib.RegisterFont("UI.TextButton", "Space Grotesk SemiBold", 20)

function PANEL:Init()
    self:SetText("Button")
    self:SetTextAlign(TEXT_ALIGN_CENTER)
    self:SetTextSpacing(Elib.Scale(6))
    self:SetFont("UI.TextButton")

    self:SetSize(Elib.Scale(100), Elib.Scale(30))
end

function PANEL:SizeToText()
    Elib.SetFont(self:GetFont())
    self:SetSize(Elib.GetTextSize(self:GetText()) + Elib.Scale(14), Elib.Scale(30))
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()

    if not self:IsEnabled() then
        Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)
        return
    end

    Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.SecondaryText, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.GradientTextButton", PANEL, "Elib.GradientButton")