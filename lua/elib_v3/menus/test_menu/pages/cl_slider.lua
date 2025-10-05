// Script made by Eve Haddox
// discord evehaddox


/// Slider | Page 15
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Slider", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Slider]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Content
    self.Container = self:Add("DPanel")
    self.Container:Dock(TOP)
    self.Container:SetHeight(Elib.Scale(30))
    self.Container:DockMargin(0, 0, 0, 0)
    self.Container.Paint = function(pnl, w, h)
    end

    self.ValueEntry = self.Container:Add("Elib.TextEntry")
    self.ValueEntry:Dock(RIGHT)
    self.ValueEntry:SetNumeric(true)
    self.ValueEntry:SetWidth(Elib.Scale(50))

    self.ValueEntry.lastvalue = 0
    self.ValueEntry.OnValueChange = function(pnl, value)
        local min, max = 1, 5
        value = math.Clamp(tonumber(value) or 0, min, max)

        if value == self.ValueEntry.lastvalue then return end

        self.ValueEntry.lastvalue = value
        self.ValueEntry:SetValue(value)

        local size = math.Round(min + (max - min) * self.Slider.Fraction)
        if size ~= value then
            self.Slider.Fraction = (value - min) / (max - min)
            self.Slider:InvalidateLayout()
        end
    end

    self.Slider = self.Container:Add("Elib.Slider")
    self.Slider:Dock(FILL)
    self.Slider:DockMargin(12, Elib.Scale(9), 16, Elib.Scale(9))
    self.Slider.Fraction = 1

    self.Slider.OnValueChanged = function(slider, frac)
        local min, max = 1, 5
        local size = math.Round(min + (max - min) * frac)
        self.ValueEntry:SetValue(size)
    end

    do
        local min, max = 5, 10
        local size = math.Round(min + (max - min) * self.Slider.Fraction)
        self.ValueEntry:SetValue(size)
    end

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page15", PANEL, "Panel")