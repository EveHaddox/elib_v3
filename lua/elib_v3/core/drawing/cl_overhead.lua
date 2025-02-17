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

Elib.RegisterFontUnscaled("UI.Overhead", "Open Sans Bold", 100)

local localPly
local function checkDistance(ent)
    if not IsValid(localPly) then localPly = LocalPlayer() end
    if localPly:GetPos():DistToSqr(ent:GetPos()) > 200000 then return true end
end

local disableClipping = DisableClipping
local start3d2d, end3d2d = cam.Start3D2D, cam.End3D2D
local Icon = icon

local function drawOverhead(ent, pos, text, ang, scale)
    if ang then
        ang = ent:LocalToWorldAngles(ang)
    else
        ang = (pos - localPly:GetPos()):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
    end

    Elib.SetFont("UI.Overhead")
    local w, h = Elib.GetTextSize(text)
    w = w + 40
    h = h + 6

    local x, y = -(w * .5), -h

    local oldClipping = disableClipping(true)

    start3d2d(pos, ang, scale or 0.05)
    if not Icon then
        Elib.DrawRoundedBox(12, x, y, w, h, Elib.Colors.Background)
        Elib.DrawText(text, "UI.Overhead", 0, y + 1, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER)
        Elib.DrawOutlinedRoundedBox(10, x, y, w, h, Color(45, 45, 45), 3)
    else
        x = x - 40
        Elib.DrawRoundedBox(12, x, y, h, h, Elib.Colors.Primary)
        Elib.DrawRoundedBoxEx(12, x + (h - 12), y + h - 20, w + 15, 20, Elib.Colors.Primary, false, false, false, true)
        Elib.DrawText(text, "UI.Overhead", x + h + 15, y + 8, Elib.Colors.PrimaryText)
        Elib.DrawImage(x + 10, y + 10, h - 20, h - 20, Icon, color_white)
    end
    end3d2d()

    disableClipping(oldClipping)
end

local entOffset = 2
function Elib.DrawEntOverhead(ent, text, angleOverride, posOverride, scaleOverride)
    if checkDistance(ent) then return end

    if posOverride then
        drawOverhead(ent, ent:LocalToWorld(posOverride), text, angleOverride, scaleOverride)
        return
    end

    local pos = ent:OBBMaxs()
    pos:SetUnpacked(0, 0, pos[3] + entOffset)

    drawOverhead(ent, ent:LocalToWorld(pos), text, angleOverride, scaleOverride)
end

local eyeOffset = Vector(0, 0, 7)
local fallbackOffset = Vector(0, 0, 73)
function Elib.DrawNPCOverhead(ent, text, angleOverride, offsetOverride, scaleOverride)
    if checkDistance(ent) then return end

    local eyeId = ent:LookupAttachment("eyes")
    if eyeId then
        local eyes = ent:GetAttachment(eyeId)
        if eyes then
            eyes.Pos:Add(offsetOverride or eyeOffset)
            drawOverhead(ent, eyes.Pos, text, angleOverride, scaleOverride)
            return
        end
    end

    drawOverhead(ent, ent:GetPos() + fallbackOffset, text, angleOverride, scaleOverride)
end

function Elib.EnableIconOverheads(new)
    local oldIcon = Icon
    local imgurMatch = (new or ""):match("^[a-zA-Z0-9]+$")
    if imgurMatch then
        new = "https://i.imgur.com/" .. new .. ".png"
    end
    Icon = new
    return oldIcon
end