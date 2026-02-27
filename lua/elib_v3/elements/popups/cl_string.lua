// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Popup String
///////////////////
local PANEL = {}

Elib.RegisterFont("Elib.PopupText", "Inter Semi Bold", 22)

function PANEL:Init()
    self.Frame:SetTitle("String Popup")

    self.Text = self.Frame:Add("Elib.Label")
    self.Text:SetText("What would you like to call this?")
    self.Text:Dock(TOP)
    self.Text:SetFont("Elib.PopupText")
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
    self.Text:SetAutoWrap(true)
    self.Text:SetAutoHeight(true)

    hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)

    self.Input = self.Frame:Add("Elib.TextEntry")
    self.Input:Dock(TOP)
    self.Input:SetTall(Elib.Scale(30))
    self.Input:DockMargin(0, 8, 0, 0)
    self.Input:SetPlaceholderText("Enter a name here...")

    self.Confirm = self.Frame:Add("Elib.GradientTextButton")
    self.Confirm:SetText("Confirm")
    self.Confirm:Dock(TOP)
    self.Confirm:DockMargin(0, 8, 0, 0)

    self.Confirm.DoClick = function()
        if self.func then
            self.func(self.Input:GetValue())
        end
        self:Remove()
    end
end

function PANEL:SetText(text)
    self.Text:SetText(text)
end

function PANEL:SetFunction(func)
    self.func = func
end

function PANEL:SetPlaceholder(text)
    self.Input:SetPlaceholderText(text)
end

function PANEL:UpdateColors()
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
end

vgui.Register("Elib.PopupString", PANEL, "Elib.PopupBase")