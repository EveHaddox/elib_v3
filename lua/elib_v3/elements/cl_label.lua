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

-- Remove AccessorFunc for Text to use custom SetText
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "Ellipses", "Ellipses", FORCE_BOOL)
AccessorFunc(PANEL, "AutoHeight", "AutoHeight", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWidth", "AutoWidth", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWrap", "AutoWrap", FORCE_BOOL)

Elib.RegisterFont("UI.Label", "Space Grotesk SemiBold", 14)

function PANEL:Init()
    self:SetText("Label")
    self:SetFont("UI.Label")
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetTextColor(Elib.Colors.SecondaryText)

    hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
    self:SetTextColor(Elib.Colors.SecondaryText)
end

local function StripInvalidUtf8(str)
    str = tostring(str or "")
    if pcall(utf8.len, str) then return str end

    local bytes = { string.byte(str, 1, #str) }
    local out, i = {}, 1
    while i <= #bytes do
        local b = bytes[i]
        local len = (b < 0x80 and 1)
            or (b >= 0xC2 and b <= 0xDF and 2)
            or (b >= 0xE0 and b <= 0xEF and 3)
            or (b >= 0xF0 and b <= 0xF4 and 4)
            or 1

        local ok, ch
        if i + len - 1 <= #bytes then
            local slice = {}
            for j = 0, len - 1 do slice[#slice + 1] = bytes[i + j] end
            ok, ch = pcall(utf8.char, unpack(slice))
        end

        if ok and ch then
            out[#out + 1] = ch
            i = i + len
        else
            i = i + 1
        end
    end
    return table.concat(out)
end

local function ForEachUtf8Char(line, fn)
    line = StripInvalidUtf8(tostring(line or ""))
    for ch in string.gmatch(line, utf8.charpattern) do
        fn(ch)
    end
end

function PANEL:SetText(text)
    text = StripInvalidUtf8(text)
    self.OriginalText = text
    self.Text = text
    self:ParseColoredText()
end

function PANEL:GetText()
    return self.Text or ""
end

function PANEL:ParseColoredText()
    self.ColorSegments = {}
    local text = StripInvalidUtf8(self.OriginalText or "")
    local plainText = ""
    local pos = 1

    while pos <= #text do
        local tagStart, tagEnd, r, g, b, a = string.find(text, "<color%((%d+),%s*(%d+),%s*(%d+),%s*(%d+)%)>", pos)
        
        if tagStart then
            if tagStart > pos then
                plainText = plainText .. string.sub(text, pos, tagStart - 1)
            end

            local closeStart, closeEnd = string.find(text, "</color>", tagEnd + 1)
            if closeStart then
                local content = string.sub(text, tagEnd + 1, closeStart - 1)

                table.insert(self.ColorSegments, {
                    start = (utf8.len(plainText) or #plainText) + 1,
                    length = utf8.len(content) or #content,
                    color = Color(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
                })

                plainText = plainText .. content
                pos = closeEnd + 1
            else
                plainText = plainText .. string.sub(text, pos)
                break
            end
        else
            plainText = plainText .. string.sub(text, pos)
            break
        end
    end
    
    self.OriginalText = plainText
end

function PANEL:CalculateSize()
    Elib.SetFont(self:GetFont())
    return Elib.GetTextSize(self:GetText())
end

function PANEL:PerformLayout(w, h)
    local desiredW, desiredH = self:CalculateSize()

    if self:GetAutoWidth() then
        self:SetWide(desiredW)
    end

    if self:GetAutoHeight() then
        self:SetTall(desiredH)
    end

    if self:GetAutoWrap() then
        self.Text = Elib.WrapText(self.OriginalText, w, self:GetFont())
    end
end

function PANEL:Paint(w, h)
    local align = self:GetTextAlign()
    local text = self:GetEllipses() and Elib.EllipsesText(self:GetText(), w, self:GetFont()) or self:GetText()
    text = StripInvalidUtf8(text)
    local font = self.GetFont and self:GetFont() or "UI.Label"
    local baseColor = self:GetTextColor()

    if self.ColorSegments and #self.ColorSegments > 0 then
        Elib.SetFont(font)

        local lines = string.Explode("\n", text)
        local lineWidths = {}
        for i, line in ipairs(lines) do
            line = StripInvalidUtf8(line)
            lines[i] = line
            lineWidths[i] = (Elib.GetTextSize(line))
        end

        local _, lineHeight = Elib.GetTextSize("Ay")
        local globalIndex = 1

        for li, line in ipairs(lines) do
            local lineWidth = lineWidths[li] or 0
            local xPos = 0
            local yPos = (li - 1) * lineHeight

            if align == TEXT_ALIGN_CENTER then
                xPos = w / 2 - lineWidth / 2
            elseif align == TEXT_ALIGN_RIGHT then
                xPos = w - lineWidth
            end

            ForEachUtf8Char(line, function(char)
                local charColor = baseColor

                for _, segment in ipairs(self.ColorSegments) do
                    if globalIndex >= segment.start and globalIndex < segment.start + segment.length then
                        charColor = segment.color
                        break
                    end
                end

                Elib.DrawText(char, font, xPos, yPos, charColor, TEXT_ALIGN_LEFT)
                local charWidth = Elib.GetTextSize(char)
                xPos = xPos + charWidth
                globalIndex = globalIndex + 1
            end)

            if li < #lines then
                globalIndex = globalIndex + 1 -- newline
            end
        end

        return
    end

    if align == TEXT_ALIGN_CENTER then
        Elib.DrawText(text, font, w / 2, 0, baseColor, TEXT_ALIGN_CENTER)
        return
    elseif align == TEXT_ALIGN_RIGHT then
        Elib.DrawText(text, font, w, 0, baseColor, TEXT_ALIGN_RIGHT)
        return
    end

    Elib.DrawText(text, font, 0, 0, baseColor)
end

vgui.Register("Elib.Label", PANEL, "Panel")