// Script made by Eve Haddox
// discord evehaddox


/// Color Picker | Page 6
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Color Picker", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Color Picker]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Color Picker
    self.colorPicker = self:Add("Elib.ColorPicker")
    self.colorPicker:Dock(TOP)
    self.colorPicker:DockMargin(0, 0, 0, 8)
    self.colorPicker:SetSize(Elib.Scale(200), Elib.Scale(200))
    self.colorPicker:SetColor(Elib.Colors.PrimaryText)

    self.colorPicker.OnChange = function(pnl, color)
        self.label:SetTextColor(color)
    end

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page6", PANEL, "Panel")