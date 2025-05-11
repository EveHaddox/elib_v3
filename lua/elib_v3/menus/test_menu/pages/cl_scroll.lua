// Script made by Eve Haddox
// discord evehaddox


/// Scroll Panel | Page 11
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Scroll Panel", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Scroll Panel]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // Scroll
    self.scroll = self:Add("Elib.ScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockPadding(0, 0, 0, 4)
    
    local bgCl = Elib.OffsetColor(Elib.Colors.Background, 5)

    for var = 1, 28 do
        local pnl = self.scroll:Add("DPanel")
        pnl:Dock(TOP)
        pnl:DockMargin(4, 4, 4, 0)
        pnl:SetTall(Elib.Scale(30))

        pnl.Paint = function(self, w, h)
            Elib.DrawRoundedBox(6, 0, 0, w, h, bgCl)
            Elib.DrawSimpleText("Test Panel " .. var, "Elib.Test.Normal", w / 2, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page11", PANEL, "Panel")