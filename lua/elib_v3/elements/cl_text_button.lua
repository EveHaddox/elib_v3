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

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextSpacing", "TextSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)

Elib.RegisterFont("UI.TextButton", "Space Grotesk SemiBold", 20)

function PANEL:Init()
    self:SetText("Button")
    self:SetTextAlign(TEXT_ALIGN_CENTER)
    self:SetTextSpacing(Elib.Scale(6))
    self:SetFont("UI.TextButton")

    self:SetSize(Elib.Scale(100), Elib.Scale(30))
end

function PANEL:SizeToText()
    Elib.SetFont(self:GetFont())
    self:SetSize(Elib.GetTextSize(self:GetText()) + Elib.Scale(14), Elib.Scale(30))
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()

    if not self:IsEnabled() then
        Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)
        return
    end

    Elib.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, Elib.Colors.PrimaryText, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("Elib.TextButton", PANEL, "Elib.Button")