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

do
    local materials = {
        "https://pixel-cdn.lythium.dev/i/srlt7tk7m", --8
        "https://pixel-cdn.lythium.dev/i/l2km82zi", --16
        "https://pixel-cdn.lythium.dev/i/5mqrguuxd", --32
        "https://pixel-cdn.lythium.dev/i/yxh641f2a", --64
        "https://pixel-cdn.lythium.dev/i/yz2n2neu", --128
        "https://pixel-cdn.lythium.dev/i/v4sxyjdd8", --256
        "https://pixel-cdn.lythium.dev/i/nmp8368j", --512
        "https://pixel-cdn.lythium.dev/i/e425w7lrj", --1024
        "https://pixel-cdn.lythium.dev/i/iinrlgj5b" --2048
    }

    local max = math.max
    function Elib.DrawCircle(x, y, w, h, col)
        local size = max(w, h)
        local id = materials[1]

        local curSize = 8
        for i = 1, #materials do
            if size <= curSize then break end
            id = materials[i + 1] or id
            curSize = curSize + curSize
        end

        Elib.DrawImage(x, y, w, h, id, col)
    end
end

do
    local insert = table.insert
    local rad, sin, cos = math.rad, math.sin, math.cos

    function Elib.CreateCircle(x, y, ang, seg, pct, radius)
        local circle = {}

        insert(circle, {x = x, y = y})

        for i = 0, seg do
            local segAngle = rad((i / seg) * -pct + ang)
            insert(circle, {x = x + sin(segAngle) * radius, y = y + cos(segAngle) * radius})
        end

        return circle
    end
end

local createCircle = Elib.CreateCircle
local drawPoly = surface.DrawPoly
function Elib.DrawCircleUncached(x, y, ang, seg, pct, radius)
    drawPoly(createCircle(x, y, ang, seg, pct, radius))
end


function Elib.DrawArc(x, y, r, startAng, endAng, step ,cache)
    local positions = {}


    positions[1] = {
        x = x,
        y = y
    }


    for i = startAng - 90, endAng - 90, step do
        table.insert(positions, {
            x = x + math.cos(math.rad(i)) * r,
            y = y + math.sin(math.rad(i)) * r
        })
    end


    return (cache and positions) or surface.DrawPoly(positions)
end

function Elib.DrawSubSection(x, y, r, r2, startAng, endAng, step, cache)
    local positions = {}
    local inner = {}
    local outer = {}


    r2 = r+r2
    startAng = startAng or 0
    endAng = endAng or 0


    for i = startAng - 90, endAng - 90, step do
        table.insert(inner, {
            x = math.ceil(x + math.cos(math.rad(i)) * r2),
            y = math.ceil(y + math.sin(math.rad(i)) * r2)
        })
    end


    for i = startAng - 90, endAng - 90, step do
        table.insert(outer, {
            x = math.ceil(x + math.cos(math.rad(i)) * r),
            y = math.ceil(y + math.sin(math.rad(i)) * r)
        })
    end


    for i = 1, #inner * 2 do
        local outPoints = outer[math.floor(i / 2) + 1]
        local inPoints = inner[math.floor((i + 1) / 2) + 1]
        local otherPoints


        if i % 2 == 0 then
            otherPoints = outer[math.floor((i + 1) / 2)]
        else
            otherPoints = inner[math.floor((i + 1) / 2)]
        end


        table.insert(positions, {outPoints, otherPoints, inPoints})
    end


    if cache then
        return positions
    else
        for k,v in pairs(positions) do 
            surface.DrawPoly(v)
        end
    end
end