Elib.RegisterFont("UI.Tooltip.Title", "Space Grotesk Bold", 15)
Elib.RegisterFont("UI.Tooltip.Body", "Space Grotesk", 14)

local TOOLTIP_MAX_WIDTH = 260
local TOOLTIP_PADDING   = 8
local TOOLTIP_OFFSET_X  = 14
local TOOLTIP_OFFSET_Y  = 18
local TOOLTIP_DELAY     = 0.35   -- seconds before showing
local TOOLTIP_FADE_IN   = 0.18
local TOOLTIP_FADE_OUT  = 0.12

local registeredTooltips = {}
local activeTooltip = nil
local hoverStart = 0
local lastPanel = nil

-- Animation state
local animState = {
	alpha     = 0,
	scale     = 0.85,
	posX      = 0,
	posY      = 0,
	targetX   = 0,
	targetY   = 0,
	showing   = false,
	anchorDir = "below",
	firstFrame = true,
	slideOffset = 0,
}

local ANIM_PRESETS = {
	fade = {
		fadeIn      = 0.18,
		fadeOut     = 0.12,
		scaleFrom   = 1,
		scaleTo     = 1,
		slideOffset = 0,
		overshoot   = 0,
		posSmoothing = 12,
	},
	slide = {
		fadeIn      = 0.20,
		fadeOut     = 0.10,
		scaleFrom   = 1,
		scaleTo     = 1,
		slideOffset = 8,     -- pixels to slide from
		overshoot   = 0,
		posSmoothing = 10,
	},
	none = {
		fadeIn      = 0,
		fadeOut     = 0,
		scaleFrom   = 1,
		scaleTo     = 1,
		slideOffset = 0,
		overshoot   = 0,
		posSmoothing = 999,
	},
}

local defaultPreset = "fade"

local function GetPreset(data)
	local name = data and data.animation or defaultPreset
	return ANIM_PRESETS[name] or ANIM_PRESETS[defaultPreset]
end

local function EaseOutBack(t, overshoot)
	overshoot = overshoot or 1.70158
	local t1 = t - 1
	return t1 * t1 * ((overshoot + 1) * t1 + overshoot) + 1
end

local function EaseOutCubic(t)
	local t1 = t - 1
	return t1 * t1 * t1 + 1
end

local function EaseInCubic(t)
	return t * t * t
end

function Elib.SetTooltip(panel, data, delay)
	if not IsValid(panel) then return end

	if isstring(data) then
		data = { body = data }
	end

	registeredTooltips[panel] = {
		title           = data.title,
		body            = data.body or "",
		icon            = data.icon,
		delay           = delay or data.delay or TOOLTIP_DELAY,
		animation       = data.animation,
		titleEffect     = data.titleEffect,
		titleEffectOpts = data.titleEffectOpts,
		bodyEffect      = data.bodyEffect,
		bodyEffectOpts  = data.bodyEffectOpts,
	}

	local oldRemove = panel.OnRemove
	panel.OnRemove = function(self, ...)
		registeredTooltips[self] = nil
		if lastPanel == self then
			lastPanel = nil
			activeTooltip = nil
		end
		if oldRemove then return oldRemove(self, ...) end
	end
end

function Elib.RemoveTooltip(panel)
	registeredTooltips[panel] = nil
	if lastPanel == panel then
		lastPanel = nil
		activeTooltip = nil
	end
end

function Elib.HasTooltip(panel)
	return registeredTooltips[panel] ~= nil
end


