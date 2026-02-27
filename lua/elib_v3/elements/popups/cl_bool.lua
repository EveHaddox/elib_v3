// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Popup Boolean
///////////////////
local PANEL = {}

Elib.RegisterFont("Elib.PopupText", "Inter Semi Bold", 22)

function PANEL:Init()
    self.Frame:SetTitle("Boolean Popup")

    self.Text = self.Frame:Add("Elib.Label")
    self.Text:SetText("Please confirm your choice.")
    self.Text:Dock(TOP)
    self.Text:SetFont("Elib.PopupText")
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
    self.Text:SetAutoWrap(true)
    self.Text:SetAutoHeight(true)

    self.ButtonPanel = self.Frame:Add("DPanel")
    self.ButtonPanel:Dock(TOP)
    self.ButtonPanel:SetTall(40)
    self.ButtonPanel:DockMargin(0, 8, 0, 0)

    self.ButtonPanel.Paint = function() end

    self.Cancel = self.ButtonPanel:Add("Elib.TextButton")
    self.Cancel:SetText("Cancel")
    self.Cancel:Dock(LEFT)
    self.Cancel:DockMargin(0, 0, 4, 0)

    self.Cancel.NormalCol = Elib.CopyColor(Elib.Colors.Negative)
    self.Cancel.HoverCol = Elib.OffsetColor(self.Cancel.NormalCol, -15)
    self.Cancel.ClickedCol = Elib.OffsetColor(self.Cancel.NormalCol, 15)
    self.Cancel.BackgroundCol = self.Cancel.NormalCol

    self.Cancel.DoClick = function()
        if self.func then
            self.func(false)
        end
        self:Remove()
    end

    self.Confirm = self.ButtonPanel:Add("Elib.TextButton")
    self.Confirm:SetText("Confirm")
    self.Confirm:Dock(FILL)

    self.Confirm.DoClick = function()
        if self.func then
            self.func(true)
        end
        self:Remove()
    end

    self.Confirm.NormalCol = Elib.CopyColor(Elib.Colors.Positive)
    self.Confirm.HoverCol = Elib.OffsetColor(self.Confirm.NormalCol, -15)
    self.Confirm.ClickedCol = Elib.OffsetColor(self.Confirm.NormalCol, 15)
    self.Confirm.BackgroundCol = self.Confirm.NormalCol

    hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
    self.Text:SetTextColor(Elib.Colors.SecondaryText)
    self.Cancel.NormalCol = Elib.CopyColor(Elib.Colors.Negative)
    self.Cancel.HoverCol = Elib.OffsetColor(self.Cancel.NormalCol, -15)
    self.Cancel.ClickedCol = Elib.OffsetColor(self.Cancel.NormalCol, 15)
    self.Cancel.BackgroundCol = self.Cancel.NormalCol
    self.Confirm.NormalCol = Elib.CopyColor(Elib.Colors.Positive)
    self.Confirm.HoverCol = Elib.OffsetColor(self.Confirm.NormalCol, -15)
    self.Confirm.ClickedCol = Elib.OffsetColor(self.Confirm.NormalCol, 15)
    self.Confirm.BackgroundCol = self.Confirm.NormalCol
end

function PANEL:PerformSecondaryLayout()
    self.Cancel:SetWide(self.ButtonPanel:GetWide() / 2 - 2)
end

function PANEL:SetText(text)
    self.Text:SetText(text)
end

function PANEL:SetFunction(func)
    self.func = func
end

vgui.Register("Elib.PopupBool", PANEL, "Elib.PopupBase")