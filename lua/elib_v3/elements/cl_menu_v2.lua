--[[
Apologise if this is badly written, it's code from 2 years back with functions swapped and shit to work with Elib :)
--]]
local OPTION = {}

AccessorFunc(OPTION, "m_pMenu", "Menu")
AccessorFunc(OPTION, "m_bChecked", "Checked")
AccessorFunc(OPTION, "m_bCheckable", "IsCheckable")

AccessorFunc(OPTION, "Text", "Text", FORCE_STRING)
AccessorFunc(OPTION, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(OPTION, "Font", "Font", FORCE_STRING)
AccessorFunc(OPTION, "IconURL", "IconURL", FORCE_STRING)
AccessorFunc(OPTION, "IconSize", "IconSize", FORCE_NUMBER)
AccessorFunc(OPTION, "SwatchColor", "SwatchColor")
AccessorFunc(OPTION, "Tooltip", "Tooltip", FORCE_STRING)
AccessorFunc(OPTION, "IsDisabled", "IsDisabled", FORCE_BOOL)
AccessorFunc(OPTION, "KeyBind", "KeyBind", FORCE_STRING)

Elib.RegisterFont("UI.MenuOptionV2", "Space Grotesk SemiBold", 18)
Elib.RegisterFont("UI.MenuOptionV2.Keybind", "Space Grotesk", 14)

function OPTION:Init()
	self:SetTextAlign(TEXT_ALIGN_LEFT)
	self:SetFont("UI.MenuOptionV2")
	self:SetChecked(false)
	self:SetIsDisabled(false)
	self:SetIconSize(16)

	self.NormalCol = Elib.Colors.Transparent
	self.HoverCol = Elib.CopyColor(Elib.Colors.Scroller)
	self.HighlightCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)

	self.BackgroundCol = Elib.CopyColor(self.NormalCol)
	self.IsKeyboardFocused = false

	hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function OPTION:UpdateColors()
	self.NormalCol = Elib.Colors.Transparent
	self.HoverCol = Elib.CopyColor(Elib.Colors.Scroller)
	self.HighlightCol = Elib.OffsetColor(Elib.Colors.Scroller, 10)
	self.BackgroundCol = Elib.CopyColor(self.NormalCol)
end

function OPTION:SetIcon() end

function OPTION:SetSubMenu(menu)
	self.SubMenu = menu
end

function OPTION:AddSubMenu()
	local subMenu = vgui.Create("Elib.MenuV2", self)
	subMenu:SetVisible(false)
	subMenu:SetParent(self)

	self:SetSubMenu(subMenu)

	return subMenu
end

function OPTION:OnCursorEntered()
	local parent = self.ParentMenu
	if not IsValid(parent) then parent = self:GetParent() end
	if not IsValid(parent) then return end

	if parent.OpenSubMenu then
		parent:OpenSubMenu(self, self.SubMenu)
	end

	if IsValid(parent) and parent.ClearKeyboardFocus then
		parent:ClearKeyboardFocus()
	end
end

function OPTION:OnCursorExited() end

