// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()

    self:SetHeight(Elib.Scale(35))
    self:SetText("")

    self.OriginalValue = nil
    self.table = nil
    self.Saved = true

    self.ComboBox = self:Add("Elib.ComboBox")
    self.ComboBox:Dock(RIGHT)
    self.ComboBox:DockMargin(0, 4, 4, 4)
    self.ComboBox:SetWide(Elib.Scale(130))

    self.ComboBox.OnSelect = function(i, value, data)
        if self.OriginalValue == nil then return end
        self.Saved = data == self.OriginalValue
    end

    self.Reset = self:Add("DButton")
    self.Reset:Dock(RIGHT)
    self.Reset:DockMargin(0, 4, 4, 4)
    self.Reset:SetText("")
    self.Reset.Color = Elib.Colors.PrimaryText

    self.Reset.DoClick = function(pnl)
        if self.Saved then return end
        self:RestoreDefault()
        self.Saved = true
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
    
end

function PANEL:SetValue(value, table)
    self.ComboBox:Clear()
    for k, v in ipairs(table) do
        local value1, icon = istable(v) and v.value or v, istable(v) and v.icon or nil // icons aren't actually there, as the menu doesn't support it, but I'll add them later so this stays
        self.ComboBox:AddChoice(value1, k, value1 == value, icon)
    end
    
    self.table = table
    self.OriginalValue = value
end

function PANEL:GetValue()
    return self.ComboBox:GetSelected()
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
    self:SetValue(self.OriginalValue, self.table)
end

function PANEL:Save()
    if self.Saved then return end
    local value = self:GetValue()

    Elib.Config.Save(self.Path.addon, self.Path.realm, self.Path.category, self.Path.id, value)

    Elib.Config.Addons[self.Path.addon][self.Path.realm][self.Path.category][self.Path.id].value = value
    self.Saved = true
    self.OriginalValue = value
end

function PANEL:PerformLayout(w, h)
    self.Reset:SetWide(h - 8)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Background, 6))
    Elib.DrawSimpleText(self.Text, "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.Config.Panels.Dropdown", PANEL, "DPanel")