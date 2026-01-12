// Script made by Eve Haddox
// discord evehaddox


/// Horizontal Scroll Panel | Page 16
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Horizontal Scroll Panel", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[A horizontally scrolling panel for displaying content that extends beyond the visible width.]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Horizontal Scroll
    self.scroll = self:Add("Elib.HorizontalScrollPanel")
    self.scroll:Dock(TOP)
    self.scroll:DockMargin(0, 0, 0, 8)
    self.scroll:SetTall(Elib.Scale(100))
    
    local bgCl = Elib.OffsetColor(Elib.Colors.Background, 5)
    local canvas = self.scroll:GetCanvas()

    for var = 1, 20 do
        local pnl = vgui.Create("DPanel", canvas)
        pnl:Dock(LEFT)
        pnl:DockMargin(var > 1 and 4 or 0, 4, 0, 4)
        pnl:SetWide(Elib.Scale(150))

        pnl.Paint = function(self, w, h)
            Elib.DrawRoundedBox(6, 0, 0, w, h, bgCl)
            Elib.DrawSimpleText("Panel " .. var, "Elib.Test.Normal", w / 2, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    // Second example with images/cards
    self.label2 = self:Add("Elib.Label")
    self.label2:Dock(TOP)
    self.label2:DockMargin(0, 8, 0, 8)
    self.label2:SetText([[Example with larger cards:]])
    self.label2:SetAutoWrap(true)
    self.label2:SetAutoHeight(true)
    self.label2:SetAutoWidth(true)
    self.label2:SetFont("Elib.Test.Normal")

    self.scroll2 = self:Add("Elib.HorizontalScrollPanel")
    self.scroll2:Dock(TOP)
    self.scroll2:DockMargin(0, 0, 0, 8)
    self.scroll2:SetTall(Elib.Scale(200))

    local canvas2 = self.scroll2:GetCanvas()
    local colors = {
        Color(231, 76, 60),
        Color(46, 204, 113),
        Color(52, 152, 219),
        Color(155, 89, 182),
        Color(241, 196, 15),
        Color(230, 126, 34),
        Color(26, 188, 156),
        Color(236, 240, 241)
    }

    for var = 1, 12 do
        local pnl = vgui.Create("DPanel", canvas2)
        pnl:Dock(LEFT)
        pnl:DockMargin(0, 0, 4, 4)
        pnl:SetWide(Elib.Scale(180))

        local cardColor = colors[((var - 1) % #colors) + 1]

        pnl.Paint = function(self, w, h)
            Elib.DrawRoundedBox(8, 0, 0, w, h, bgCl)
            Elib.DrawRoundedBox(6, 4, 4, w - 8, h * 0.6, cardColor)
            Elib.DrawSimpleText("Card " .. var, "Elib.Test.Normal", w / 2, h * 0.8, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    // Scrollbar on top example
    self.label3 = self:Add("Elib.Label")
    self.label3:Dock(TOP)
    self.label3:DockMargin(0, 8, 0, 8)
    self.label3:SetText([[Scrollbar on top:]])
    self.label3:SetAutoWrap(true)
    self.label3:SetAutoHeight(true)
    self.label3:SetAutoWidth(true)
    self.label3:SetFont("Elib.Test.Normal")

    self.scroll3 = self:Add("Elib.HorizontalScrollPanel")
    self.scroll3:Dock(TOP)
    self.scroll3:DockMargin(0, 0, 0, 8)
    self.scroll3:SetTall(Elib.Scale(80))
    self.scroll3:SetScrollbarTopSide(true)

    local canvas3 = self.scroll3:GetCanvas()

    for var = 1, 15 do
        local pnl = vgui.Create("DPanel", canvas3)
        pnl:Dock(LEFT)
        pnl:DockMargin(0, 4, 4, 4)
        pnl:SetWide(Elib.Scale(100))

        pnl.Paint = function(self, w, h)
            Elib.DrawRoundedBox(6, 0, 0, w, h, bgCl)
            Elib.DrawSimpleText("Item " .. var, "Elib.Test.Normal", w / 2, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page16", PANEL, "Panel")