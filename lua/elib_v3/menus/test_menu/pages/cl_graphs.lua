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
        Elib.DrawSimpleText("Graphs", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Here are all of my graph elements]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Graphs
    self.scroll = self:Add("Elib.ScrollPanel")
    self.scroll:Dock(FILL)

    local LineGraph = self.scroll:Add("Elib.LineGraph")
    LineGraph:Dock(TOP)
    LineGraph:SetHeight(Elib.Scale(300))

    LineGraph:SetUnits(" d", " $")

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
    LineGraph:SetData(economy)

    local pie = vgui.Create("Elib.PieChart", self.scroll)
    pie:Dock(TOP)
    pie:SetHeight(400)            -- keep it square
    pie:SetDonut(0.35)          -- 0 = pie ; 0-0.9 = donut

    pie:AddSlice("Copper", 40, Color(184,115,51))
    pie:AddSlice("Tin",    25, Color(200,200,180))
    pie:AddSlice("Iron",   60)                    -- default HSV colour
    pie:AddSlice("Gold",   15, Color(255,215,  0))

    local bar = vgui.Create("Elib.BarChart", self.scroll)
    bar:Dock(TOP)
    bar:SetHeight(Elib.Scale(300))
    bar:SetBarSpacing(0.4)
    bar:SetTicksY(4)
    bar:SetUnitY(" kg")

    bar:AddBar("Q1", 120)
    bar:AddBar("Q2", 200, Color(  0,200,255))
    bar:AddBar("Q3",  90)
    bar:AddBar("Q4", 160)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page13", PANEL, "DPanel")