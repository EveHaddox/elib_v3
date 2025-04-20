// Script made by Eve Haddox
// discord evehaddox


/// Welcome Page | Page 1
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Welcome to the test menu", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 4)
    self.label:SetText(
[[Besides the obius experimenting with the libarie's visuals,
this will be used as example for the documentation.

I hope you find it useful!

List of Pages:
- Welcome
- Buttons
- Tab 3

You can find the source code at: elib_v3/lua/elib_v3/menus/cl_test.lua
Also you won't find a page on frames, as the whole menu is a frame! :D]])
    --self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetFont("Elib.Test.Normal")

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page1", PANEL, "Panel")