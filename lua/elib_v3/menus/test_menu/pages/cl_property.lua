// Script made by Eve Haddox
// discord evehaddox


/// Property Sheet | Page 10
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Property Sheet", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Property Sheet]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Panel
    self.propertySheet = self:Add("Elib.PropertySheet")
    self.propertySheet:Dock(FILL)
    
    local btn = vgui.Create("Elib.TextButton")
    btn:SetText("Test Button")

    local pnl = vgui.Create("DPanel")
    pnl.Paint = function(self, w, h)
        surface.SetDrawColor(Elib.Colors.Background)
        surface.DrawRect(0, 0, w, h)

        Elib.DrawSimpleText("Test Panel", "Elib.Test.Title", w / 2, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.propertySheet:AddSheet("Test1", btn, "icon16/wrench.png", false, false, "Tooltip 1")
    self.propertySheet:AddSheet("Test2", pnl, "icon16/wrench.png", false, false, "Tooltip 2")

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page10", PANEL, "Panel")