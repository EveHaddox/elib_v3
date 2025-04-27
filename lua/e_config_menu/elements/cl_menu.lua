// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()

    self.addon = "Elib"
    self.realm = "client"
    self.category = 1

    self.panels = {}

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

    self.scroll = self:Add("Elib.ScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(6, 6, 6, 6)

    if LocalPlayer():IsSuperAdmin() then
        self.realmNav:AddItem("client", "client", self.SwichRealm, 1, Color(207, 144, 49))
        self.realmNav:AddItem("server", "server", self.SwichRealm, 2, Color(49, 149, 207))

        self.realmNav:SelectItem("client")
    end

    if self.categoryNav and self.categoryNav.Items then
        self.categoryNav:SelectItem(1)
    end

    self.TaskBar = self:Add("DPanel")
    self.TaskBar:Dock(BOTTOM)
    self.TaskBar:SetHeight(Elib.Scale(32))
    self.TaskBar:DockMargin(6, 0, 6, 6)
    self.TaskBar.Paint = function(self, w, h)
    end

    self.Reset = self.TaskBar:Add("DButton")
    self.Reset:SetText("")
    self.Reset.Color = Elib.Colors.PrimaryText

    self.Reset.DoClick = function(pnl)
        for k, v in pairs(self.panels) do
            if v.RestoreDefault then
                v:RestoreDefault()
            end
        end
    end

    self.Reset.Paint = function(pnl, w, h)

        if pnl:IsDown() then
            self.Reset.Color = Elib.Colors.Negative
        elseif pnl:IsHovered() then
            self.Reset.Color = Elib.OffsetColor(Elib.Colors.Negative, -20)
        else
            self.Reset.Color = Elib.Colors.PrimaryText
        end

        Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/5fa7c9c8-d9d5-4c77-aed6-975b4fb039b5.png", self.Reset.Color)
    end

    self.Save = self.TaskBar:Add("DButton")
    self.Save:SetText("")
    self.Save.Color = Elib.Colors.PrimaryText

    self.Save.DoClick = function(pnl)
        for k, v in pairs(self.panels) do
            if v.Save then
                if v.onComplete then
                    v.onComplete(item)
                end

                if v.resetMenu then
                    self:GeneratePage()
                end

                v:Save()
            end
        end
    end

    self.Save.Paint = function(pnl, w, h)

        if pnl:IsDown() then
            self.Save.Color = Elib.Colors.Positive
        elseif pnl:IsHovered() then
            self.Save.Color = Elib.OffsetColor(Elib.Colors.Positive, -20)
        else
            self.Save.Color = Elib.Colors.PrimaryText
        end

        Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/2b2f5ea0-3cb3-4207-82db-bb8484da738a.png", self.Save.Color)
    end

    self.TaskBar.PerformLayout = function(pnl, w, h)
        local spacing = 8
        local btnSize = h
        local totalWidth = btnSize * 2 + spacing
        local startX = (w - totalWidth) / 2

        self.Reset:SetPos(startX, 0)
        self.Reset:SetSize(btnSize, btnSize)

        self.Save:SetPos(startX + btnSize + spacing, 0)
        self.Save:SetSize(btnSize, btnSize)
    end
    
end

function PANEL:GenerateCategories()
    if self.categoryNav and self.categoryNav.Items then
        for k, v in ipairs(self.categoryNav.Items) do
            v:Remove()
        end
    end

    local function SwichCat(item)
        self.category = string.lower(self.categoryNav.Items[self.categoryNav.SelectedItem]:GetName())
        self:GeneratePage()
    end

    if Elib.Config.Addons[self.addon][self.realm] == nil then 
        self.categoryNav:AddItem(1, "No Data", function() end, 1)
        self.scroll:Clear()
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

    self.scroll:Clear()

    if Elib.Config.Addons[self.addon][self.realm][self.category] == nil or table.IsEmpty(Elib.Config.Addons[self.addon][self.realm][self.category]) then return end

    for k, v in pairs(Elib.Config.Addons[self.addon][self.realm][self.category]) do
        
        self.panels[k] = self.scroll:Add("Elib.Config.Panels." .. v.type)
        local item = self.panels[k]

        item:SetSize(self.scroll:GetWide(), Elib.Scale(35))
        item:Dock(TOP)
        item:DockMargin(0, 0, 0, 4)
        item:SetText(v.name)
        item:SetValue(v.value)

    end
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")