--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local PANEL = {}

AccessorFunc(PANEL, "IsToggle", "IsToggle", FORCE_BOOL)
AccessorFunc(PANEL, "Toggle", "Toggle", FORCE_BOOL)

function PANEL:Init()
    self:SetIsToggle(false)
    self:SetToggle(false)
    self:SetMouseInputEnabled(true)

    self:SetCursor("hand")

    local btnSize = Elib.Scale(30)
    self:SetSize(btnSize, btnSize)

    self.NormalCol = Elib.CopyColor(Elib.OffsetColor(Elib.Colors.Background, 10)) --Color(35, 35, 35)
    self.HoverCol = Elib.OffsetColor(self.NormalCol, -5)
    self.ClickedCol = Elib.OffsetColor(self.NormalCol, 5)
    self.DisabledCol = Elib.CopyColor(Elib.Colors.Disabled)

    self.BackgroundCol = self.NormalCol
end

function PANEL:DoToggle(...)
    if not self:GetIsToggle() then return end

    self:SetToggle(not self:GetToggle())
    self:OnToggled(self:GetToggle(), ...)
end

local localPly
function PANEL:OnMousePressed(mouseCode)
    if not self:IsEnabled() then return end

    if not localPly then
        localPly = LocalPlayer()
    end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT and (input.IsShiftDown() or input.IsControlDown()) and not (localPly:KeyDown(IN_FORWARD) or localPly:KeyDown(IN_BACK) or localPly:KeyDown(IN_MOVELEFT) or localPly:KeyDown(IN_MOVERIGHT)) then
        return self:StartBoxSelection()
    end

    self:MouseCapture(true)
    self.Depressed = true
    self:OnPressed(mouseCode)

    self:DragMousePress(mouseCode)
end

function PANEL:OnMouseReleased(mouseCode)
    self:MouseCapture(false)

    if not self:IsEnabled() then return end
    if not self.Depressed and dragndrop.m_DraggingMain ~= self then return end

    if self.Depressed then
        self.Depressed = nil
        self:OnReleased(mouseCode)
    end

    if self:DragMouseRelease(mouseCode) then
        return
    end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT then
        local canvas = self:GetSelectionCanvas()
        if canvas then
            canvas:UnselectAll()
        end
    end

    if not self.Hovered then return end

    self.Depressed = true

    if mouseCode == MOUSE_RIGHT then
        self:DoRightClick()
    elseif mouseCode == MOUSE_LEFT then
        self:DoClick()
    elseif mouseCode == MOUSE_MIDDLE then
        self:DoMiddleClick()
    end

    self.Depressed = nil
end

function PANEL:PaintExtra(w, h) end

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
    Elib.DrawFullRoundedBox(Elib.Scale(8), 0, 0, w, h, Elib.OffsetColor(self.NormalCol, -12))

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

function PANEL:IsDown() return self.Depressed end
function PANEL:OnPressed(mouseCode) end
function PANEL:OnReleased(mouseCode) end
function PANEL:OnToggled(enabled) end
function PANEL:DoClick(...) self:DoToggle(...) end
function PANEL:DoRightClick() end
function PANEL:DoMiddleClick() end

vgui.Register("Elib.Button", PANEL, "Panel")