local function ComputeTooltipSize(data)
	local maxW = Elib.Scale(TOOLTIP_MAX_WIDTH)
	local pad = Elib.Scale(TOOLTIP_PADDING)
	local innerW = maxW - pad * 2

	local hasIcon = data.icon and data.icon ~= ""
	local iconSz = Elib.Scale(16)
	local textAreaW = innerW
	if hasIcon then
		textAreaW = textAreaW - iconSz - Elib.Scale(6)
	end

	local totalH = pad
	local actualW = 0

	if data.title and data.title ~= "" then
		Elib.SetFont("UI.Tooltip.Title")
		local tw = Elib.GetTextSize(data.title)
		local _, th = Elib.GetTextSize("Tg")
		actualW = math.max(actualW, tw)
		totalH = totalH + th + Elib.Scale(3)
	end

	if data.body and data.body ~= "" then
		local wrappedBody = Elib.WrapText(data.body, textAreaW, "UI.Tooltip.Body")
		data._wrappedBody = wrappedBody

		Elib.SetFont("UI.Tooltip.Body")
		local _, lineH = Elib.GetTextSize("Tg")
		local lines = 1
		for _ in wrappedBody:gmatch("\n") do
			lines = lines + 1
		end

		for line in (wrappedBody .. "\n"):gmatch("(.-)\n") do
			local lw = Elib.GetTextSize(line)
			actualW = math.max(actualW, lw)
		end

		totalH = totalH + lineH * lines
	end

	totalH = totalH + pad

	if hasIcon then
		actualW = actualW + iconSz + Elib.Scale(6)
	end

	local finalW = math.min(actualW + pad * 2, maxW)
	finalW = math.max(finalW, Elib.Scale(60))

	return finalW, totalH
end

local function FindHoveredTooltipPanel()
	if not vgui.CursorVisible() then return nil end

	local pnl = vgui.GetHoveredPanel()
	local check = pnl
	local depth = 0

	while IsValid(check) and depth < 10 do
		if registeredTooltips[check] then
			return check
		end
		check = check:GetParent()
		depth = depth + 1
	end

	return nil
end

local function DrawEffectText(effectName, text, font, x, y, color, alpha, opts)
	opts = opts or {}

	local ct = CurTime()
	local rt = RealTime()
	local col = Color(color.r, color.g, color.b, alpha)

	if not effectName or effectName == "" or effectName == "none" then
		surface.SetFont(font)
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		surface.SetTextPos(x, y)
		surface.DrawText(text)
		return
	end

    -- ifthen elseif then elseif then elseif then... you get the idea :D
	if effectName == "shaking" then
		Elib.DrawShakingText(text, font, x, y, col, ct * (opts.speed or 1.8), opts.intensity or 1.05)

	elseif effectName == "waving" then
		Elib.DrawWavingText(text, font, x, y, col, ct, opts.intensity or 3)

	elseif effectName == "ripple" then
		Elib.DrawIteratingHorizontalRippleText(text, font, x, y, col, ct, opts.amplitude or 3, opts.speed or 5, opts.wavelength or 0.5)

	elseif effectName == "glowing" then
		Elib.DrawGlowingText(opts.static or false, text, font, x, y, col)

	elseif effectName == "chromatic" then
		Elib.DrawChromaticAberrationText(text, font, x, y, opts.intensity or 2, ct, opts.speed or 5)

	elseif effectName == "glitch" then
		Elib.DrawGlitchText(text, font, x, y, col, ct, opts.speed or 15, opts.intensity or 0.15)

	elseif effectName == "chromatic_glitch" then
		Elib.DrawChromaticGlitchText(text, font, x, y, ct, opts.chromaIntensity or 2, opts.glitchSpeed or 15, opts.glitchIntensity or 0.15, opts.chromaSpeed or 5)

	elseif effectName == "pulse" then
		local col2 = opts.color2 or Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, alpha)
		Elib.DrawColorPulseText(text, font, x, y, col, col2, ct, opts.speed or 2)

	elseif effectName == "fade" then
		Elib.DrawFadeText(text, font, x, y, col, ct, opts.speed or 2)

	elseif effectName == "blink" then
		Elib.DrawBlinkingText(text, font, x, y, col, ct, opts.speed or 2, opts.dutyCycle or 0.5)

	elseif effectName == "jitter" then
		Elib.DrawControlledJitterText(text, font, x, y, col, ct, opts.chance or 0.2, opts.duration or 0.15, opts.magnitude or 1.5)

	elseif effectName == "flicker" then
		Elib.DrawControlledFlickerText(text, font, x, y, col, ct, opts.chance or 0.3, opts.duration or 0.15)

	else
		surface.SetFont(font)
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		surface.SetTextPos(x, y)
		surface.DrawText(text)
	end
