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

AccessorFunc(PANEL, "Draggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "CanFullscreen", "CanFullscreen", FORCE_BOOL)
AccessorFunc(PANEL, "Sizable", "Sizable", FORCE_BOOL)
AccessorFunc(PANEL, "MinWidth", "MinWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "MinHeight", "MinHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "ScreenLock", "ScreenLock", FORCE_BOOL)
AccessorFunc(PANEL, "RemoveOnClose", "RemoveOnClose", FORCE_BOOL)

AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)

AccessorFunc(PANEL, "Padding", "Padding", FORCE_NUMBER)
AccessorFunc(PANEL, "SidebarWidh", "SidebarWidh", FORCE_NUMBER)

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

Elib.RegisterFont("UI.FrameTitle", "Space Grotesk Bold", 22)

function PANEL:Init()
	self.CloseButton = vgui.Create("Elib.ImageButton", self)
	self.CloseButton:SetImageURL("https://construct-cdn.physgun.com/images/204e6270-1a86-4af6-9350-66cfd5dd8b5a.png") -- https://pixel-cdn.lythium.dev/i/fh640z2o pixel ui one
	self.CloseButton:SetNormalColor(Elib.Colors.PrimaryText)
	self.CloseButton:SetHoverColor(Elib.Colors.Negative)
	self.CloseButton:SetClickColor(Elib.Colors.Negative)
	self.CloseButton:SetDisabledColor(Elib.Colors.DisabledText)

	self.CloseButton.DoClick = function(s)
		self:Close()
	end

	self.FullscreenButton = vgui.Create("Elib.ImageButton", self)
	self.FullscreenButton:SetImageURL("https://construct-cdn.physgun.com/images/b3531bb5-c708-4d40-a263-48350672ea91.png")
	self.FullscreenButton:SetNormalColor(Elib.Colors.PrimaryText)
	self.FullscreenButton:SetHoverColor(Elib.Colors.Positive)
	self.FullscreenButton:SetClickColor(Elib.Colors.Positive)
	self.FullscreenButton:SetDisabledColor(Elib.Colors.DisabledText)

	self.FullscreenButton.DoClick = function(s)
		self:Fullscreen()
	end

	self.IsFullscreen = false

	self.ExtraButtons = {}

	self:SetTitle("Elib Frame")

	self:SetDraggable(true)
	self:SetCanFullscreen(true)
	self:SetScreenLock(true)
	self:SetRemoveOnClose(true)

	self:SetPadding(6)
	self:SetSidebarWidh(200)

	local size = Elib.Scale(200)
	self:SetMinWidth(size)
	self:SetMinHeight(size)

	local oldMakePopup = self.MakePopup
	function self:MakePopup()
		oldMakePopup(self)
		self:Open()
	end
end

function PANEL:DragThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Dragging then
		local x = mousex - targetPanel.Dragging[1]
		local y = mousey - targetPanel.Dragging[2]

		if targetPanel:GetScreenLock() then
			x = math.Clamp(x, 0, scrw - targetPanel:GetWide())
			y = math.Clamp(y, 0, scrh - targetPanel:GetTall())
		end

		targetPanel:SetPos(x, y)
	end

	local _, screenY = targetPanel:LocalToScreen(0, 0)
	if (hoverPanel or targetPanel).Hovered and targetPanel:GetDraggable() and mousey < (screenY + Elib.Scale(30)) then
		targetPanel:SetCursor("sizeall")
		return true
	end
end

function PANEL:SizeThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Sizing then
		local x = mousex - targetPanel.Sizing[1]
		local y = mousey - targetPanel.Sizing[2]
		local px, py = targetPanel:GetPos()

		local screenLock = self:GetScreenLock()
		if x < targetPanel.MinWidth then x = targetPanel.MinWidth elseif x > scrw - px and screenLock then x = scrw - px end
		if y < targetPanel.MinHeight then y = targetPanel.MinHeight elseif y > scrh - py and screenLock then y = scrh - py end

		targetPanel:SetSize(x, y)
		targetPanel:SetCursor("sizenwse")
		return true
	end

	local screenX, screenY = targetPanel:LocalToScreen(0, 0)
	if (hoverPanel or targetPanel).Hovered and targetPanel.Sizable and mousex > (screenX + targetPanel:GetWide() - Elib.Scale(20)) and mousey > (screenY + targetPanel:GetTall() - Elib.Scale(20)) then
		(hoverPanel or targetPanel):SetCursor("sizenwse")
		return true
	end
