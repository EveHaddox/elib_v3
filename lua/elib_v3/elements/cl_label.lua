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
end

function PANEL:SetText(text)
    self.OriginalText = text
    self:ParseColoredText()
end

function PANEL:GetText()
    return self.Text or ""
end

function PANEL:ParseColoredText()
    self.ColorSegments = {}
    local text = self.OriginalText or ""
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
                    start = #plainText + 1,
                    length = #content,
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
    local font = self:GetFont()
    local baseColor = self:GetTextColor()

    if self.ColorSegments and #self.ColorSegments > 0 then
        Elib.SetFont(font)
        
        local xPos = 0
        local yPos = 0

        if align == TEXT_ALIGN_CENTER then
            local totalWidth = Elib.GetTextSize(text)
            xPos = w / 2 - totalWidth / 2
        elseif align == TEXT_ALIGN_RIGHT then
            local totalWidth = Elib.GetTextSize(text)
            xPos = w - totalWidth
        end
        
        local currentSegment = 1
        local currentPos = 1

        for i = 1, #text do
            local char = string.sub(text, i, i)
            local charColor = baseColor

            for _, segment in ipairs(self.ColorSegments) do
                if i >= segment.start and i < segment.start + segment.length then
                    charColor = segment.color
                    break
                end
            end
            
            Elib.DrawText(char, font, xPos, yPos, charColor, TEXT_ALIGN_LEFT)
            local charWidth = Elib.GetTextSize(char)
            xPos = xPos + charWidth
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