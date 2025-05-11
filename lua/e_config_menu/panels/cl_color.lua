// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()

    local height = Elib.Scale(80)
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
        local color = self.colorPicker:GetHueColor()
        Elib.DrawRoundedBox(6, 0, 0, w, h, color)
    end

    self.colorPicker = self:Add("Elib.ColorPicker")
    self.colorPicker:Dock(RIGHT)
    self.colorPicker:DockMargin(0, 4, 4, 4)
    self.colorPicker:SetWide(height)

    self.colorPicker.OnChange = function(pnl, value)
        if self.OriginalValue == nil then return end
        self.Saved = value == self.OriginalValue
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
        if self.Saved then return end
        self.colorPicker:SetColor(self.OriginalValue)
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

function PANEL:SetValue(value)
    self.OriginalValue = value
    self.colorPicker:SetColor(value)
end

function PANEL:GetValue()
    return self.colorPicker:GetHueColor()
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
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Background, 6))
    Elib.DrawSimpleText(self.Text, "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.Config.Panels.Color", PANEL, "DPanel")