end


local function CreateOverlayPanel()
	if IsValid(Elib.TooltipOverlay) then
		Elib.TooltipOverlay:Remove()
	end

	local overlay = vgui.Create("DPanel")
	overlay:SetParent(vgui.GetWorldPanel())
	overlay:SetDrawOnTop(true)
	overlay:SetMouseInputEnabled(false)
	overlay:SetKeyboardInputEnabled(false)
	overlay:SetPaintBackgroundEnabled(false)
	overlay:SetPaintBorderEnabled(false)
	overlay:NoClipping(true)

	overlay:SetPos(0, 0)
	overlay:SetSize(0, 0)
	overlay:SetVisible(true)

	function overlay:Think()
		local dt = FrameTime()
		local now = RealTime()

		local hoveredPanel = FindHoveredTooltipPanel()

		if hoveredPanel ~= lastPanel then
			lastPanel = hoveredPanel
			hoverStart = now

			if hoveredPanel then
				activeTooltip = nil
				animState.firstFrame = true
			end
		end

		local shouldShow = false
		if IsValid(hoveredPanel) and registeredTooltips[hoveredPanel] then
			local data = registeredTooltips[hoveredPanel]
			local delay = data.delay or TOOLTIP_DELAY

			if now - hoverStart >= delay then
				shouldShow = true
				activeTooltip = data
			end
		end

		local preset = GetPreset(activeTooltip)

		if shouldShow then
			animState.showing = true

			local fadeIn = preset.fadeIn
			if fadeIn <= 0 then
				animState.alpha = 1
			else
				animState.alpha = math.Approach(animState.alpha, 1, dt / fadeIn)
			end
		else
			animState.showing = false

			local fadeOut = preset.fadeOut
			if fadeOut <= 0 then
				animState.alpha = 0
			else
				animState.alpha = math.Approach(animState.alpha, 0, dt / fadeOut)
			end
		end

		if animState.alpha <= 0 then
			activeTooltip = nil
			animState.scale = preset.scaleFrom
			animState.slideOffset = Elib.Scale(preset.slideOffset)
			animState.firstFrame = true
			self:SetSize(0, 0)
			return
		end

		if not activeTooltip then
			self:SetSize(0, 0)
			return
		end

		local tipW, tipH = ComputeTooltipSize(activeTooltip)

		local mx, my = gui.MouseX(), gui.MouseY()
		local offsetX = Elib.Scale(TOOLTIP_OFFSET_X)
		local offsetY = Elib.Scale(TOOLTIP_OFFSET_Y)

		local rawX = mx + offsetX
		local rawY = my + offsetY

		local scrW, scrH = ScrW(), ScrH()

		if rawX + tipW > scrW - 4 then
			rawX = mx - tipW - Elib.Scale(4)
		end

		local anchorDir = "below"
		if rawY + tipH > scrH - 4 then
			rawY = my - tipH - Elib.Scale(4)
			anchorDir = "above"
		end

		rawX = math.max(rawX, 4)
		rawY = math.max(rawY, 4)

		animState.targetX = rawX
		animState.targetY = rawY
		animState.anchorDir = anchorDir

		if animState.firstFrame then
			animState.posX = rawX
			animState.posY = rawY
			animState.scale = preset.scaleFrom
			animState.slideOffset = Elib.Scale(preset.slideOffset)
			animState.firstFrame = false
		end

		local smoothing = preset.posSmoothing
		animState.posX = Lerp(dt * smoothing, animState.posX, animState.targetX)
		animState.posY = Lerp(dt * smoothing, animState.posY, animState.targetY)

		local targetScale = preset.scaleTo
		local overshoot = preset.overshoot
		if overshoot > 0 and animState.showing then
			local scaleProgress = animState.alpha
			local easedScale = EaseOutBack(scaleProgress, overshoot * 20)
			animState.scale = Lerp(easedScale, preset.scaleFrom, targetScale)
		else
			animState.scale = Lerp(animState.alpha, preset.scaleFrom, targetScale)
		end

		if animState.slideOffset ~= 0 then
			animState.slideOffset = Lerp(dt * smoothing, animState.slideOffset, 0)
			if math.abs(animState.slideOffset) < 0.5 then
				animState.slideOffset = 0
			end
		end

		local extraMargin = Elib.Scale(20)
		self:SetPos(animState.posX - extraMargin, animState.posY - extraMargin)
		self:SetSize(tipW + extraMargin * 2, tipH + extraMargin * 2)
	end

	function overlay:Paint(w, h)
		if animState.alpha <= 0 or not activeTooltip then return end

		local data = activeTooltip
		local preset = GetPreset(data)
		local extraMargin = Elib.Scale(20)

		local baseX = extraMargin
		local baseY = extraMargin

		local slideDir = animState.anchorDir == "above" and 1 or -1
		baseY = baseY + animState.slideOffset * slideDir

		local tipW, tipH = ComputeTooltipSize(data)

		local alpha = 255 * EaseOutCubic(animState.alpha)
		local scale = animState.scale
		local pad = Elib.Scale(TOOLTIP_PADDING)
		local cornerR = Elib.Scale(5)

		if scale ~= 1 then
			local mat = Matrix()
			local cx = baseX + tipW * 0.5
			local cy = baseY + tipH * 0.5
			mat:Translate(Vector(cx, cy, 0))
			mat:Scale(Vector(scale, scale, 1))
			mat:Translate(Vector(-cx, -cy, 0))
			cam.PushModelMatrix(mat, true)
		end

		local shadowA = math.min(alpha * 0.2, 50)
		Elib.DrawRoundedBox(cornerR + 1, baseX + 1, baseY + 2, tipW, tipH, Color(0, 0, 0, shadowA))

		local bgCol = Elib.OffsetColor(Elib.Colors.Background, 18)
		Elib.DrawRoundedBox(cornerR, baseX, baseY, tipW, tipH, Color(bgCol.r, bgCol.g, bgCol.b, alpha))

		local borderCol = Elib.OffsetColor(Elib.Colors.Background, 32)
		Elib.DrawOutlinedRoundedBox(cornerR, baseX, baseY, tipW, tipH, Color(borderCol.r, borderCol.g, borderCol.b, alpha * 0.4), 1)

		local contentX = baseX + pad
		local contentY = baseY + pad

		local hasIcon = data.icon and data.icon ~= ""
		local iconSz = Elib.Scale(16)

		if hasIcon then
			local iconY = baseY + (tipH - iconSz) / 2
			local iconCol = Color(Elib.Colors.PrimaryText.r, Elib.Colors.PrimaryText.g, Elib.Colors.PrimaryText.b, alpha)
			Elib.DrawImage(contentX, iconY, iconSz, iconSz, data.icon, iconCol)
			contentX = contentX + iconSz + Elib.Scale(6)
		end

		local ct = CurTime()
		local rt = RealTime()

		if data.title and data.title ~= "" then
			local titleCol = Color(Elib.Colors.PrimaryText.r, Elib.Colors.PrimaryText.g, Elib.Colors.PrimaryText.b, alpha)
			local titleFont = Elib.GetRealFont("UI.Tooltip.Title") or "UI.Tooltip.Title"

			DrawEffectText(data.titleEffect, data.title, titleFont, contentX, contentY, titleCol, alpha, data.titleEffectOpts)

			Elib.SetFont("UI.Tooltip.Title")
			local _, titleH = Elib.GetTextSize("Tg")
			contentY = contentY + titleH + Elib.Scale(3)
		end

		local bodyText = data._wrappedBody or data.body or ""
		if bodyText ~= "" then
			local bodyCol = Color(Elib.Colors.SecondaryText.r, Elib.Colors.SecondaryText.g, Elib.Colors.SecondaryText.b, alpha)
			local bodyFont = Elib.GetRealFont("UI.Tooltip.Body") or "UI.Tooltip.Body"

			if data.bodyEffect then
				Elib.SetFont("UI.Tooltip.Body")
				local _, lineH = Elib.GetTextSize("Tg")
				local lineY = contentY

				for line in (bodyText .. "\n"):gmatch("(.-)\n") do --fun fact, I forgot the \ here and wondered why it wasn't working for like an hour... so if you're seeing this... shurrup.
					if line ~= "" then
						DrawEffectText(data.bodyEffect, line, bodyFont, contentX, lineY, bodyCol, alpha, data.bodyEffectOpts)
					end
					lineY = lineY + lineH
				end
			else
				Elib.DrawText(bodyText, "UI.Tooltip.Body", contentX, contentY, bodyCol)
			end
		end

		if scale ~= 1 then
			cam.PopModelMatrix()
		end
	end

	Elib.TooltipOverlay = overlay
	return overlay
