// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()

    local height = Elib.Scale(100)
    self:SetHeight(height)
    self:SetText("")

    self.OriginalValue = nil
    self.Saved = true

    self.ColorPanel = self:Add("DPanel")
    self.ColorPanel:Dock(RIGHT)
    local spaceNum = Elib.Scale(16)
    self.ColorPanel:DockMargin(spaceNum, spaceNum, spaceNum, spaceNum)
    self.ColorPanel:SetWide(height - spaceNum * 2)
    self.ColorPanel.Paint = function(pnl, w, h)
        if self.OriginalValue == nil then return end
        local color = self.colorPicker.Color or color_white
        Elib.DrawRoundedBox(6, 0, 0, w, h, color)
    end

    self.colorPicker = self:Add("Elib.ColorPicker")
    self.colorPicker:Dock(RIGHT)
    self.colorPicker:DockMargin(0, 4, 4, 4)
    self.colorPicker:SetWide(height)

    self.RGBPanel = self:Add("DPanel")
    self.RGBPanel:Dock(RIGHT)
    self.RGBPanel:SetWide(Elib.Scale(55))
    self.RGBPanel:DockMargin(8, 4, 8, 4)
    self.RGBPanel.Paint = function() end

    local function createEntry(placeholder, y, h)
        local entry = self.RGBPanel:Add("Elib.TextEntry")
        entry:SetPos(0, y)
        entry:SetSize(self.RGBPanel:GetWide(), h)
        entry:SetPlaceholderText(placeholder)
        entry:SetNumeric(true)

        function entry.updateColor()
            local r_val = tonumber(self.REntry:GetValue())
            local g_val = tonumber(self.GEntry:GetValue())
            local b_val = tonumber(self.BEntry:GetValue())

            local r = math.Clamp(r_val or 0, 0, 255)
            local g = math.Clamp(g_val or 0, 0, 255)
            local b = math.Clamp(b_val or 0, 0, 255)
            local a = self.colorPicker.Color.a

            local newColor = Color(r, g, b, a)
            self.colorPicker:SetColor(newColor)
        end

        entry.OnValueChange = entry.updateColor
        entry.OnLoseFocus = entry.updateColor
        return entry
    end

    local entryHeight = (self.RGBPanel:GetTall() - Elib.Scale(4)) / 3
    self.REntry = createEntry("R", 0, entryHeight)
    self.GEntry = createEntry("G", entryHeight + Elib.Scale(2), entryHeight)
    self.BEntry = createEntry("B", (entryHeight + Elib.Scale(2)) * 2, entryHeight)

    self.colorPicker.OnChange = function(pnl, value)
        if self.OriginalValue == nil then return end
        self.Saved = value == self.OriginalValue

        self.REntry:SetText(value.r)
        self.GEntry:SetText(value.g)
        self.BEntry:SetText(value.b)
    end

    self.resetPos = self:Add("DPanel")
    self.resetPos:Dock(RIGHT)
    self.resetPos:DockMargin(0, 4, 0, 4)
    self.resetPos:SetWide(Elib.Scale(30))
    self.resetPos.Paint = function(pnl, w, h)
    end

    self.Reset = self.resetPos:Add("DButton")
    self.Reset:Dock(TOP)
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
    
end

function PANEL:SetValue(value)
    if isstring(value) then
        local tbl = util.JSONToTable(value)
        value = tbl or {}
    end

    self.OriginalValue = table.Copy(value)
    self.colorPicker:SetColor(value)
    
    self.REntry:SetValue(math.floor(value.r))
    self.GEntry:SetValue(math.floor(value.g))
    self.BEntry:SetValue(math.floor(value.b))
end

function PANEL:GetValue()
    return self.colorPicker.Color
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
    self.colorPicker:SetColor(self.OriginalValue)

    self.REntry:SetValue(math.floor(self.OriginalValue.r))
    self.GEntry:SetValue(math.floor(self.OriginalValue.g))
    self.BEntry:SetValue(math.floor(self.OriginalValue.b))
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
    self.Reset:DockMargin(0, (h - Elib.Scale(30)) / 2, 4, 0)
    self.Reset:SetHeight(Elib.Scale(30))

    local entryHeight = (self.RGBPanel:GetTall() - Elib.Scale(4)) / 3
    self.REntry:SetPos(0, 0)
    self.REntry:SetSize(self.RGBPanel:GetWide(), entryHeight)
    self.GEntry:SetPos(0, entryHeight + Elib.Scale(2))
    self.GEntry:SetSize(self.RGBPanel:GetWide(), entryHeight)
    self.BEntry:SetPos(0, (entryHeight + Elib.Scale(2)) * 2)
    self.BEntry:SetSize(self.RGBPanel:GetWide(), entryHeight)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Background, 6))
    Elib.DrawSimpleText(self.Text, "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.Config.Panels.Color", PANEL, "DPanel")