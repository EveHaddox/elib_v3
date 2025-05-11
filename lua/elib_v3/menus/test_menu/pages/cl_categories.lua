// Script made by Eve Haddox
// discord evehaddox


/// Categories | Page 12
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Categories", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Categories]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Category
    self.category = self:Add("Elib.Category")
    self.category:Dock(TOP)
    self.category:DockMargin(0, 0, 0, 8)

    self.button = self.category:Add("Elib.TextButton")
    self.button:Dock(TOP)
    self.button:SetHeight(Elib.Scale(30))
    self.button:DockMargin(4, 2, 4, 4)
    self.button:SetText("Test")

    self.button1 = self.category:Add("Elib.TextButton")
    self.button1:Dock(TOP)
    self.button1:SetHeight(Elib.Scale(30))
    self.button1:DockMargin(4, 0, 4, 2)
    self.button1:SetText("Test2")

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page12", PANEL, "Panel")