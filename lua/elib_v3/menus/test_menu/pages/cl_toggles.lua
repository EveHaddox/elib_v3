// Script made by Eve Haddox
// discord evehaddox


/// Toggles | Page 3
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Toggles", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Toggles and checkboxes also with labels!]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Toggles
    self.toggleBox = self:Add("DPanel")
    self.toggleBox:Dock(TOP)
    self.toggleBox:DockMargin(0, 0, 0, 4)
    self.toggleBox:SetTall(Elib.Scale(20))

    self.toggleBox.Paint = function(pnl, w, h)
    end

    self.toggle = self.toggleBox:Add("Elib.Toggle")
    self.toggle:Dock(LEFT)

    self.labelledToggle = self:Add("Elib.LabelledToggle")
    self.labelledToggle:Dock(TOP)
    self.labelledToggle:DockMargin(0, 0, 0, 4)
    self.labelledToggle:SetText("Labelled Toggle")
    self.labelledToggle:SetToggle(true)

    // Checkboxes
    self.checkBox = self:Add("DPanel")
    self.checkBox:Dock(TOP)
    self.checkBox:DockMargin(0, 0, 0, 4)
    self.checkBox:SetTall(Elib.Scale(20))

    self.checkBox.Paint = function(pnl, w, h)
    end

    self.check = self.checkBox:Add("Elib.Checkbox")
    self.check:Dock(LEFT)

    self.labelledcheck = self:Add("Elib.LabelledCheckbox")
    self.labelledcheck:Dock(TOP)
    self.labelledcheck:DockMargin(0, 0, 0, 4)
    self.labelledcheck:SetText("Labelled Checkbox")
    self.labelledcheck:SetToggle(true)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page3", PANEL, "Panel")