end

function Elib.SetTooltipAnimation(presetName)
	if ANIM_PRESETS[presetName] then
		defaultPreset = presetName
	end
end

function Elib.GetTooltipAnimation()
	return defaultPreset
end

function Elib.RegisterTooltipAnimation(name, config)
	ANIM_PRESETS[name] = {
		fadeIn       = config.fadeIn or 0.18,
		fadeOut      = config.fadeOut or 0.12,
		scaleFrom    = config.scaleFrom or 1,
		scaleTo      = config.scaleTo or 1,
		slideOffset  = config.slideOffset or 0,
		overshoot    = config.overshoot or 0,
		posSmoothing = config.posSmoothing or 12,
	}
end

-- Create immediately because shit does won't show. (took me too long to realise this fucking happened...)
if IsValid(LocalPlayer()) then
	timer.Simple(0, CreateOverlayPanel)
end

-- also??? well... obviously but ya know...
hook.Add("InitPostEntity", "Elib.Tooltip.Init", function()
	timer.Simple(0, CreateOverlayPanel)
end)

-- safety because someone obviously fucked around
hook.Add("OnScreenSizeChanged", "Elib.Tooltip.RecreateOverlay", function()
	timer.Simple(0, CreateOverlayPanel)
end)

-- hacky, bad but fixes shit...
hook.Add("Think", "Elib.Tooltip.EnsureOverlay", function()
	if not IsValid(Elib.TooltipOverlay) then
		CreateOverlayPanel()
	end

	-- stop using this fucking hook once we confirm its valid... I WILL NOT HAVE LUA ERRORS!!!!!! fuck your perofmrnace.
	if IsValid(Elib.TooltipOverlay) then
		hook.Remove("Think", "Elib.Tooltip.EnsureOverlay")
	end
end)

