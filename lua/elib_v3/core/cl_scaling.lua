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

function Elib.Scale(value)
    return math.max(value * (ScrH() / 1080), 1)
end

local constants = {}
local scaledConstants = {}
function Elib.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = Elib.Scale(size)
end

function Elib.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "Elib.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = Elib.Scale(size)
    end
end)