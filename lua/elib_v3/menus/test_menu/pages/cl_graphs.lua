// Script made by Eve Haddox
// discord evehaddox


/// Menu | Page 13
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Menu", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Menu]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // menu
    local graph = self:Add("Elib.Graph")
    graph:Dock(FILL)

    graph:SetUnits(" d", " $")

    local economy = {
        {x =  0, y = 1000000},
        {x =  1, y = 1250000},
        {x =  2, y = 1284000},
        {x =  3, y = 1312000},
        {x =  4, y = 1290000},
        {x =  5, y = 1355000},
        {x =  6, y = 1423000},
        {x =  7, y = 1398000},
    }
    graph:SetData(economy)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page13", PANEL, "DPanel")