// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

function PANEL:Init()


    
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
    Elib.DrawRoundedBox(6, 0, 0, w, h, Elib.OffsetColor(Elib.Colors.Background, 6))
end

vgui.Register("Elib.Config.Panels.Number", PANEL, "DPanel")