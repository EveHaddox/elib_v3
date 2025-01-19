// This library is based on Pixel UI by Tom.bat
// This is Pixel UI's licence this library also follows

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

Elib = Elib or {}
Elib.Version = "1.0"

function Elib.LoadDirectory(path)
	local files, folders = file.Find(path .. "/*", "LUA")

	for _, fileName in ipairs(files) do
		local filePath = path .. "/" .. fileName

		if CLIENT then
			include(filePath)
		else
			if fileName:StartWith("cl_") then
				AddCSLuaFile(filePath)
			elseif fileName:StartWith("sh_") then
				AddCSLuaFile(filePath)
				include(filePath)
			else
				include(filePath)
			end
		end
	end

	return files, folders
end

function Elib.LoadDirectoryRecursive(basePath)
	local _, folders = Elib.LoadDirectory(basePath)
	for _, folderName in ipairs(folders) do
		Elib.LoadDirectoryRecursive(basePath .. "/" .. folderName)
	end
end

Elib.LoadDirectoryRecursive("elib")

hook.Run("Elib.FullyLoaded")

if CLIENT then return end

--[[
resource.AddWorkshop("2468112758")

hook.Add("Think", "Elib.UI.VersionChecker", function()
	hook.Remove("Think", "Elib.UI.VersionChecker")

	http.Fetch("https://raw.githubusercontent.com/TomDotBat/pixel-ui/master/VERSION", function(body)
		if Elib.Version ~= string.Trim(body) then
			local red = Color(192, 27, 27)

			MsgC(red, "[Elib] There is an update available, please download it at: https://github.com/TomDotBat/pixel-ui/releases\n")
			MsgC(red, "\nYour version: " .. Elib.Version .. "\n")
			MsgC(red, "New  version: " .. body .. "\n")
			return
		end
	end)
end)
]]