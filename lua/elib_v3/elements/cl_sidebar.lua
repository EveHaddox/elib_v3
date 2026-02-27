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
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "DrawOutline", "DrawOutline", FORCE_BOOL)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

Elib.RegisterFont("SidebarItem", "Space Grotesk Bold", 19)

function PANEL:Init()
	self:SetName("N/A")
	self:SetDrawOutline(true)

	self.TextCol = Elib.CopyColor(Elib.Colors.SecondaryText)
	self.BackgroundCol = Elib.CopyColor(Elib.Colors.Transparent)
	self.BackgroundHoverCol = ColorAlpha(Elib.Colors.Scroller, 80)
	self.AccentCol = Elib.CopyColor(Elib.Colors.Primary)

	self.AnimH = 0

	hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
	self.TextCol = Elib.CopyColor(Elib.Colors.SecondaryText)
	self.BackgroundCol = Elib.CopyColor(Elib.Colors.Transparent)
	self.BackgroundHoverCol = ColorAlpha(Elib.Colors.Scroller, 80)
	self.AccentCol = Elib.CopyColor(Elib.Colors.Primary)
end

function PANEL:Paint(w, h)
	local textCol = Elib.Colors.SecondaryText
	local backgroundCol = Elib.Colors.Transparent
	local Animate = false

	if self:IsHovered() then
		textCol = Elib.Colors.PrimaryText
		backgroundCol = self.BackgroundHoverCol
		Animate = true
	end

	if self:IsDown() or self:GetToggle() then
		textCol = Elib.Colors.PrimaryText
		backgroundCol = self.BackgroundHoverCol
		Animate = true
	end

	local animTime = FrameTime() * 12
	self.TextCol = Elib.LerpColor(animTime, self.TextCol, textCol)
	self.BackgroundCol = Elib.LerpColor(animTime, self.BackgroundCol, backgroundCol)
	if Animate and h != self.AnimH or not Animate and self.AnimH != 0 then
		self.AnimH = Lerp(animTime, self.AnimH, Animate and h or 0)
		self.AnimH = math.Clamp(self.AnimH, 0, h)
	end
	

	if self:GetDrawOutline() then Elib.DrawRoundedBox(Elib.Scale(6), 0, 0, w, h, self.BackgroundCol, Elib.Scale(1)) end
	Elib.DrawRoundedBox(Elib.Scale(6), 0, (h - self.AnimH) / 2, Elib.Scale(3), self.AnimH, self.AccentCol)

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .65
		Elib.DrawImage(Elib.Scale(10), (h - iconSize) / 2, iconSize, iconSize, imageURL, self.TextCol)
		Elib.DrawSimpleText(self:GetName(), "SidebarItem", Elib.Scale(20) + iconSize, h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	Elib.DrawSimpleText(self:GetName(), "SidebarItem", Elib.Scale(10), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.SidebarItem", PANEL, "Elib.Button")

PANEL = {}

AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "ImageScale", "ImageScale", FORCE_NUMBER)
AccessorFunc(PANEL, "ImageOffset", "ImageOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "ButtonOffset", "ButtonOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "DrawShadow", "DrawShadow", FORCE_BOOL)

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImgurScale", "ImgurScale", FORCE_NUMBER) -- Deprecated
AccessorFunc(PANEL, "ImgurOffset", "ImgurOffset", FORCE_NUMBER) -- Deprecated

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

function PANEL:SetImgurScale(scale)
	self:SetImageScale(scale)
	self.ImgurScale = scale
end

function PANEL:GetImgurScale()
	return self:GetImageScale()
end

function PANEL:SetImgurOffset(offset)
	self:SetImageOffset(offset)
	self.ImgurOffset = offset
end

function PANEL:GetImgurOffset()
	return self:GetImageOffset()
end

function PANEL:Init()
	self.Items = {}

	self.Scroller = vgui.Create("Elib.ScrollPanel", self)
	self.Scroller:SetBarDockShouldOffset(true)
	self.Scroller.LayoutContent = function(s, w, h)
		local spacing = Elib.Scale(8)
		local height = Elib.Scale(35)
		for k,v in pairs(self.Items) do
			v:SetTall(height)
			v:Dock(TOP)
			v:DockMargin(0, 0, 0, spacing)
		end
	end

	self:SetImageScale(.6)
	self:SetImageOffset(0)
	self:SetButtonOffset(0)

	self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Header, -5)

	hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
	self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Header, -5)
end

function PANEL:AddItem(id, name, imageURL, doClick, order)
	local btn = vgui.Create("Elib.SidebarItem", self.Scroller)

	btn:SetZPos(order or table.Count(self.Items) + 1)
	btn:SetName(name)
	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		btn:SetImageURL(imageURL)
	end
	btn.Function = doClick

	btn.DoClick = function(s)
		self:SelectItem(id)
	end

	self.Items[id] = btn

	return btn
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
	local sideSpacing = Elib.Scale(7)
	local topSpacing = Elib.Scale(7)
	self:DockPadding(sideSpacing, self:GetImageURL() and w * self:GetImageScale() + self:GetImageOffset() + self:GetButtonOffset() + topSpacing * 2 or topSpacing, sideSpacing, topSpacing)

	self.Scroller:Dock(FILL)
	self.Scroller:GetCanvas():DockPadding(0, 0, self.Scroller.VBar.Enabled and sideSpacing or 0, 0)
end

function PANEL:Paint(w, h)
	Elib.DrawRoundedBoxEx(Elib.Scale(6), 0, 0, w, h, self.BackgroundCol, false, false, true)

	local imageURL = self:GetImageURL()
	if imageURL then
		local imageSize = w * self:GetImageScale()
		Elib.DrawImage((w - imageSize) / 2, self:GetImageOffset() + Elib.Scale(15), imageSize, imageSize, imageURL, color_white)
	end

	if self:GetDrawShadow() then
		surface.SetDrawColor(self.BackgroundCol)
		surface.SetMaterial(Material("gui/gradient_down"))
		surface.DrawTexturedRect(0, 0, w, Elib.Scale(10))
	end
end

vgui.Register("Elib.Sidebar", PANEL, "Panel")