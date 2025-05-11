// Script made by Eve Haddox
// discord evehaddox


/// Navbar | Page 9
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 38)
Elib.RegisterFont("Elib.Test.Normal", "Space Grotesk SemiBold", 20)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 8)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Navbar", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.label = self:Add("Elib.Label")
    self.label:Dock(TOP)
    self.label:DockMargin(0, 0, 0, 8)
    self.label:SetText([[Navbar]])
    self.label:SetAutoWrap(true)
    self.label:SetAutoHeight(true)
    self.label:SetAutoWidth(true)
    self.label:SetFont("Elib.Test.Normal")

    self.navbar = self:Add("Elib.Navbar")
    self.navbar:Dock(TOP)
    self.navbar:SetHeight(Elib.Scale(35))

    local pnls = {
        {pnl = "Elib.TextButton"},
        {pnl = "DPanel"}
    }

    local function swichPage()
        if IsValid(self.curpanel) then
            self.curpanel:Remove()
        end
        local id = self.navbar.SelectedItem
        self.curpanel = vgui.Create(pnls[id].pnl, self)
        self.curpanel:Dock(FILL)
    end

    self.navbar:AddItem(1, "test", swichPage, 1, Elib.Colors.Primary)
    self.navbar:AddItem(2, "test2", swichPage, 2, Elib.Colors.Primary)

    self.navbar:SelectItem(1)

end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page9", PANEL, "Panel")