end

function PANEL:Think()
	if self:DragThink(self) then return end
	if self:SizeThink(self) then return end

	self:SetCursor("arrow")

	if self.y < 0 then
		self:SetPos(self.x, 0)
	end
end

function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen(0, 0)
	local mouseX, mouseY = gui.MouseX(), gui.MouseY()

	if self.Sizable and mouseX > (screenX + self:GetWide() - Elib.Scale(30)) and mouseY > (screenY + self:GetTall() - Elib.Scale(30)) then
		self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
		self:MouseCapture(true)
		return
	end

	if self:GetDraggable() and mouseY < (screenY + Elib.Scale(30)) then
		self.Dragging = {mouseX - self.x, mouseY - self.y}
		self:MouseCapture(true)
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture(false)
end

function PANEL:CreateSidebar(defaultItem, imageURL, imageScale, imageYOffset, buttonYOffset)
	if IsValid(self.SideBar) then return end
	self.SideBar = vgui.Create("Elib.Sidebar", self)
	
	self.SideBar:SetDrawShadow(true)

	if defaultItem then
		timer.Simple(0, function()
			if not IsValid(self.SideBar) then return end
			self.SideBar:SelectItem(defaultItem)
		end)
	end

	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		self.SideBar:SetImageURL(imageURL)
	end

	if imageScale then self.SideBar:SetImageScale(imageScale) end
	if imageYOffset then self.SideBar:SetImageOffset(imageYOffset) end
	if buttonYOffset then self.SideBar:SetButtonOffset(buttonYOffset) end

	return self.SideBar
end

function PANEL:AddHeaderButton(elem, size)
	elem.HeaderIconSize = size or .6
	return table.insert(self.ExtraButtons, elem)
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
	local headerH = Elib.Scale(40)
	local btnPad = Elib.Scale(6)
	local btnSpacing = Elib.Scale(6)

	if IsValid(self.CloseButton) then
		local btnSize = headerH * .6
		self.CloseButton:SetSize(btnSize, btnSize)
		self.CloseButton:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)

		btnPad = btnPad + btnSize + btnSpacing
	end

	if not self:GetCanFullscreen() and IsValid(self.FullscreenButton) then self.FullscreenButton:Remove() end
	if IsValid(self.FullscreenButton) then
		local btnSize = headerH * .6
		self.FullscreenButton:SetSize(btnSize, btnSize)
		self.FullscreenButton:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)

		btnPad = btnPad + btnSize + btnSpacing
	end

	for _, btn in ipairs(self.ExtraButtons) do
		local btnSize = headerH * btn.HeaderIconSize
		btn:SetSize(btnSize, btnSize)
		btn:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)
		btnPad = btnPad + btnSize + btnSpacing
	end

	if IsValid(self.SideBar) then
		self.SideBar:SetPos(0, headerH)
		self.SideBar:SetSize(Elib.Scale(self:GetSidebarWidh()), h - headerH)
	end

	local padding = Elib.Scale(self:GetPadding())
	self:DockPadding(self.SideBar and Elib.Scale(self:GetSidebarWidh()) + padding or padding, headerH + padding, padding, padding)

	self:LayoutContent(w, h)
end

function PANEL:Open()

	local w, h = self:GetSize()

	timer.Simple(0, function()
		self:SetAlpha(0)
		self:SetVisible(true)
		self:AlphaTo(255, .25, 0)
		self:SetSize( 35, 35 )
		self:SizeTo( w, 35, 0.25 )
		self:SizeTo( w, h, 0.25, 0.25 )
		self:SetPos( ScrW()/2, ScrH()/2 -35/2 )
		self:MoveTo( ScrW()/2 -w/2, ScrH()/2 -35/2, 0.25 )
		self:MoveTo( ScrW()/2 -w/2, ScrH()/2 -h/2, 0.25, 0.25 )
	end)
	
