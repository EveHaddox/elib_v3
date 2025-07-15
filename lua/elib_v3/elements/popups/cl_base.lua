// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Popup Base
///////////////////
local PANEL = {}

function PANEL:Init()
    self:MakePopup()

    self.Frame = self:Add("Elib.Frame")
    self.Frame:SetSize(450, 250)
    self.Frame:SetSizable(false)
    self.Frame:SetDraggable(false)
    self.Frame:SetCanFullscreen(false)
    self.Frame:SetTitle("Popup")
    self.Frame.Open = function() end
    self.Frame:MakePopup()

    self.Frame.OnClose = function()
        self:Remove()
    end
end

function PANEL:Paint(w, h)
    Elib.DrawBlur(self, 0, 0, w, h)
    surface.SetDrawColor(Color(20, 20, 20, 150))
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PerformLayout()
    self:SetSize(ScrW(), ScrH())
    self:Center()

    self.Frame:InvalidateLayout()
    self.Frame:SizeToChildren(false, true)
    self.Frame:Center()

    self:PerformSecondaryLayout()
end

function PANEL:PerformSecondaryLayout()
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:SetTitle(title)
    self.Frame:SetTitle(title)
end

vgui.Register("Elib.PopupBase", PANEL, "Panel")