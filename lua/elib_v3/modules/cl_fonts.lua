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
]]

Elib.RegisteredFonts = Elib.RegisteredFonts or {}
local registeredFonts = Elib.RegisteredFonts

do
    Elib.SharedFonts = Elib.SharedFonts or {}
    local sharedFonts = Elib.SharedFonts

    function Elib.RegisterFontUnscaled(name, font, size, weight)
        weight = weight or 500

        local identifier = font .. size .. ":" .. weight

        local fontName = "Elib:" .. identifier
        registeredFonts[name] = fontName

        if sharedFonts[identifier] then return end
        sharedFonts[identifier] = true

        surface.CreateFont(fontName, {
            font = font,
            size = size,
            weight = weight,
            extended = true,
            antialias = true
        })
    end
end

do
    Elib.ScaledFonts = Elib.ScaledFonts or {}
    local scaledFonts = Elib.ScaledFonts

    function Elib.RegisterFont(name, font, size, weight)
        scaledFonts[name] = {
            font = font,
            size = size,
            weight = weight
        }

        Elib.RegisterFontUnscaled(name, font, Elib.Scale(size), weight)
    end

    hook.Add("OnScreenSizeChanged", "Elib.ReRegisterFonts", function()
        for k,v in pairs(scaledFonts) do
            Elib.RegisterFont(k, v.font, v.size, v.weight)
        end
    end)
end

do
    local setFont = surface.SetFont
    local function setElibFont(font)
        local ElibFont = registeredFonts[font]
        if ElibFont then
            setFont(ElibFont)
            return
        end

        setFont(font)
    end

    Elib.SetFont = setElibFont

    local getTextSize = surface.GetTextSize
    function Elib.GetTextSize(text, font)
        if font then setElibFont(font) end
        return getTextSize(text)
    end

    function Elib.GetRealFont(font)
        return registeredFonts[font]
    end
end