end

function PANEL:Close()
	self:AlphaTo(0, .25, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:OnClose()
		if pnl:GetRemoveOnClose() then pnl:Remove() end
	end)
end

function PANEL:OnClose() end

function PANEL:Fullscreen()

	if not self:GetCanFullscreen() then return end

	if self.IsFullscreen then
		local w, h = unpack(self.LastSize)
		self:SizeTo(w, h, .25)
		self:MoveTo(ScrW()/2 - w/2, ScrH()/2 - h/2, .25)
		self:Center()
		if self.shouldDrag then
			self:SetDraggable(true)
		end
		if self.shouldSizeble then
			self:SetSizable(true)
		end
	else
		self.LastSize = {self:GetSize()}
		timer.Simple(0, function()
			self:SizeTo(ScrW(), ScrH(), 0.25)
			self:MoveTo(0, 0, 0.25, 0, -ScrH()/2)
			self:Center()
			self.shouldDrag = self:GetDraggable()
			self.shouldSizeble = self:GetSizable()
			self:SetDraggable(false)
		end)
	end

	self.IsFullscreen = not self.IsFullscreen
end

function PANEL:PaintHeader(x, y, w, h)
	--Elib.DrawRoundedBoxEx(Elib.Scale(6), x, y, w, h, Elib.Colors.Header, true, true)

	local CornerRadius = Elib.Scale(6)
	if self.IsFullscreen then
		CornerRadius = 0
	end

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
    Elib.DrawRoundedBoxEx(CornerRadius, 0, 0, w, h, Elib.Colors.Header, true, true)

    -- 5) Now switch to only drawing where the stencil == 1
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    -- 6) Draw anything that should appear *inside* the rectangle
	surface.SetDrawColor(Elib.OffsetColor(Elib.Colors.Background, 5))
	surface.SetMaterial(Material("gui/gradient_up"))
	surface.DrawTexturedRect(0, 0, w, h)

	-- 7) Disable stencil
    render.SetStencilEnable(false)

	surface.SetDrawColor(Color(45, 45, 45))
	surface.DrawRect(0, h - 1, w, 1)

	surface.SetDrawColor(Elib.Colors.Background)
	surface.SetMaterial(Material("gui/gradient_down"))
	surface.DrawTexturedRect(0, h + 1, w, Elib.Scale(10))

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .6
		Elib.DrawImage(Elib.Scale(6), x + (h - iconSize) / 2, y + iconSize, iconSize, imageURL, color_white)
		Elib.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + Elib.Scale(10) + iconSize, y + h / 2 - 2, Elib.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
		return
	end

	Elib.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + Elib.Scale(6), y + h / 2, Elib.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
end

local gradientMat = Material("gui/center_gradient")

function PANEL:Paint(w, h)

	local CornerRadius = Elib.Scale(6)
	if self.IsFullscreen then
		CornerRadius = 0
	end

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
    Elib.DrawRoundedBox(CornerRadius, 0, 0, w, h, Elib.Colors.Background)

    -- 5) Now switch to only drawing where the stencil == 1
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    -- 6) Draw anything that should appear *inside* the rectangle
	
	--Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/bb26c4a0-cf84-4043-ab87-bff0cc9af57f.png", Color(255, 255, 255, 20))
	Elib.DrawImage(0, 0, w, h, "https://construct-cdn.physgun.com/images/299b15c9-d403-44f9-bf4a-0b4dce07baf1.png", Color(255, 255, 255, 255))

    -- 7) Disable stencil
    render.SetStencilEnable(false)

	--Elib.DrawRoundedBox(CornerRadius, 0, 0, w, h, Elib.Colors.Background)
	self:PaintHeader(0, 0, w, Elib.Scale(40))
end

vgui.Register("Elib.Frame", PANEL, "EditablePanel")
