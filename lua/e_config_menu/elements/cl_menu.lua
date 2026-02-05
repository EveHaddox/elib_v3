// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()

    self.addon = "None"
    self.realm = "client"
    self.category = nil

    self.panels = {}
    self.Cleanup = {}

    self.func = function() end

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

    self.ScrollLayout = self:Add("DPanel")
    self.ScrollLayout:Dock(FILL)
    self.ScrollLayout:DockMargin(6, 6, 6, 6)
    self.ScrollLayout.Paint = function(pnl, w, h) end

    self.scroll = self.ScrollLayout:Add("Elib.ScrollPanel")
    self.scroll:Dock(FILL)

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
        local reset = false
        for k, v in pairs(self.panels) do
            if v.Save then
                if v.onComplete then
                    v.onComplete(v:GetValue())
                end

                if v.resetMenu then
                    reset = true
                end

                v:Save()
            end
        end
        if reset then
            self:GeneratePage()
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

    self.Back = self.TaskBar:Add("DButton")
    self.Back:SetText("")
    self.Back.Color = Elib.Colors.PrimaryText

    self.Back.DoClick = function(pnl)
        self.func()
    end

    self.Back.Paint = function(pnl, w, h)
        if pnl:IsDown() then
            self.Back.Color = Elib.Colors.Primary
        elseif pnl:IsHovered() then
            self.Back.Color = Elib.OffsetColor(Elib.Colors.Primary, -20)
        else
            self.Back.Color = Elib.Colors.PrimaryText
        end

        Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/ab014fa0-a7fe-4ba2-b822-3254ce3108fc.png", self.Back.Color)
    end

    self.TaskBar.PerformLayout = function(pnl, w, h)
        local spacing = 8
        local btnSize = h
        local totalWidth = btnSize * 2 + spacing
        local startX = (w - totalWidth) / 2

        self.Reset:SetPos(startX, 0)
        self.Save:SetPos(startX + btnSize + spacing, 0)

        self.Reset:SetSize(btnSize, btnSize)
        self.Save:SetSize(btnSize, btnSize)
        self.Back:SetSize(btnSize, btnSize)
    end
end

function PANEL:SetAddon(addon)
    self.addon = addon
    self:GenerateCategories()
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

    if Elib.Config.Addons[self.addon] == nil or Elib.Config.Addons[self.addon][self.realm] == nil then
        self.categoryNav:AddItem(1, "No Data", function() end, 1)
        self.categoryNav:SelectItem(1)
        self.scroll:Clear()
        return
    end

    local sortedCategories = {}
    for k, v in pairs(Elib.Config.Addons[self.addon][self.realm]) do
        table.insert(sortedCategories, { name = k, order = v.order or 999 })
    end

    table.sort(sortedCategories, function(a, b) return a.order < b.order end)

    for i, cat in ipairs(sortedCategories) do
        self.categoryNav:AddItem(i, cat.name, SwichCat, i)
    end

    if #self.categoryNav.Items > 0 and self.categoryNav.Items[self.categoryNav.SelectedItem] then
        self.category = string.lower(self.categoryNav.Items[self.categoryNav.SelectedItem]:GetName())
        self:GeneratePage()
    end

    self.categoryNav:SelectItem(1)
end

function PANEL:GeneratePage()
    self.scroll:Clear()
    self.panels = {}

    if !table.IsEmpty(self.Cleanup) then
        for k, v in ipairs(self.Cleanup) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end

    if Elib.Config.Addons[self.addon][self.realm][self.category] == nil or table.IsEmpty(Elib.Config.Addons[self.addon][self.realm][self.category]) then return end

    local sortedPanels = {}
    for k, v in pairs(Elib.Config.Addons[self.addon][self.realm][self.category]) do
        if type(v) == "table" then
            v.key = k
            table.insert(sortedPanels, v)
        end
    end

    table.sort(sortedPanels, function(a, b) return (a.order or 999) < (b.order or 999) end)

    for _, v in ipairs(sortedPanels) do
        local k = v.key
        
        local item
        if v.fullscreen then
            self.panels[k] = self:Add("Elib.Config.Panels." .. v.type)
            item = self.panels[k]
            item:Dock(FILL)

            table.insert(self.Cleanup, self.panels[k])
        else
            self.panels[k] = self.scroll:Add("Elib.Config.Panels." .. v.type)
            item = self.panels[k]

            item:Dock(TOP)
            item:DockMargin(0, 0, 0, 4)
        end

        item:SetText(v.name)
        item:SetValue(v.value, v.table)
        item:SetPath(self.addon, self.realm, self.category, k)

        item.onComplete = v.onComplete
        item.resetMenu = v.resetMenu or false
    end

    self:InvalidateLayout(true)

    timer.Simple(0, function()
        if not IsValid(self) then return end
        self:InvalidateLayout(true)
    end)
end

function PANEL:SetFunc(func)
    self.func = func
end

function PANEL:PerformLayout(w, h)
    self.scroll:InvalidateLayout(true)

    local spacing = 4
    local barSpacing = self.scroll.VBar.Enabled and 4 or 0

    for _, v in pairs(self.panels) do
        if IsValid(v) then
            v:DockMargin(0, 0, barSpacing, spacing)
        end
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Menu", PANEL, "DPanel")