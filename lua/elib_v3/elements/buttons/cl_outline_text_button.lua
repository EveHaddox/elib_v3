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

    self.TextColor = Elib.Colors.PrimaryText
end

function PANEL:SizeToText()
    Elib.SetFont(self:GetFont())
    self:SetSize(Elib.GetTextSize(self:GetText()) + Elib.Scale(14), Elib.Scale(30))
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()

    if not self:IsEnabled() then
        Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, self.DisabledCol, textAlign, TEXT_ALIGN_CENTER)
        return
    end

    local textColor = self.BackgroundCol

    if self:IsDown() or self:GetToggle() or self:IsHovered() then
        textColor = self.TextColor
    end

    Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, textColor, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.OutlineTextButton", PANEL, "Elib.OutlineButton")