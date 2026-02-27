// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Popup Info
///////////////////
local PANEL = {}

Elib.RegisterFont("Elib.PopupText", "Inter Semi Bold", 22)

function PANEL:Init()
    self.Frame:SetTitle("Information")
    self.Frame:SetImageURL("https://construct-cdn.physgun.com/images/5c251e65-8d1e-4ebe-a015-750019251547.png")

    self.Text = self.Frame:Add("Elib.Label")
    self.Text:SetText("This is an information popup. You can use it to display messages to the user.")
    self.Text:Dock(TOP)
    self.Text:SetFont("Elib.PopupText")
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
    self.Text:SetAutoWrap(true)
    self.Text:SetAutoHeight(true)

    hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)

    self.Confirm = self.Frame:Add("Elib.GradientTextButton")
    self.Confirm:SetText("Understood")
    self.Confirm:Dock(TOP)
    self.Confirm:DockMargin(0, 8, 0, 0)

    self.Confirm.DoClick = function()
        self:Remove()
    end
end

function PANEL:SetText(text)
    self.Text:SetText(text)
end

function PANEL:UpdateColors()
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
end

vgui.Register("Elib.PopupInfo", PANEL, "Elib.PopupBase")