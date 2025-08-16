// Script made by Eve Haddox
// discord evehaddox


/// Dropdowns | Page 14
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Dropdowns", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Dropdowns - first one is normal, but the second one is a multi select one.]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    self.DropDown = self:Add("Elib.ComboBox")
    self.DropDown:Dock(TOP)
    self.DropDown:DockMargin(0, 0, 0, 8)
    self.DropDown:SetSizeToText(false)

    self.DropDown:AddChoice("None", true, true)
    self.DropDown:AddChoice("Test", true, false)
    self.DropDown:AddChoice("Option 3", true, false)

    self.MultiDropDown = self:Add("Elib.MultiComboBox")
    self.MultiDropDown:Dock(TOP)
    self.MultiDropDown:SetSizeToText(false)

    self.MultiDropDown:AddChoice("None", true, true)
    self.MultiDropDown:AddChoice("Test", true, false)
    self.MultiDropDown:AddChoice("Option 3", true, false)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page14", PANEL, "Panel")