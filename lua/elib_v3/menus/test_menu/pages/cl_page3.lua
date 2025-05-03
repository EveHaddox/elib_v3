// Script made by Eve Haddox
// discord evehaddox


/// IDK Page | Page 3
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Page 3", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 4)
    self.label:SetText(
[[Hmmm, I wonder what this page is about?]])
    --self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetFont("Elib.Test.Normal")

    self.toggleBox = self:Add("DPanel")
    self.toggleBox:Dock(TOP)
    self.toggleBox:DockMargin(0, 0, 0, 4)
    self.toggleBox:SetTall(Elib.Scale(20))

    self.toggleBox.Paint = function(pnl, w, h)
    end

    self.toggle = self.toggleBox:Add("Elib.Toggle")
    self.toggle:Dock(LEFT)
    --self.toggle:SetWide(Elib.Scale(20))

    self.labelledToggle = self:Add("Elib.LabelledToggle")
    self.labelledToggle:Dock(TOP)
    self.labelledToggle:DockMargin(0, 0, 0, 4)
    self.labelledToggle:SetText("Labelled Toggle")


end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page3", PANEL, "Panel")