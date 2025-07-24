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

local materials = {}
local queue = {}

local useProxy = false

file.CreateDir(Elib.DownloadPath)

local function endsWithExtension(str)
    local fileName = str:match(".+/(.-)$")
    if not fileName then
        return false
    end
    local extractedExtension = fileName and fileName:match("^.+(%..+)$")

    return extractedExtension and string.sub(str, -#extractedExtension) == extractedExtension or false
end

local function processQueue()
    if queue[1] then
        local url, filePath, matSettings, callback = unpack(queue[1])

        http.Fetch((useProxy and ("https://proxy.duckduckgo.com/iu/?u=" .. url)) or url,
            function(body, len, headers, code)
                if len > 2097152 or code ~= 200 then
                    materials[filePath] = Material("nil")
                else
                    local writeFilePath = filePath
                    if not endsWithExtension(filePath) then
                        writeFilePath = filePath .. ".png"
                    end

                    file.Write(writeFilePath, body)
                    materials[filePath] = Material("../data/" .. writeFilePath, matSettings or "noclamp smooth mips")
                end

                callback(materials[filePath])
            end,
            function(error)
                if useProxy then
                    materials[filePath] = Material("nil")
                    callback(materials[filePath])
                else
                    useProxy = true
                    processQueue()
                end
            end
        )
    end
end

function Elib.GetImage(url, callback, matSettings)
    local protocol = url:match("^([%a]+://)")
    local urlWithoutProtocol = url
    if not protocol then
        protocol = "http://"
    else
        urlWithoutProtocol = string.gsub(url, protocol, "")
    end

    local fileNameStart = url:find("[^/]+$")
    if not fileNameStart then
        return
    end

    local urlWithoutFileName = url:sub(protocol:len() + 1, fileNameStart - 1)

    local dirPath = Elib.DownloadPath .. urlWithoutFileName
    local filePath = Elib.DownloadPath .. urlWithoutProtocol

    file.CreateDir(dirPath)

    local readFilePath = filePath
    if not endsWithExtension(filePath) and file.Exists(filePath .. ".png", "DATA") then
        readFilePath = filePath .. ".png"
    end

    if materials[filePath] then
        callback(materials[filePath])
    elseif file.Exists(readFilePath, "DATA") then
        materials[filePath] = Material("../data/" .. readFilePath, matSettings or "noclamp smooth mips")
        callback(materials[filePath])
    else
        table.insert(queue, {
            url,
            filePath,
            matSettings,
            function(mat)
                callback(mat)
                table.remove(queue, 1)
                processQueue()
            end
        })

        if #queue == 1 then
            processQueue()
        end
    end
end


function Elib.GetImgur(id, callback, _, matSettings)
    local url = "https://i.imgur.com/" .. id .. ".png"
    Elib.GetImage(url, callback, matSettings)
end


local progressMat

local drawProgressWheel
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

do
    local min = math.min
    local curTime = CurTime
    local drawTexturedRectRotated = surface.DrawTexturedRectRotated

    function Elib.DrawProgressWheel(x, y, w, h, col)
        local progSize = min(w, h)
        setMaterial(progressMat)
        setDrawColor(col.r, col.g, col.b, col.a)
        drawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end
    drawProgressWheel = Elib.DrawProgressWheel
end

local materials = {}
local grabbingMaterials = {}

local getImage = Elib.GetImage
getImage(Elib.ProgressImageURL, function(mat)
    progressMat = mat
end)

local drawTexturedRect = surface.DrawTexturedRect
function Elib.DrawImage(x, y, w, h, url, col)
    if not url then
        drawProgressWheel(x, y, w, h, col)
        return 
    end
    if not materials[url] then
        drawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRect(x, y, w, h)
end

local drawTexturedRectRotated = surface.DrawTexturedRectRotated
function Elib.DrawImageRotated(x, y, w, h, rot, url, col)
    if not materials[url] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x, y, w, h, rot)
end

function Elib.DrawImgur(x, y, w, h, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    Elib.DrawImage(x, y, w, h, url, col)
end

function Elib.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    Elib.DrawImageRotated(x, y, w, h, rot, url, col)
end