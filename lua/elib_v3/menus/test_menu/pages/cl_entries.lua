// Script made by Eve Haddox
// discord evehaddox


/// Text Entries | Page 4
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Text Entries", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Text Entries allows users to input text and numbers making them very useful

Here you will hava a normal and a validated one, you can put requirements on the validated to inshure the user inputs the right thing.]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Text Entries
    self.textBox = self:Add("Elib.TextEntry")
    self.textBox:Dock(TOP)
    self.textBox:DockMargin(0, 8, 0, 4)
    self.textBox:SetTall(Elib.Scale(30))
    self.textBox:SetPlaceholderText("Normal Text Entry")
    --self.textBox:SetText("Normal Text Entry")

    self.numberBox = self:Add("Elib.TextEntry")
    self.numberBox:Dock(TOP)
    self.numberBox:DockMargin(0, 8, 0, 4)
    self.numberBox:SetTall(Elib.Scale(30))
    self.numberBox:SetPlaceholderText("Numbers Only")
    self.numberBox:SetNumeric(true)

    self.validatedBox = self:Add("Elib.ValidatedTextEntry")
    self.validatedBox:Dock(TOP)
    self.validatedBox:DockMargin(0, 8, 0, 4)
    self.validatedBox:SetTall(Elib.Scale(30))
    self.validatedBox:SetPlaceholderText("Validated Text Entry (below 5 chars)")

    function self.validatedBox:IsTextValid(text)
        if #text < 5 then
            return true
        end

        return false, "This is invalid text lol"
    end
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page4", PANEL, "Panel")