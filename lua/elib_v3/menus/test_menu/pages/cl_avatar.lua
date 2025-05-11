// Script made by Eve Haddox
// discord evehaddox


/// Avatar | Page 7
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Avatar", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Avatar]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // avatar
    self.pnl = self:Add("DPanel")
    self.pnl:Dock(TOP)
    self.pnl:SetHeight(Elib.Scale(30))

    self.pnl.Paint = function(self, w, h)
    end

    self.avatar = self.pnl:Add("Elib.Avatar")
    self.avatar:Dock(LEFT)
    self.avatar:SetPlayer(LocalPlayer(), 64)
    self.avatar:SetMaskSize((Elib.Scale(14)))
    self.avatar:SetWide(Elib.Scale(30))

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page7", PANEL, "Panel")