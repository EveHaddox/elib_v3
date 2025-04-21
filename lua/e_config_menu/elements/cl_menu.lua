// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()

    self.addon = "Elib"
    self.realm = "client"
    self.category = 1

    if LocalPlayer():IsSuperAdmin() then
        self.realmNav = self:Add("Elib.Navbar")
        self.realmNav:Dock(TOP)
        self.realmNav:SetHeight(Elib.Scale(32))
        self.realmNav:SetDrawShadow(true)

        local function SwichRealm(item)
            self.realm = self.realmNav.SelectedItem
            print("Switched realm to: " .. self.realm)
        end

        self.realmNav:AddItem("client", "client", SwichRealm, 1, Color(207, 144, 49))
        self.realmNav:AddItem("server", "server", SwichRealm, 2, Color(49, 149, 207))

        self.realmNav:SelectItem("client")
    end

    self.categoryNav = self:Add("Elib.Navbar")
    self.categoryNav:Dock(TOP)
    self.categoryNav:SetHeight(Elib.Scale(32))

    local function SwichCat(item)
        self.category = self.categoryNav.SelectedItem
    end

    local i = 0
    for k, v in pairs(Elib.Config.Addons[self.addon][self.realm]) do
        i = i + 1
        self.categoryNav:AddItem(i, k, SwichCat, i)
    end

    self.categoryNav:SelectItem(1)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")