// Script made by Eve Haddox
// discord evehaddox


//////////////////
// Addons Panel //
//////////////////
if SERVER then return end

Elib.Config = Elib.Config or {}

local PANEL = {}

function PANEL:Init()

    self.addons = {}
    
    self.Scroll = self:Add("Elib.ScrollPanel")
    self.Scroll:Dock(FILL)

    for k, v in pairs(Elib.Config.Addons) do
        local addon = self.Scroll:Add("Elib.Config.Addon")
        addon:SetAddon(v)
        addon:Dock(TOP)
        addon:DockMargin(0, 0, 0, Elib.Scale(5))

        self.addons[k] = addon
    end

end

function PANEL:PerformLayout(w, h)

end

function PANEL:Paint(w, h)
end

vgui.Register("Elib.Config.Addons", PANEL, "DPanel")

////////////////////
// Menu Container //
////////////////////
local function CreateConfigMenu()
    Elib.Config.Menu = vgui.Create("Elib.Frame")
    Elib.Config.Menu:SetTitle("Elib Config Menu")
    Elib.Config.Menu:SetImageURL("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    Elib.Config.Menu:SetSize(Elib.Scale(900), Elib.Scale(600))
    Elib.Config.Menu:Center()
    Elib.Config.Menu:SetRemoveOnClose(false)

    Elib.Config.Menu.Addons = Elib.Config.Menu:Add("Elib.Config.Addons")
    Elib.Config.Menu.Addons:Dock(FILL)

    Elib.Config.Menu:MakePopup()
end

if IsValid(Elib.Config.Menu) then Elib.Config.Menu:Remove() CreateConfigMenu() end

concommand.Add("elib_config", function()

    if not IsValid(Elib.Config.Menu) then
        CreateConfigMenu()
        return
    end
    if not IsValid(Elib.Config.Menu) then return end
    if Elib.Config.Menu:IsVisible() then
        Elib.Config.Menu:Close()
    else
        // Open With Animation
        --Elib.Config.Menu:Open()
        Elib.Config.Menu:MakePopup() -- it has open
    end
    
end)