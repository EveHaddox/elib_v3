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

function PANEL:Init()
    self:SetIsToggle(true)

    local boxSize = Elib.Scale(20)
    self:SetSize(boxSize, boxSize)

    self:SetImageURL("https://pixel-cdn.lythium.dev/i/7u6uph3x6g")

    self:SetNormalColor(Elib.Colors.Transparent)
    self:SetHoverColor(Elib.Colors.PrimaryText)
    self:SetClickColor(Elib.Colors.PrimaryText)
    self:SetDisabledColor(Elib.Colors.Transparent)

    self:SetImageSize(.8)

    self.BackgroundCol = Elib.CopyColor(Elib.Colors.Primary)
end

function PANEL:PaintBackground(w, h)
    if not self:IsEnabled() then
        Elib.DrawRoundedBox(Elib.Scale(4), 0, 0, w, h, Elib.Colors.Disabled)
        self:PaintExtra(w, h)
        return
    end

    local bgCol = Elib.Colors.Primary

    if self:IsDown() or self:GetToggle() then
        bgCol = Elib.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = Elib.LerpColor(animTime, self.BackgroundCol, bgCol)

    Elib.DrawRoundedBox(Elib.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("Elib.Checkbox", PANEL, "Elib.ImageButton")