// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()

    self.realm = "client"

    if LocalPlayer():IsSuperAdmin() then
        self.realmNav = self:Add("Elib.Navbar")
        self.realmNav:Dock(TOP)
        self.realmNav:SetHeight(Elib.Scale(32))

        local function SwichRealm(id)
            self.realm = id
        end

        self.realmNav:AddItem("client", "client", SwichRealm, 1, Color(207, 144, 49))
        self.realmNav:AddItem("server", "server", SwichRealm, 2, Color(49, 149, 207))

        self.realmNav:SelectItem("client")
    end
    

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")