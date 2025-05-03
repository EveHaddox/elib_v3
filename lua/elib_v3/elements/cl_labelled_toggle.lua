// Script made by Eve Haddox
// discord evehaddox

local PANEL = {}

function PANEL:Init()
    self.Toggle = vgui.Create("Elib.Toggle", self)

    self.Toggle.OnToggled = function(s, enabled)
        self:OnToggled(enabled)
    end

    self.LabelHolder = vgui.Create("Panel", self)
    self.Label = vgui.Create("Elib.Label", self.LabelHolder)
    self.Label:SetAutoWidth(true)
    self.Label:SetAutoHeight(true)

    self.LabelHolder.PerformLayout = function(s, w, h)
        self.Label:CenterVertical()
        s:SizeToChildren(true, true)
        self:SizeToChildren(true, true)
    end
end

function PANEL:PerformLayout(w, h)
    self.Toggle:Dock(LEFT)
    self.Toggle:SetWide(h * 2)
    self.Toggle:DockMargin(0, 0, Elib.Scale(6), 0)

    self.LabelHolder:Dock(LEFT)
end

function PANEL:SetToggle(toggle)
    self.Toggle:SetToggle(toggle)
end

function PANEL:OnToggled(enabled) end

function PANEL:SetText(text) self.Label:SetText(text) end
function PANEL:GetText() return self.Label:GetText() end

function PANEL:SetFont(font) self.Label:SetFont(font) end
function PANEL:GetFont() return self.Label:GetFont() end

function PANEL:SetTextColor(col) self.Label:SetTextColor(col) end
function PANEL:GetTextColor() return self.Label:GetTextColor() end

function PANEL:SetAutoWrap(enabled) self.Label:SetAutoWrap(enabled) end
function PANEL:GetAutoWrap() return self.Label:GetAutoWrap() end

vgui.Register("Elib.LabelledToggle", PANEL, "Panel")