function OPTION:Paint(w, h)
	if self:GetIsDisabled() then
		Elib.DrawSimpleText(self:GetText(), self:GetFont(), self:_GetTextX(), h / 2, Elib.Colors.DisabledText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	local targetCol = self.NormalCol
	if self.IsKeyboardFocused then
		targetCol = self.HighlightCol
	elseif self:IsHovered() then
		targetCol = self.HoverCol
	end

	self.BackgroundCol = Elib.LerpColor(FrameTime() * 14, self.BackgroundCol, targetCol)

	surface.SetDrawColor(self.BackgroundCol)
	surface.DrawRect(0, 0, w, h)

	local textX = self:_GetTextX()
	local textCol = Elib.Colors.PrimaryText

	local iconURL = self:GetIconURL()
	if iconURL and iconURL ~= "" then
		local iconSz = Elib.Scale(self:GetIconSize())
		local iconY = (h - iconSz) / 2
		Elib.DrawImage(Elib.Scale(8), iconY, iconSz, iconSz, iconURL, textCol)
	end

	local swatch = self:GetSwatchColor()
	if swatch and IsColor(swatch) then
		local swatchSz = Elib.Scale(12)
		local swatchX = w - swatchSz - Elib.Scale(8)
		local swatchY = (h - swatchSz) / 2

		Elib.DrawRoundedBox(Elib.Scale(3), swatchX, swatchY, swatchSz, swatchSz, swatch)

		local borderCol = Elib.OffsetColor(Elib.Colors.Background, 40)
		Elib.DrawRoundedBox(Elib.Scale(3), swatchX, swatchY, swatchSz, swatchSz, borderCol, 1)
	end

	if self:GetIsCheckable() then
		local checkSize = Elib.Scale(14)
		local checkX = w - checkSize - Elib.Scale(8)
		local checkY = (h - checkSize) / 2

		if swatch then
			checkX = checkX - Elib.Scale(20)
		end

		local checkBg = Elib.OffsetColor(Elib.Colors.Background, 20)
		Elib.DrawRoundedBox(Elib.Scale(3), checkX, checkY, checkSize, checkSize, checkBg)

		if self:GetChecked() then
			local innerPad = Elib.Scale(3)
			Elib.DrawRoundedBox(Elib.Scale(2), checkX + innerPad, checkY + innerPad, checkSize - innerPad * 2, checkSize - innerPad * 2, Elib.Colors.Positive)
		end
	end

	Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local keybind = self:GetKeyBind()
	if keybind and keybind ~= "" then
		local kbCol = Elib.Colors.DisabledText
		local rightPad = Elib.Scale(8)

		if swatch then rightPad = rightPad + Elib.Scale(20) end
		if self:GetIsCheckable() then rightPad = rightPad + Elib.Scale(22) end

		Elib.DrawSimpleText(keybind, "UI.MenuOptionV2.Keybind", w - rightPad, h / 2, kbCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	if self.SubMenu then
		local dropBtnSize = Elib.Scale(8)
		Elib.DrawImage(w - dropBtnSize - Elib.Scale(6), h / 2 - dropBtnSize / 2, dropBtnSize, dropBtnSize, "https://pixel-cdn.lythium.dev/i/ce2kyfb88", textCol)
	end
end

function OPTION:_GetTextX()
	local x = Elib.Scale(10)
	local iconURL = self:GetIconURL()
	if iconURL and iconURL ~= "" then
		x = Elib.Scale(10) + Elib.Scale(self:GetIconSize()) + Elib.Scale(6)
	end
	return x
end

function OPTION:OnPressed(mousecode)
	if self:GetIsDisabled() then return end
	self.m_MenuClicking = true
end

function OPTION:OnReleased(mousecode)
	if self:GetIsDisabled() then return end
	if not self.m_MenuClicking and mousecode == MOUSE_LEFT then return end
	self.m_MenuClicking = false

	if self:GetIsCheckable() then return end

	CloseDermaMenus()
end

function OPTION:DoRightClick()
	if self:GetIsDisabled() then return end
	if self:GetIsCheckable() then
		self:ToggleCheck()
	end
end

function OPTION:DoClick()
	if self:GetIsDisabled() then return end

	if self:GetIsCheckable() then
		self:ToggleCheck()
	end
	if self.m_funcCallback then
		self.m_funcCallback(self)
	end

	if self.m_pMenu then
		self.m_pMenu:OptionSelectedInternal(self)
	end
end

function OPTION:SetCallback(func)
	self.m_funcCallback = func
end


function OPTION:DoClickInternal()
	self:DoClick()
end

function OPTION:ToggleCheck()
	self:SetChecked(not self:GetChecked())
	self:OnChecked(self:GetChecked())
end

function OPTION:OnChecked(enabled) end

function OPTION:CalculateWidth()
	Elib.SetFont(self:GetFont())
	local tw = Elib.GetTextSize(self:GetText())
	local extra = Elib.Scale(34)

	local iconURL = self:GetIconURL()
	if iconURL and iconURL ~= "" then
		extra = extra + Elib.Scale(self:GetIconSize()) + Elib.Scale(6)
	end

	local swatch = self:GetSwatchColor()
	if swatch then
		extra = extra + Elib.Scale(20)
	end

	if self:GetIsCheckable() then
		extra = extra + Elib.Scale(22)
	end

	local keybind = self:GetKeyBind()
	if keybind and keybind ~= "" then
		Elib.SetFont("UI.MenuOptionV2.Keybind")
		extra = extra + Elib.GetTextSize(keybind) + Elib.Scale(16)
	end

	return tw + extra
end

function OPTION:PerformLayout(w, h)
	self:SetSize(math.max(self:CalculateWidth(), self:GetWide()), Elib.Scale(32))
end

vgui.Register("Elib.MenuOptionV2", OPTION, "Elib.Button")

local OPTION_CVAR = {}

AccessorFunc(OPTION_CVAR, "ConVar", "ConVar")
AccessorFunc(OPTION_CVAR, "ValueOn", "ValueOn")
AccessorFunc(OPTION_CVAR, "ValueOff", "ValueOff")

function OPTION_CVAR:Init()
	self:SetChecked(false)
	self:SetIsCheckable(true)
	self:SetValueOn("1")
	self:SetValueOff("0")
end

function OPTION_CVAR:Think()
	if not self.ConVar then return end
	self:SetChecked(GetConVar(self.ConVar):GetString() == self.ValueOn)
end

function OPTION_CVAR:OnChecked(checked)
	if not self.ConVar then return end
	RunConsoleCommand(self.ConVar, checked and self.ValueOn or self.ValueOff)
end

vgui.Register("Elib.MenuOptionCVarV2", OPTION_CVAR, "Elib.MenuOptionV2")

local HEADER = {}

Elib.RegisterFont("UI.MenuSectionHeader", "Space Grotesk Bold", 14)

function HEADER:Init()
	self.Text = "Section"
	self:SetMouseInputEnabled(false)
end

function HEADER:SetText(text)
	self.Text = text
end

function HEADER:GetText()
	return self.Text
end

function HEADER:Paint(w, h)
	local lineY = h / 2
	local textW = 0

	Elib.SetFont("UI.MenuSectionHeader")
	textW = Elib.GetTextSize(self.Text)

	local pad = Elib.Scale(8)
	local textX = pad
	local lineCol = Elib.OffsetColor(Elib.Colors.Background, 20)

	Elib.DrawSimpleText(self.Text, "UI.MenuSectionHeader", textX, lineY, Elib.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local lineStart = textX + textW + Elib.Scale(6)
	surface.SetDrawColor(lineCol)
	surface.DrawRect(lineStart, lineY, w - lineStart - pad, 1)
end

function HEADER:PerformLayout(w, h)
	self:SetTall(Elib.Scale(24))
end

vgui.Register("Elib.MenuSectionHeader", HEADER, "Panel")

local PANEL = {}

AccessorFunc(PANEL, "m_bBorder", "DrawBorder")
AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_iMinimumWidth", "MinimumWidth")
AccessorFunc(PANEL, "m_bDrawColumn", "DrawColumn")
AccessorFunc(PANEL, "m_iMaxHeight", "MaxHeight")
AccessorFunc(PANEL, "m_pOpenSubMenu", "OpenSubMenu")
AccessorFunc(PANEL, "AnimateOpen", "AnimateOpen", FORCE_BOOL)
AccessorFunc(PANEL, "CornerRadius", "CornerRadius", FORCE_NUMBER)

function PANEL:Init()
	self:SetIsMenu(true)
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetMinimumWidth(Elib.Scale(120))
	self:SetDrawOnTop(true)
	self:SetMaxHeight(ScrH() * 0.4)
	self:SetDeleteSelf(true)
	self:SetBarDockShouldOffset(true)
	self:SetAnimateOpen(true)
	self:SetCornerRadius(8)

	self:SetPadding(0)

	self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Background, 10)
	self.BorderCol = Elib.OffsetColor(Elib.Colors.Background, 25)

	self.OpenAlpha = 0
	self.OpenScale = 0.95
	self.IsOpening = false

	self.FocusedIndex = 0
	self.NavigableItems = {}

	RegisterDermaMenuForClose(self)

	hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
	self.BackgroundCol = Elib.OffsetColor(Elib.Colors.Background, 10)
	self.BorderCol = Elib.OffsetColor(Elib.Colors.Background, 25)
end

function PANEL:AddPanel(pnl)
	self:AddItem(pnl)
	pnl.ParentMenu = self
end

function PANEL:AddOption(strText, funcFunction)
	local pnl = vgui.Create("Elib.MenuOptionV2", self)
	pnl:SetMenu(self)
	pnl:SetText(strText)
	if funcFunction then pnl:SetCallback(funcFunction) end

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddCVar(strText, convar, on, off, funcFunction)
	local pnl = vgui.Create("Elib.MenuOptionCVarV2", self)
	pnl:SetMenu(self)
	pnl:SetText(strText)
	if funcFunction then pnl:SetCallback(funcFunction) end

	pnl:SetConVar(convar)
	pnl:SetValueOn(on)
	pnl:SetValueOff(off)

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSpacer(text, func)
	local pnl = vgui.Create("Panel", self)

	local spacerCol = Elib.OffsetColor(Elib.Colors.Background, 6)
	pnl.Paint = function(p, w, h)
		surface.SetDrawColor(spacerCol)
		surface.DrawRect(Elib.Scale(8), 0, w - Elib.Scale(16), h)
	end

	pnl:SetTall(Elib.Scale(1))
	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSubMenu(strText, funcFunction)
	local pnl = vgui.Create("Elib.MenuOptionV2", self)
	local subMenu = pnl:AddSubMenu(strText, funcFunction)

	pnl:SetText(strText)
	if funcFunction then pnl.DoClick = funcFunction end

	self:AddPanel(pnl)

	return subMenu, pnl
end

function PANEL:AddIconOption(strText, iconURL, funcFunction)
	local pnl = self:AddOption(strText, funcFunction)
	pnl:SetIconURL(iconURL)
	return pnl
end

function PANEL:AddSectionHeader(strText)
	local pnl = vgui.Create("Elib.MenuSectionHeader", self)
	pnl:SetText(strText)
	self:AddPanel(pnl)
	return pnl
end

function PANEL:AddColorOption(strText, color, funcFunction)
	local pnl = self:AddOption(strText, funcFunction)
	pnl:SetSwatchColor(color)
	return pnl
end

function PANEL:AddDisabledOption(strText)
	local pnl = self:AddOption(strText)
	pnl:SetIsDisabled(true)
	return pnl
end

function PANEL:AddKeybindOption(strText, keybind, funcFunction)
	local pnl = self:AddOption(strText, funcFunction)
	pnl:SetKeyBind(keybind)
	return pnl
end

function PANEL:RebuildNavigableItems()
	self.NavigableItems = {}
	local children = self:GetCanvas():GetChildren()
	for _, child in ipairs(children) do
		if child.DoClick and not (child.GetIsDisabled and child:GetIsDisabled()) then
			table.insert(self.NavigableItems, child)
		end
	end
end

function PANEL:ClearKeyboardFocus()
	for _, item in ipairs(self.NavigableItems) do
		if item.IsKeyboardFocused then
			item.IsKeyboardFocused = false
		end
	end
	self.FocusedIndex = 0
end

function PANEL:SetKeyboardFocus(index)
	self:ClearKeyboardFocus()
	index = math.Clamp(index, 1, #self.NavigableItems)
	self.FocusedIndex = index

	local item = self.NavigableItems[index]
	if IsValid(item) then
		item.IsKeyboardFocused = true

		if self.ScrollToChild then
			self:ScrollToChild(item)
		end
	end
end

function PANEL:OnKeyCodePressed(key)
	if key == KEY_ESCAPE then
		CloseDermaMenus()
		return
	end

	if #self.NavigableItems == 0 then
		self:RebuildNavigableItems()
	end

	if #self.NavigableItems == 0 then return end

	if key == KEY_DOWN then
		local newIdx = self.FocusedIndex + 1
		if newIdx > #self.NavigableItems then newIdx = 1 end
		self:SetKeyboardFocus(newIdx)
	elseif key == KEY_UP then
		local newIdx = self.FocusedIndex - 1
		if newIdx < 1 then newIdx = #self.NavigableItems end
		self:SetKeyboardFocus(newIdx)
	elseif key == KEY_ENTER then
		if self.FocusedIndex > 0 then
			local item = self.NavigableItems[self.FocusedIndex]
			if IsValid(item) and item.DoClick then
				item:DoClick()
			end
		end
	end
end

function PANEL:Hide()
	local openmenu = self:GetOpenSubMenu()
	if openmenu then
		openmenu:Hide()
	end

	self:SetVisible(false)
	self:SetOpenSubMenu(nil)
end

function PANEL:OpenSubMenu(item, menu)
	local openmenu = self:GetOpenSubMenu()
	if IsValid(openmenu) and openmenu:IsVisible() then
		if menu and openmenu == menu then return end
		self:CloseSubMenu(openmenu)
	end

	if not IsValid(menu) then return end

	local x, y = item:LocalToScreen(self:GetWide(), 0)
	menu:Open(x, y, false, item)

	self:SetOpenSubMenu(menu)
end

function PANEL:CloseSubMenu(menu)
	menu:Hide()
	self:SetOpenSubMenu(nil)
end

function PANEL:Paint(w, h)
	local radius = Elib.Scale(self:GetCornerRadius())

	local shadowAlpha = 30
	Elib.DrawRoundedBox(radius + 1, -2, -1, w + 4, h + 4, Color(0, 0, 0, shadowAlpha))

	Elib.DrawRoundedBox(radius, 0, 0, w, h, self.BackgroundCol)

	if self:GetDrawBorder() then
		Elib.DrawRoundedBox(radius, 0, 0, w, h, self.BorderCol, 1)
	end
end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild(num)
	return self:GetCanvas():GetChildren()[num]
end

function PANEL:LayoutContent(w, h)
	w = self:GetMinimumWidth()

	local children = self:GetCanvas():GetChildren()
	for k, pnl in pairs(children) do
		pnl:InvalidateLayout(true)
		w = math.max(w, pnl:GetWide())
	end

	self:SetWide(w)

	local padding = Elib.Scale(4)
	local y = padding
	for k, pnl in pairs(children) do
		pnl:SetWide(w)
		pnl:SetPos(0, y)
		pnl:InvalidateLayout(true)

		y = y + pnl:GetTall()
	end

	y = y + padding
	y = math.min(y, self:GetMaxHeight())

	self:SetTall(y)

	local overlap = select(2, self:LocalToScreen(0, y)) - ScrH()
	if overlap > 0 then
		self:SetPos(self:GetPos(), select(2, self:GetPos()) - overlap)
	end

	self:RebuildNavigableItems()
end

function PANEL:Open(x, y, skipanimation, ownerpanel)
	RegisterDermaMenuForClose(self)

	local manual = x and y
	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local ownerHeight = 0
	if ownerpanel then ownerHeight = ownerpanel:GetTall() end

	self:InvalidateLayout(true)

	local w, h = self:GetWide(), self:GetTall()
	self:SetSize(w, h)

	if y + h > ScrH() then y = ((manual and ScrH()) or (y + ownerHeight)) - h end
	if x + w > ScrW() then x = ((manual and ScrW()) or x) - w end
	if y < 1 then y = 1 end
	if x < 1 then x = 1 end

	self:SetPos(x, y)

	self:MakePopup()
	self:SetVisible(true)
	self:SetKeyboardInputEnabled(true)

	if self:GetAnimateOpen() and not skipanimation then
		self:SetAlpha(0)
		self:AlphaTo(255, 0.12, 0)
	end

	self.FocusedIndex = 0
end

function PANEL:OptionSelectedInternal(option)
	self:OptionSelected(option, option:GetText())
end

function PANEL:OptionSelected(option, text) end

function PANEL:ClearHighlights()
	for k, pnl in pairs(self:GetCanvas():GetChildren()) do
		pnl.Highlight = nil
	end
end

function PANEL:HighlightItem(item)
	for k, pnl in pairs(self:GetCanvas():GetChildren()) do
		if pnl == item then
			pnl.Highlight = true
		end
	end
end

vgui.Register("Elib.MenuV2", PANEL, "Elib.ScrollPanel")


function Elib.UseMenuV2()
	-- Store originals
	Elib._OriginalMenu = Elib._OriginalMenu or "Elib.Menu"
	Elib._OriginalMenuOption = Elib._OriginalMenuOption or "Elib.MenuOption"
	Elib._OriginalMenuOptionCVar = Elib._OriginalMenuOptionCVar or "Elib.MenuOptionCVar"

	-- alis them
	local menuV2 = vgui.GetControlTable("Elib.MenuV2")
	local optionV2 = vgui.GetControlTable("Elib.MenuOptionV2")
	local optionCVarV2 = vgui.GetControlTable("Elib.MenuOptionCVarV2")

	if menuV2 then
		vgui.Register("Elib.Menu", menuV2, "Elib.ScrollPanel")
	end
	if optionV2 then
		vgui.Register("Elib.MenuOption", optionV2, "Elib.Button")
	end
	if optionCVarV2 then
		vgui.Register("Elib.MenuOptionCVar", optionCVarV2, "Elib.MenuOptionV2")
	end

	Elib.MenuV2Active = true
end

--- Revert to the original menu panels.
function Elib.UseMenuV1()
	if not Elib._OriginalMenu then return end

	Elib.MenuV2Active = false
end

-- testing
concommand.Add("elib_menu_v2_test", function()

	if IsValid(Elib._MenuV2TestFrame) then
		Elib._MenuV2TestFrame:Remove()
	end

	local frame = vgui.Create("Elib.Frame")
	frame:SetTitle("Menu V2 Playground")
	frame:SetSize(Elib.Scale(520), Elib.Scale(500))
	frame:Center()
	frame:SetSizable(true)
	frame:SetMinWidth(Elib.Scale(420))
	frame:SetMinHeight(Elib.Scale(400))
	frame:MakePopup()
	Elib._MenuV2TestFrame = frame

	local scroll = vgui.Create("Elib.ScrollPanel", frame)
	scroll:Dock(FILL)
	scroll:DockMargin(0, Elib.Scale(42), 0, 0)

	local pad = Elib.Scale(10)
	scroll:GetCanvas():DockPadding(pad, pad, pad, pad)

	local state = {
		showIcons      = true,
		showKeybinds   = true,
		showSwatches   = true,
		showSections   = true,
		showDisabled   = true,
		showCheckable  = true,
		showSubmenu    = true,
		animateOpen    = true,
		cornerRadius   = 8,
		minWidth       = 120,
	}

	local function AddSectionLabel(parent, text)
		local lbl = vgui.Create("DPanel", parent)
		lbl:Dock(TOP)
		lbl:DockMargin(0, Elib.Scale(8), 0, Elib.Scale(4))
		lbl:SetTall(Elib.Scale(22))
		lbl.Paint = function(s, w, h)
			Elib.DrawSimpleText(text, "UI.MenuOptionV2", Elib.Scale(2), h / 2, Elib.Colors.Primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Elib.OffsetColor(Elib.Colors.Background, 20))
			surface.DrawRect(0, h - 1, w, 1)
		end
		return lbl
	end

	local function AddToggleRow(parent, text, key)
		local row = vgui.Create("DPanel", parent)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, Elib.Scale(2))
		row:SetTall(Elib.Scale(28))
		row.Paint = function() end

		local toggle = vgui.Create("Elib.LabelledCheckbox", row)
		toggle:Dock(FILL)
		toggle:SetText(text)
		toggle:SetToggle(state[key])
		toggle.OnToggled = function(s, val)
			state[key] = val
		end

		return row
	end

	local function AddSliderRow(parent, text, key, minVal, maxVal)
		local row = vgui.Create("DPanel", parent)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, Elib.Scale(4))
		row:SetTall(Elib.Scale(32))
		row.Paint = function() end

		local lbl = vgui.Create("DPanel", row)
		lbl:Dock(LEFT)
		lbl:SetWide(Elib.Scale(130))
		lbl.Paint = function(s, w, h)
			Elib.DrawSimpleText(text .. ": " .. tostring(state[key]), "UI.Toast.Body", Elib.Scale(2), h / 2, Elib.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local slider = vgui.Create("Elib.Slider", row)
		slider:Dock(FILL)
		slider:DockMargin(Elib.Scale(4), Elib.Scale(6), Elib.Scale(4), Elib.Scale(6))

		local range = maxVal - minVal
		slider.Fraction = (state[key] - minVal) / range

		slider.OnValueChanged = function(s, fraction)
			state[key] = math.Round(minVal + fraction * range)
		end

		return row
	end

	AddSectionLabel(scroll, "Features to show")

	AddToggleRow(scroll, "Icon options",      "showIcons")
	AddToggleRow(scroll, "Keybind hints",     "showKeybinds")
	AddToggleRow(scroll, "Color swatches",    "showSwatches")
	AddToggleRow(scroll, "Section headers",   "showSections")
	AddToggleRow(scroll, "Disabled option",   "showDisabled")
	AddToggleRow(scroll, "Checkable options", "showCheckable")
	AddToggleRow(scroll, "Submenu",           "showSubmenu")
	AddToggleRow(scroll, "Animate open",      "animateOpen")

	AddSectionLabel(scroll, "Properties")

	AddSliderRow(scroll, "Corner radius",  "cornerRadius", 0, 16)
	AddSliderRow(scroll, "Min width",      "minWidth",     80, 300)

	local spacer = vgui.Create("DPanel", scroll)
	spacer:Dock(TOP)
	spacer:SetTall(Elib.Scale(10))
	spacer.Paint = function() end

	local openBtn = vgui.Create("Elib.TextButton", scroll)
	openBtn:Dock(TOP)
	openBtn:DockMargin(Elib.Scale(40), Elib.Scale(4), Elib.Scale(40), Elib.Scale(4))
	openBtn:SetTall(Elib.Scale(36))
	openBtn:SetText("Open Menu V2")

	openBtn.DoClick = function()
		local menu = vgui.Create("Elib.MenuV2")
		menu:SetAnimateOpen(state.animateOpen)
		menu:SetCornerRadius(state.cornerRadius)
		menu:SetMinimumWidth(Elib.Scale(state.minWidth))

		if state.showIcons then
			if state.showSections then menu:AddSectionHeader("File") end

			menu:AddIconOption("Save", "https://construct-cdn.physgun.com/images/2b2f5ea0-3cb3-4207-82db-bb8484da738a.png", function()
				Elib.Toast("Save clicked!", "success")
			end)
			menu:AddIconOption("Open", "https://construct-cdn.physgun.com/images/ab014fa0-a7fe-4ba2-b822-3254ce3108fc.png", function()
				Elib.Toast("Open clicked!", "info")
			end)
			menu:AddSpacer()
		end

		if state.showKeybinds then
			if state.showSections then menu:AddSectionHeader("Edit") end

			menu:AddKeybindOption("Copy", "Ctrl+C", function()
				Elib.Toast("Copied to clipboard!", "success")
			end)
			menu:AddKeybindOption("Paste", "Ctrl+V", function()
				Elib.Toast("Pasted from clipboard!", "info")
			end)
			menu:AddKeybindOption("Undo", "Ctrl+Z", function()
				Elib.Toast("Undo!", "warning")
			end)
			menu:AddSpacer()
		end

		if state.showSwatches then
			if state.showSections then menu:AddSectionHeader("Themes") end

			for _, name in ipairs({"Default", "Blue", "Green", "Purple", "Orange", "Arctic Neon", "Bloodsteel"}) do
				local theme = Elib.Themes[name]
				if theme then
					menu:AddColorOption(name, theme.Primary, function()
						Elib.SetTheme(name)
						Elib.Toast("Theme → " .. name, "success")
					end)
				end
			end
			menu:AddSpacer()
		end

		if state.showCheckable then
			if state.showSections then menu:AddSectionHeader("Options") end

			local opt1 = menu:AddOption("Show HUD")
			opt1:SetIsCheckable(true)
			opt1:SetChecked(true)
			opt1:SetCallback(function()
				Elib.Toast("HUD: " .. (opt1:GetChecked() and "ON" or "OFF"), "info")
			end)

			local opt2 = menu:AddOption("God Mode")
			opt2:SetIsCheckable(true)
			opt2:SetCallback(function()
				Elib.Toast("God: " .. (opt2:GetChecked() and "ON" or "OFF"), "info")
			end)

			local opt3 = menu:AddOption("Noclip")
			opt3:SetIsCheckable(true)
			opt3:SetCallback(function()
				Elib.Toast("Noclip: " .. (opt3:GetChecked() and "ON" or "OFF"), "info")
			end)

			menu:AddSpacer()
		end

		if state.showDisabled then
			menu:AddDisabledOption("Premium Only")
		end

		if state.showSubmenu then
			if state.showSections then menu:AddSectionHeader("Advanced") end

			local sub, _ = menu:AddSubMenu("Render Settings")
			sub:AddOption("Low", function() Elib.Toast("Render: Low", "info") end)
			sub:AddOption("Medium", function() Elib.Toast("Render: Medium", "info") end)
			sub:AddOption("High", function() Elib.Toast("Render: High", "info") end)
			sub:AddSpacer()
			sub:AddOption("Ultra", function() Elib.Toast("Render: Ultra", "success") end)

			local sub2, _ = menu:AddSubMenu("Audio Settings")
			sub2:AddOption("Mute All", function() Elib.Toast("Audio: Muted", "warning") end)
			sub2:AddOption("50%", function() Elib.Toast("Audio: 50%", "info") end)
			sub2:AddOption("100%", function() Elib.Toast("Audio: 100%", "info") end)
		end


		menu:AddSpacer()
		menu:AddOption("Close", function() end)

		menu:Open()
	end

	local hint = vgui.Create("DPanel", scroll)
	hint:Dock(TOP)
	hint:DockMargin(0, Elib.Scale(6), 0, 0)
	hint:SetTall(Elib.Scale(20))
	hint.Paint = function(s, w, h)
		Elib.DrawSimpleText("Toggle features above, then click the button or right-click anywhere in this window.", "UI.Toast.Body", w / 2, h / 2, Elib.Colors.DisabledText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local oldPressed = frame.OnMousePressed
	frame.OnMousePressed = function(self2, mc)
		if mc == MOUSE_RIGHT then
			openBtn:DoClick()
			return
		end
		if oldPressed then return oldPressed(self2, mc) end
	end
end)