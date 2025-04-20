// Script made by Eve Haddox
// discord evehaddox


//////////////////
// Addons Panel //
//////////////////
if SERVER then return end

Elib.Config = Elib.Config or {}

Elib.RegisterFont("Elib.Config.Title", "Space Grotesk SemiBold", 24)
Elib.RegisterFont("Elib.Config.normal", "Space Grotesk SemiBold", 20)

local PANEL = {}

function PANEL:Init()

    self.addons = {}
    
    self.Scroll = self:Add("Elib.ScrollPanel")
    self.Scroll:Dock(FILL)

    for k, v in ipairs(Elib.Config.Addons) do
        self.addons[k] = self.Scroll:Add("DPanel")
        local addon = self.addons[k]

        addon:Dock(TOP)
        addon:DockMargin(0, 0, 0, Elib.Scale(4))
        addon:SetHeight(Elib.Scale(30))

        addon.hovered = false

        addon.Paint = function(pnl, w, h)
            Elib.DrawRoundedBox(6, 0, 0, w, h, addon.hovered and Elib.OffsetColor(Elib.Colors.Background, 5) or Elib.Colors.Background)
            Elib.DrawSimpleText(v.name, "Elib.Config.Title", 10, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            Elib.DrawSimpleText(v.author.name, "Elib.Config.normal", w - h - 2, h / 2, Elib.Colors.SecondaryText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        addon.OnCursorEntered = function(pnl)
            addon.hovered = true
        end
        addon.OnCursorExited = function(pnl)
            addon.hovered = false
        end

        addon.OnMousePressed = function(pnl, mcode)
            if mcode == MOUSE_LEFT then
                -- Open the addon menu
                -- Elib.Config.Addons[k].Open()
            end
        end

        addon.Avatar = addon:Add("Elib.Avatar")
        addon.Avatar:Dock(RIGHT)
        addon.Avatar:DockMargin(0, 4, 4, 4)
        addon.Avatar:SetWide(Elib.Scale(30) - 8)
        addon.Avatar:SetMaskSize(16)

        addon.Avatar:SetSteamID(v.author.steamid, 256)

        self.addons[k] = addon
    end

end

function PANEL:PerformLayout(w, h)
    --[[
    for k, v in ipairs(self.addons) do
        
        v.Avatar:Dock(RIGHT)
    end
    ]]
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