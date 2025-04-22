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

        function self.SwichRealm(item)
            self.realm = self.realmNav.SelectedItem
            self:GenerateCategories()
        end
    end

    self.categoryNav = self:Add("Elib.Navbar")
    self.categoryNav:Dock(TOP)
    self.categoryNav:SetHeight(Elib.Scale(32))

    if LocalPlayer():IsSuperAdmin() then
        self.realmNav:AddItem("client", "client", self.SwichRealm, 1, Color(207, 144, 49))
        self.realmNav:AddItem("server", "server", self.SwichRealm, 2, Color(49, 149, 207))

        self.realmNav:SelectItem("client")
    end

    if self.categoryNav and self.categoryNav.Items then
        self.categoryNav:SelectItem(1)
    end
    
end

function PANEL:GenerateCategories()
    if self.categoryNav and self.categoryNav.Items then
        for k, v in ipairs(self.categoryNav.Items) do
            v:Remove()
        end
    end

    local function SwichCat(item)
        self.category = self.categoryNav.SelectedItem
        self:GeneratePage()
    end

    if Elib.Config.Addons[self.addon][self.realm] == nil then 
        self.categoryNav:AddItem(1, "No Data", function() end, 1)
        return
    end

    local i = 0
    for k, v in pairs(Elib.Config.Addons[self.addon][self.realm]) do
        i = i + 1
        self.categoryNav:AddItem(i, k, SwichCat, i)
    end

    self:GeneratePage()
end

function PANEL:GeneratePage()
    
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")