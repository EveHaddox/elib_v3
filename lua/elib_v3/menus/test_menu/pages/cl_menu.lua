// Script made by Eve Haddox
// discord evehaddox


/// Menu | Page 8
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Menu", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Menu]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    // menu
    local btn = self:Add("Elib.TextButton")
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, 8)
    btn:SetTall(Elib.Scale(30))
    btn:SetText("Open Elib Menu")
    btn.DoClick = function()
        local menu = vgui.Create("Elib.Menu")
        menu:AddOption("Say Hello", function() print("Hello!") end)
        menu:AddOption("Print Time", function() print(os.date("%X")) end)
        menu:AddSpacer()
        local subMenu, parent = menu:AddSubMenu("More Options")
        subMenu:AddOption("Option A", function() print("A selected") end)
        subMenu:AddOption("Option B", function() print("B selected") end)
        menu:Open()
    end

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page8", PANEL, "Panel")