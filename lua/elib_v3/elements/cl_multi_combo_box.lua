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

Derma_Install_Convar_Functions(PANEL)

AccessorFunc(PANEL, "bSizeToText", "SizeToText", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDoSort", "SortItems", FORCE_BOOL)

function PANEL:Init()
    self:SetSizeToText(true)

    self:Clear()

    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetSortItems(true)
end

function PANEL:PerformLayout(w, h)
    if not self:GetSizeToText() then return end
    self:SizeToText()
    self:SetWide(self:GetWide() + Elib.Scale(14))
end

function PANEL:Clear()
    self:SetText("")
    self.Choices = {}
    self.Data = {}
    self.ChoiceIcons = {}
    self.selected = {}

    if not self.Menu then return end
    self.Menu:Remove()
    self.Menu = nil
end

function PANEL:GetOptionText(id)
    return self.Choices[id]
end

function PANEL:GetOptionData(id)
    return self.Data[id]
end

function PANEL:GetOptionTextByData(data)
    for id, dat in pairs(self.Data) do
        if dat == data then
            return self:GetOptionText(id)
        end
    end

    for id, dat in pairs(self.Data) do
        if dat == tonumber(data) then
            return self:GetOptionText(id)
        end
    end

    return data
end

function PANEL:ChooseOption(value, index)
    if self.Menu then
        self.Menu:Remove()
        self.Menu = nil
    end

    local wasSelected = table.HasValue(self.selected, index)
    if wasSelected then
        table.RemoveByValue(self.selected, index)
    else
        table.insert(self.selected, index)
    end

    self:OnSelectionChanged(index, value, not wasSelected)

    local displayText = ""
    for i, selectedIndex in ipairs(self.selected) do
        if i > 1 then displayText = displayText .. ", " end
        displayText = displayText .. self:GetOptionText(selectedIndex)
    end
    
    if #self.selected == 0 then
        displayText = ""
    end
    
    self:SetText(displayText)
    self:OnSelect(self.selected, value, index)

    if not self:GetSizeToText() then return end
    self:SizeToText()
    self:SetWide(self:GetWide() + Elib.Scale(10))
end

function PANEL:OnSelectionChanged(index, value, selected) end

function PANEL:GetSelectedValues()
    local values = {}
    for _, index in ipairs(self.selected) do
        values[self:GetOptionText(index)] = true
    end
    return values
end

function PANEL:ChooseOptionID(index)
    local value = self:GetOptionText(index)
    self:ChooseOption(value, index)
end

function PANEL:GetSelectedIDs()
    return self.selected
end

function PANEL:GetSelectedID(k)
    return self.selected[k]
end

function PANEL:GetSelected()
    if not self.selected or table.IsEmpty(self.selected) then return false end
    
    local result = {}
    for _, index in ipairs(self.selected) do
        table.insert(result, {
            id = index,
            text = self:GetOptionText(index),
            data = self:GetOptionData(index)
        })
    end
    
    return result
end

function PANEL:OnSelect(selectedIndices, value, index) end

function PANEL:AddChoice(value, data, select, icon)
    local i = table.insert(self.Choices, value)

    if data then
        self.Data[i] = data
    end

    if icon then
        self.ChoiceIcons[i] = icon
    end

    if select then
        self:ChooseOption(value, i)
    end

    return i
end

function PANEL:IsMenuOpen()
    return IsValid(self.Menu) and self.Menu:IsVisible()
end

function PANEL:OpenMenu(pControlOpener)
    if pControlOpener and pControlOpener == self.TextEntry then return end

    if #self.Choices == 0 then return end

    if IsValid(self.Menu) then
        self.Menu:Remove()
        self.Menu = nil
    end

    CloseDermaMenus()
    self.Menu = vgui.Create("Elib.Menu", self)

    local function AddMultiOption(menu, id, text)
        local option = menu:AddOption(text, function() 
            self:ChooseOption(text, id) 
        end)

        option.Paint = function(pnl, w, h)

            local bgColor = pnl.BackgroundCol
            if pnl:IsDown() then
                bgColor = Elib.OffsetColor(Elib.Colors.Background, 5)
            elseif pnl:IsHovered() then
                bgColor = Elib.OffsetColor(Elib.Colors.Background, 15)
            end
            Elib.DrawRoundedBox(Elib.Scale(6), 0, 0, w, h, bgColor)

            local size = h * .35
            local offset = (h - size) / 2

            if table.HasValue(self.selected, id) then
                Elib.DrawRoundedBox(Elib.Scale(5), offset, offset, size, size, Elib.Colors.Positive)
            else
                Elib.DrawRoundedBox(Elib.Scale(5), offset, offset, size, size, Elib.Colors.Negative)
            end

            Elib.DrawSimpleText(text, option:GetFont(), h, h / 2, Elib.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            return false
        end
        
        if self.ChoiceIcons[id] then
            option:SetIcon(self.ChoiceIcons[id])
        end
        
        return option
    end

    if self:GetSortItems() then
        local sorted = {}
        for k, v in pairs(self.Choices) do
            local val = tostring(v)
            if string.len(val) > 1 and not tonumber(val) and val:StartWith("#") then val = language.GetPhrase(val:sub(2)) end
            table.insert(sorted, {id = k, data = v, label = val})
        end

        for k, v in SortedPairsByMemberValue(sorted, "label") do
            AddMultiOption(self.Menu, v.id, v.data)
        end
    else
        for k, v in pairs(self.Choices) do
            AddMultiOption(self.Menu, k, v)
        end
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    self.Menu:SetMinimumWidth(self:GetWide())
    self.Menu:Open(x, y + Elib.Scale(6), false, self)

    self:SetToggle(true)

    self.Menu.OnRemove = function(s)
        if not IsValid(self) then return end
        self:SetToggle(false)
    end
end

function PANEL:CloseMenu()
    if not IsValid(self.Menu) then return end
    self.Menu:Remove()
end

function PANEL:CheckConVarChanges()
    if not self.m_strConVar then return end

    local strValue = GetConVar(self.m_strConVar):GetString()
    if self.m_strConVarValue == strValue then return end

    self.m_strConVarValue = strValue
    self:SetValue(self:GetOptionTextByData(self.m_strConVarValue))
end

function PANEL:Think()
    self:CheckConVarChanges()
end

function PANEL:SetValue(strValue)
    self:SetText(strValue)
end

function PANEL:DoClick()
    if self:IsMenuOpen() then return self:CloseMenu() end
    self:OpenMenu()
end

function PANEL:PaintOver(w, h)
    local dropBtnSize = Elib.Scale(8)
    Elib.DrawImage(w - dropBtnSize - Elib.Scale(8), h / 2 - dropBtnSize / 2, dropBtnSize, dropBtnSize, "https://pixel-cdn.lythium.dev/i/5r7ovslav", Elib.Colors.PrimaryText)
end

vgui.Register("Elib.MultiComboBox", PANEL, "Elib.TextButton")