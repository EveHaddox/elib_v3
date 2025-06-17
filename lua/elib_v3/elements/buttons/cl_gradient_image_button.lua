// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "ImageSpacing", "ImageSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Url", "Url", FORCE_STRING)

Elib.RegisterFont("UI.TextButton", "Space Grotesk SemiBold", 20)

function PANEL:Init()
    self:SetText("Button")
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetFont("UI.TextButton")

    self:SetSize(Elib.Scale(100), Elib.Scale(30))

    self:SetImageSpacing(Elib.Scale(6))
    self:SetUrl(Elib.ProgressURL)

    self.ImageCol = Elib.CopyColor(color_white)
end

function PANEL:SizeToText()
    Elib.SetFont(self:GetFont())
    self:SetSize(Elib.GetTextSize(self:GetText()) + Elib.Scale(14), Elib.Scale(30))
end

function PANEL:PaintExtra(w, h)

    local textAlign = self:GetTextAlign()

    // Image
    local spacing = self:GetImageSpacing()
    local url = self:GetUrl()
    local imgSize = h - spacing * 2

    Elib.DrawImage(textAlign == TEXT_ALIGN_RIGHT and w - imgSize - spacing or spacing, spacing, imgSize, imgSize, url, self:IsEnabled() and self.ImageCol or self.DisabledCol)

    // Text
    local textX = (textAlign == TEXT_ALIGN_CENTER and (w + imgSize + spacing) / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - imgSize - spacing * 2) or imgSize + spacing * 2

    if not self:IsEnabled() then
        Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)
        return
    end

    Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.SecondaryText, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.GradientImageButton", PANEL, "Elib.GradientButton")