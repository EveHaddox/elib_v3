// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

function PANEL:Init()
    self.NormalCol = Elib.CopyColor(Elib.OffsetColor(Elib.Colors.Background, 10)) --Color(35, 35, 35)
    self.HoverCol = Elib.OffsetColor(self.NormalCol, -5)
    self.ClickedCol = Elib.OffsetColor(self.NormalCol, 5)
    self.DisabledCol = Elib.CopyColor(Elib.Colors.Disabled)

    self.BackgroundCol = self.NormalCol
end

local gradientMat = Material("gui/gradient_up")

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        Elib.DrawRoundedBox(Elib.Scale(6), 0, 0, w, h, self.DisabledCol)
        self:PaintExtra(w, h)
        return
    end

    local bgCol = self.NormalCol

    if self:IsDown() or self:GetToggle() then
        bgCol = self.ClickedCol
    elseif self:IsHovered() then
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
    Elib.DrawRoundedBox(Elib.Scale(8), 0, 0, w, h, Elib.OffsetColor(self.NormalCol, -12))

    -- 5) Now switch to only drawing where the stencil == 1
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    -- 6) Draw anything that should appear *inside* the rectangle
    surface.SetDrawColor(self.BackgroundCol)  
    surface.SetMaterial(gradientMat)
    surface.DrawTexturedRect(0, 0, w, h)

    -- 7) Disable stencil
    render.SetStencilEnable(false)

    Elib.DrawOutlinedRoundedBox(Elib.Scale(5), 0, 0, w, h, Elib.OffsetColor(self.NormalCol, 30), 1)

    self:PaintExtra(w, h)
end

vgui.Register("Elib.GradientButton", PANEL, "Elib.Button")