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

AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "Color", "Color")

Elib.RegisterFont("UI.NavbarItem", "Space Grotesk SemiBold", 22)

function PANEL:Init()
    self:SetName("N/A")
    self:SetColor(Elib.Colors.Primary)

    self.NormalCol = Elib.Colors.PrimaryText
    self.HoverCol = Elib.Colors.SecondaryText

    self.TextCol = Elib.CopyColor(self.NormalCol)
end

function PANEL:GetItemSize()
    Elib.SetFont("UI.NavbarItem")
    return Elib.GetTextSize(self:GetName())
end

function PANEL:Paint(w, h)
    local textCol = self.NormalCol

    if self:IsHovered() then
        textCol = self.HoverCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = Elib.LerpColor(animTime, self.TextCol, textCol)

    Elib.DrawSimpleText(self:GetName(), "UI.NavbarItem", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.NavbarItem", PANEL, "Elib.Button")

PANEL = {}

AccessorFunc(PANEL, "DrawShadow", "DrawShadow", FORCE_BOOL)

function PANEL:Init()
    self.Items = {}

    self.SelectionX = 0
    self.SelectionW = 0
    self.SelectionColor = Color(0, 0, 0)

    self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Background, 10)
end

function PANEL:AddItem(id, name, doClick, order, color)
    local btn = vgui.Create("Elib.NavbarItem", self)

    btn:SetName(name:upper())
    btn:SetZPos(order or table.Count(self.Items) + 1)
    btn:SetColor((IsColor(color) and color) or Elib.Colors.Primary)
    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn
end

function PANEL:RemoveItem(id)
    local item = self.Items[id]
    if not item then return end

    item:Remove()
    self.Items[id] = nil

    if self.SelectedItem != id then return end
    self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
    local item = self.Items[id]
    if not item then return end

    if self.SelectedItem and self.SelectedItem == id then return end
    self.SelectedItem = id

    for k,v in pairs(self.Items) do
        v:SetToggle(false)
    end

    item:SetToggle(true)
    item.Function(item)
end

function PANEL:PerformLayout(w, h)
    for k,v in pairs(self.Items) do
        v:Dock(LEFT)
        v:SetWide(v:GetItemSize() + Elib.Scale(30))
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.BackgroundCol)
    surface.DrawRect(0, 0, w, h)

    if self:GetDrawShadow() then
		surface.SetDrawColor(self.BackgroundCol)
		surface.SetMaterial(Material("gui/gradient_down"))
		surface.DrawTexturedRect(0, 0, w, Elib.Scale(10))
	end

    if not self.SelectedItem then
        self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionW = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionColor = Elib.LerpColor(FrameTime() * 10, self.SelectionColor, Elib.Colors.Primary)
        return
    end

    local selectedItem = self.Items[self.SelectedItem]
    self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, selectedItem.x)
    self.SelectionW = Lerp(FrameTime() * 10, self.SelectionW, selectedItem:GetWide())
    self.SelectionColor = Elib.LerpColor(FrameTime() * 10, self.SelectionColor, selectedItem:GetColor())

    local selectorH = Elib.Scale(6)
    surface.SetDrawColor(self.SelectionColor)
    surface.DrawRect(self.SelectionX + 2, h - selectorH, self.SelectionW - 4, selectorH / 2)
end

vgui.Register("Elib.Navbar", PANEL, "Panel")