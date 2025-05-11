// Script made by Eve Haddox
// discord evehaddox


//////////////////
// Addons Panel //
//////////////////
Elib.RegisterFont("Elib.Config.Title", "Space Grotesk SemiBold", 24)
Elib.RegisterFont("Elib.Config.normal", "Space Grotesk SemiBold", 20)

local PANEL = {}

function PANEL:Init()

    self.addons = {}

    self.BackkgroundCol = Elib.OffsetColor(Elib.Colors.Background, 6)
    self.HoverCol = Elib.OffsetColor(Elib.Colors.Background, 12)
    self.ClickedCol = Elib.CopyColor(Elib.Colors.Background)

    self.func = function() end
    
    self.Scroll = self:Add("Elib.ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(6, 6, 6, 6)

    local addonEntries = {}
    for k, v in pairs(Elib.Config.Addons) do
        table.insert(addonEntries, v)
    end

    table.sort(addonEntries, function(a, b)
        return a.order < b.order
    end)

    for _, v in ipairs(addonEntries) do
        self.addons[v.name] = self.Scroll:Add("DPanel")
        local addon = self.addons[v.name]

        addon:Dock(TOP)
        addon:DockMargin(0, 0, 0, 4)
        addon:SetHeight(Elib.Scale(30))

        addon.Color = self.BackkgroundCol

        addon.OnCursorEntered = function(pnl)
            addon.Color = self.HoverCol
        end
        addon.OnCursorExited = function(pnl)
            addon.Color = self.BackkgroundCol
        end

        addon.OnMousePressed = function(pnl, mcode)
            if mcode == MOUSE_LEFT then
                addon.Color = self.ClickedCol
                self.func(v.name)
            end
        end
        addon.OnMouseReleased = function(pnl, mcode)
            if mcode == MOUSE_LEFT then
                addon.Color = self.HoverCol
            end
        end

        addon.Paint = function(pnl, w, h)
            Elib.DrawRoundedBox(6, 0, 0, w, h, addon.Color)
            Elib.DrawSimpleText(v.name, "Elib.Config.Title", 10, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            Elib.DrawSimpleText(v.author.name, "Elib.Config.normal", w - h - 2, h / 2, Elib.Colors.SecondaryText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        addon.Avatar = addon:Add("Elib.Avatar")
        addon.Avatar:Dock(RIGHT)
        addon.Avatar:DockMargin(0, 4, 4, 4)
        addon.Avatar:SetWide(Elib.Scale(30) - 8)
        addon.Avatar:SetMaskSize(16)

        addon.Avatar:SetSteamID(v.author.steamid, 256)
    end

end

function PANEL:SetFunc(func)
    self.func = func
end

function PANEL:PerformLayout(w, h)
    local barSpacing = self.Scroll:GetVBar().Enabled and PIXEL.Scale(6) or 0
    for k, v in pairs(self.addons) do
        v:DockMargin(0, 0, barSpacing, 4)
    end
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

    Elib.Config.Menu:SetPadding(0)

    Elib.Config.Menu.Addons = Elib.Config.Menu:Add("Elib.Config.Addons")
    Elib.Config.Menu.Addons:Dock(FILL)

    // slide anim
    Elib.Config.Menu.Addons:SetFunc(function(name)
        local leftPanel = Elib.Config.Menu.Addons
        local parent = leftPanel:GetParent()
        local parentW, parentH = parent:GetSize()
        local startY = leftPanel:GetY()

        leftPanel:Dock(NODOCK)
        leftPanel:SetPos(0, startY)
        leftPanel:SetSize(parentW, parentH)

        leftPanel:MoveTo(-parentW, startY, 0.3, 0)

        local detailPanel = vgui.Create("Elib.Config.Menu", parent)
        detailPanel:SetPos(parentW, startY)
        detailPanel:SetSize(parentW - 8, parentH - Elib.Scale(45) - 8)
        detailPanel:SetAddon(name)

        detailPanel:MoveTo(0, startY, 0.3, 0, nil, function()
            detailPanel:Dock(FILL)
            -- Now set the reverse function on detailPanel
            detailPanel:SetFunc(function()
                detailPanel:Dock(NODOCK)
                detailPanel:SetPos(0, startY)
                detailPanel:SetSize(parentW - 8, parentH - Elib.Scale(45) - 8)
                detailPanel:MoveTo(parentW, startY, 0.3, 0)

                leftPanel:MoveTo(0, startY, 0.3, 0, nil, function()
                    leftPanel:Dock(FILL)
                end)
            end)
        end)
    end)

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

// Button in the c menu (cause ppl can't find the command)
Elib.GetImage("https://construct-cdn.physgun.com/images/5cfb8931-ed9d-4efe-a16b-7e9cc7c0952a.png", function(mat) end)

hook.Add("ContextMenuCreated","Elib.context_button",function(context)
    list.Set( "DesktopWindows", "Elib", {
        title = "EConfig",
        icon = "data/elib/images/construct-cdn.physgun.com/images/5cfb8931-ed9d-4efe-a16b-7e9cc7c0952a.png",
        init = function(icon, window)
            RunConsoleCommand("elib_config")
        end
    })
end)