timer.Create("Elib.Tooltip.Cleanup", 5, 0, function()
	for panel, _ in pairs(registeredTooltips) do
		if not IsValid(panel) then
			registeredTooltips[panel] = nil
		end
	end
end)

hook.Add("VGUICreated", "Elib.Tooltip.AutoRegister", function(name, panel)
	if not panel then return end

	timer.Simple(0, function()
		if not IsValid(panel) then return end

		if panel.GetTooltip and isfunction(panel.GetTooltip) then
			local tip = panel:GetTooltip()
			if tip and tip ~= "" then
				Elib.SetTooltip(panel, tip)
			end
		end
	end)
end)

local panelMeta = FindMetaTable("Panel")
if panelMeta then
	function panelMeta:SetElibTooltip(data, delay)
		Elib.SetTooltip(self, data, delay)
		return self
	end

	function panelMeta:RemoveElibTooltip()
		Elib.RemoveTooltip(self)
		return self
	end
end

concommand.Add("elib_tooltip_test", function()
	local frame = vgui.Create("Elib.Frame")
	frame:SetTitle("Animated Tooltip Test")
	frame:SetSize(Elib.Scale(520), Elib.Scale(580))
	frame:Center()
	frame:MakePopup()

	local scroll = vgui.Create("Elib.ScrollPanel", frame)
	scroll:Dock(FILL)
	scroll:DockMargin(0, Elib.Scale(42), 0, 0)

	local pad = Elib.Scale(10)
	scroll:GetCanvas():DockPadding(pad, pad, pad, pad)

	local function SectionLabel(text)
		local lbl = vgui.Create("DPanel", scroll)
		lbl:Dock(TOP)
		lbl:SetTall(Elib.Scale(24))
		lbl:DockMargin(0, Elib.Scale(8), 0, Elib.Scale(4))
		lbl.Paint = function(s, w, h)
			Elib.DrawSimpleText(text, "UI.FrameTitle", 0, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	-- Entrance Animations
	SectionLabel("Entrance Animations")

	local entranceTooltips = {
		{"Fade", {body = "Simple alpha fade.", animation = "fade"}},
		{"Slide", {body = "Slides in vertically.", animation = "slide"}},
		{"Instant", {body = "No animation at all.", animation = "none"}},
	}

	for _, entry in ipairs(entranceTooltips) do
		local btn = vgui.Create("Elib.TextButton", scroll)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, Elib.Scale(3))
		btn:SetTall(Elib.Scale(32))
		btn:SetText(entry[1])
		btn:SetElibTooltip(entry[2])
	end

	-- Text Effects on Title
	SectionLabel("Title Text Effects")

	local titleEffects = {
		{"Shaking Title", {title = "DANGER!", body = "The title is shaking.", titleEffect = "shaking"}},
		{"Waving Title", {title = "Hello World", body = "The title waves gently.", titleEffect = "waving"}},
		{"Glowing Title", {title = "Legendary Item", body = "A radiant golden glow.", titleEffect = "glowing", titleEffectOpts = {static = true}}},
		{"Glitching Title", {title = "SYSTEM ERROR", body = "Something went wrong.", titleEffect = "glitch", titleEffectOpts = {speed = 20, intensity = 0.3}}},
		{"Chromatic Title", {title = "RGB SHIFT", body = "Color channel separation.", titleEffect = "chromatic", titleEffectOpts = {intensity = 2, speed = 8}}},
		{"Pulsing Title", {title = "LIVE NOW", body = "Pulsing between two colors.", titleEffect = "pulse", titleEffectOpts = {speed = 3, color2 = Color(255, 80, 80)}}},
	}

	for _, entry in ipairs(titleEffects) do
		local btn = vgui.Create("Elib.TextButton", scroll)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, Elib.Scale(3))
		btn:SetTall(Elib.Scale(32))
		btn:SetText(entry[1])
		btn:SetElibTooltip(entry[2])
	end

	-- Text Effects on Body
	SectionLabel("Body Text Effects")

	local bodyEffects = {
		{"Waving Body", {title = "Ocean", body = "The text flows like water.", bodyEffect = "waving", bodyEffectOpts = {intensity = 3}}},
		{"Shaking Body", {title = "Earthquake", body = "Everything is trembling!", bodyEffect = "shaking", bodyEffectOpts = {intensity = 1.5}}},
		{"Ripple Body", {body = "Horizontal ripple distortion.", bodyEffect = "ripple", bodyEffectOpts = {amplitude = 3, speed = 4}}},
		{"Blinking Body", {title = "Alert", body = "This text blinks on and off.", bodyEffect = "blink", bodyEffectOpts = {speed = 2}}},
		{"Fading Body", {title = "Ghost", body = "Slowly fading in and out.", bodyEffect = "fade", bodyEffectOpts = {speed = 2}}},
		{"Jittery Body", {body = "Occasional random jitter bursts.", bodyEffect = "jitter", bodyEffectOpts = {chance = 0.3, magnitude = 2}}},
		{"Flickering Body", {title = "Broken Signal", body = "Intermittent flicker.", bodyEffect = "flicker", bodyEffectOpts = {chance = 0.4, duration = 0.12}}},
	}

	for _, entry in ipairs(bodyEffects) do
		local btn = vgui.Create("Elib.TextButton", scroll)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, Elib.Scale(3))
		btn:SetTall(Elib.Scale(32))
		btn:SetText(entry[1])
		btn:SetElibTooltip(entry[2])
	end
end)