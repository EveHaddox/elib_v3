//////////////////
// Addons Panel //
//////////////////
if SERVER then return end

Elib.Config = Elib.Config or {}

local PANEL = {}

function PANEL:Init()
    
    self.Scroll = self:Add("Elib.ScrollPanel")
    self.Scroll:Dock(FILL)

    self.buttonsHolder = self.Scroll:Add("DPanel")
    self.buttonsHolder:Dock(FILL)
    self.buttonsHolder:SetTall(Elib.Scale(120))
    self.buttonsHolder.Paint = function() end
    self.buttons = {}

    self.numButtons = 5
    self.spacing = 4

    self.NormalCol = Elib.CopyColor(Elib.OffsetColor(Elib.Colors.Background, 10)) --Color(35, 35, 35)
    self.HoverCol = Elib.OffsetColor(self.NormalCol, -10)
    self.ClickedCol = Elib.OffsetColor(self.NormalCol, 5)
    self.DisabledCol = Elib.CopyColor(Elib.Colors.Disabled)

    self.BackgroundCol = self.NormalCol

    local gradientMat = Material("gui/gradient_up")

    for i = 1, self.numButtons do
        self.buttons[i] = self.buttonsHolder:Add("DButton")
        self.buttons[i]:SetText("Addon " .. i)
        self.buttons[i]:SetTextColor(Color(255, 255, 255))
        self.buttons[i].Paint = function(pnl, w, h)
        
            local bgCol = self.NormalCol
        
            if self.buttons[i]:IsDown() then
                bgCol = self.ClickedCol
            elseif self.buttons[i]:IsHovered() then
                bgCol = self.HoverCol
            end
        
            self.BackgroundCol = Elib.LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)
        
            -- 1) Enable stencil
            render.SetStencilEnable(true)
                
            -- 2) Clear stencil to zero
            render.ClearStencil()
            
            -- 3) Configure stencil
            render.SetStencilWriteMask(255)
            render.SetStencilTestMask(255)
            render.SetStencilReferenceValue(1)
        
            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            render.SetStencilPassOperation(STENCIL_REPLACE)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)
        
            -- 4) Draw the rectangle that will define our "allowed" area
            Elib.DrawFullRoundedBox(Elib.Scale(8), 0, 0, w, h - 4, Elib.OffsetColor(self.NormalCol, -12))
        
            -- 5) Now switch to only drawing where the stencil == 1
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilPassOperation(STENCIL_KEEP)
        
            -- 6) Draw anything that should appear *inside* the rectangle
            surface.SetDrawColor(self.BackgroundCol)  
            surface.SetMaterial(gradientMat)
            surface.DrawTexturedRect(0, 0, w, h - 4)
        
            -- 7) Disable stencil
            render.SetStencilEnable(false)
        
            Elib.DrawOutlinedRoundedBox(Elib.Scale(5), 0, 0, w, h - 4, Elib.OffsetColor(self.NormalCol, 30), 1)
        end
    end

    self.OnSizeChanged = function(w, h)
        self.buttonsHolder:SetHeight(h / 1.5)
        for k, v in ipairs(self.buttons) do
            v:SetHeight(h / 1.5)
        end
    end

end

function PANEL:PerformLayout(w, h)
    local buttonWidth = (w - (self.numButtons + 1) * self.spacing) / self.numButtons
    local buttonHeight = Elib.Scale(120)

    for i = 1, self.numButtons do
        local btn = self.buttons[i]
        if IsValid(btn) then
            btn:SetSize(buttonWidth, buttonHeight)
            btn:SetPos(self.spacing + (i - 1) * (buttonWidth + self.spacing), self.spacing)
        end
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