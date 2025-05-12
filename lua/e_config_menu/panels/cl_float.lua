// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()

    self:SetHeight(Elib.Scale(35))
    self:SetText("")

    self.OriginalValue = nil
    self.Saved = true

    self.TextEntry = self:Add("Elib.TextEntry")
    self.TextEntry:Dock(RIGHT)
    self.TextEntry:DockMargin(0, 4, 4, 4)
    self.TextEntry:SetWide(Elib.Scale(200))
    self.TextEntry:SetNumeric(true)
    self.TextEntry:SetUpdateOnType(true)
    self.TextEntry:SetPlaceholderText("Number")

    function self.TextEntry:OnLoseFocus()

        local parent = self:GetParent()
        if parent.OriginalValue == nil then return end
        if self:GetFloat() != parent.OriginalValue then 
            parent.Saved = false
            self.OutlineCol = Elib.Colors.Negative
        else 
            parent.Saved = true
            self.OutlineCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)
        end
        
    end

    self.Reset = self:Add("DButton")
    self.Reset:Dock(RIGHT)
    self.Reset:DockMargin(0, 4, 4, 4)
    self.Reset:SetText("")
    self.Reset.Color = Elib.Colors.PrimaryText

    self.Reset.DoClick = function(pnl)
        if self.Saved then return end
        self.TextEntry:SetValue(self.OriginalValue)
        self.Saved = true
        self.TextEntry.OutlineCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)
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
    self.TextEntry:SetValue(value)
end

function PANEL:GetValue()
    return self.TextEntry:GetFloat()
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
    self.TextEntry.OutlineCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)
    self.TextEntry:SetValue(self.OriginalValue)
end

function PANEL:Save()
    if self.Saved then return end
    local value = self:GetValue()

    Elib.Config.Save(self.Path.addon, self.Path.realm, self.Path.category, self.Path.id, value)

    Elib.Config.Addons[self.Path.addon][self.Path.realm][self.Path.category][self.Path.id].value = value
    self.Saved = true
    self.TextEntry.OutlineCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)
    self.OriginalValue = value
end

function PANEL:PerformLayout(w, h)
    self.Reset:SetWide(h - 8)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Background, 6))
    Elib.DrawSimpleText(self.Text, "Elib.Config.Title", 8, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.Config.Panels.Float", PANEL, "DPanel")