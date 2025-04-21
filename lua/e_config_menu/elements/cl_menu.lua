// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()

    self.realmNav = self:Add("Elib.Navbar")
    self.realmNav:Dock(TOP)
    self.realmNav:SetHeight(Elib.Scale(30))

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")