// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()

    self:SetHeight(Elib.Scale(170))
    self:SetText("")

    self.OriginalValue = nil
    self.Value = {}
    self.Saved = true

    self.Header = self:Add("DPanel")
    self.Header:Dock(TOP)
    self.Header:DockMargin(0, 0, 0, 4)
    self.Header:SetHeight(Elib.Scale(35))

    self.Header.Paint = function(pnl, w, h)
        Elib.DrawRoundedBoxEx(6, 0, 0, w, h, Elib.Colors.Header, true, true, false, false)
        Elib.DrawSimpleText(self:GetText(), "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.Header.PerformLayout = function(pnl, w, h)
        self.Reset:SetWide(h - 8)
    end

    // Adding Values
    self.AddButton = self.Header:Add("Elib.TextButton")
    self.AddButton:Dock(RIGHT)
    self.AddButton:DockMargin(0, 4, 4, 4)
    self.AddButton:SetText("Add")
    self.AddButton:SetWide(Elib.Scale(60))

    self.AddButton.DoClick = function()
        local val = self.valueEntry:GetValue()
        if val and val ~= "" then
            table.insert(self.Value, val)
            self.valueEntry:SetValue("")
            self.Saved = false
            self:Populate()
        end
    end

    self.valueEntry = self.Header:Add("Elib.TextEntry")
    self.valueEntry:Dock(RIGHT)
    self.valueEntry:DockMargin(0, 4, 4, 4)
    self.valueEntry:SetWide(Elib.Scale(220))

    self.Reset = self.Header:Add("DButton")
    self.Reset:Dock(RIGHT)
    self.Reset:DockMargin(0, 4, 4, 4)
    self.Reset:SetText("")
    self.Reset.Color = Elib.Colors.PrimaryText

    self.Reset.DoClick = function(pnl)
        self:RestoreDefault()
    end

    self.Reset.Paint = function(pnl, w, h)
        if self.Saved then return end

        if pnl:IsDown() then
            pnl.Color = Elib.Colors.Negative
        elseif pnl:IsHovered() then
            pnl.Color = Elib.OffsetColor(Elib.Colors.Negative, -20)
        else
            pnl.Color = Elib.Colors.PrimaryText
        end

        Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/5fa7c9c8-d9d5-4c77-aed6-975b4fb039b5.png", self.Reset.Color)
    end

    // Content
    self.Content = self:Add("Elib.ScrollPanel")
    self.Content:Dock(FILL)
    self.Content:DockMargin(4, 0, 4, 4)

    self.contentPanels = {}

    function self:Populate()
        if !table.IsEmpty(self.contentPanels) then
            for _, pnl in ipairs(self.contentPanels) do
                pnl:Remove()
            end
        end

        self.contentPanels = {}
        if not self.Value or table.IsEmpty(self.Value) then return end

        for k, v in ipairs(self.Value) do
            self.contentPanels[k] = self.Content:Add("DPanel")
            local pnl = self.contentPanels[k]

            pnl:Dock(TOP)
            pnl:DockMargin(0, 0, 4, 4)
            pnl:SetHeight(Elib.Scale(30))

            pnl.Paint = function(pnl, w, h)
                Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Header, -4))
                Elib.DrawSimpleText(v, "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            pnl.RemoveButton = pnl:Add("Elib.TextButton")
            pnl.RemoveButton:Dock(RIGHT)
            pnl.RemoveButton:DockMargin(0, 4, 4, 4)
            pnl.RemoveButton:SetText("X")
            pnl.RemoveButton:SetWide(Elib.Scale(30))

            pnl.RemoveButton.DoClick = function()
                table.remove(self.Value, k)
                self.Saved = false
                self:Populate()
            end
        end

        timer.Simple(0, function()
            self.Content:InvalidateLayout(true)
        end)
    end
    
end

function PANEL:SetValue(value)
    if not value or type(value) ~= "table" or table.IsEmpty(value) then return end
    self.OriginalValue = table.Copy(value)
    self.Value = table.Copy(value)

    self:Populate()
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:GetSaved()
    return self.Saved
end

function PANEL:SetPath(addon, realm, category, k)
    self.Path = { addon = addon, realm = realm, category = category, id = k }
end

function PANEL:RestoreDefault()
    if self.Saved then return end

    self.Saved = true
    self.Value = table.Copy(self.OriginalValue)
    self:Populate()
end

function PANEL:Save()
    if self.Saved then return end
    local value = self:GetValue()

    Elib.Config.Save(self.Path.addon, self.Path.realm, self.Path.category, self.Path.id, value)

    Elib.Config.Addons[self.Path.addon][self.Path.realm][self.Path.category][self.Path.id].value = value
    self.Saved = true
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.Colors.Background)
end

vgui.Register("Elib.Config.Panels.List", PANEL, "DPanel")