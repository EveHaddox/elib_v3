// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Infinite Panel
///////////////////
local PANEL = {}

Elib.RegisterFont("Elib.InfinitePnl.Coordinates", "Inter SemiBold", 18)

function PANEL:Init()

    self.Owned = nil
    
    self.pos = {
        x = 0,
        y = 0
    }

    self.mousePos = {
        x = 0,
        y = 0
    }

    self:SetBounds(-500, -400, 500, 20)

    self.items = {}
    self.itemsLog = {}
    self.IsDragging = false

    function self:OnMousePressed(code)
        if code == MOUSE_LEFT then
            self.IsDragging = true
            local mouseX, mouseY = self:CursorPos()
            self.mousePos.x = mouseX
            self.mousePos.y = mouseY
        end
    end

    function self:OnMouseReleased(code)
        if code == MOUSE_LEFT then
            self.IsDragging = false
        end
    end

    function self:Think()
        if self.IsDragging then
            local mouseX, mouseY = self:CursorPos()
            if mouseX == self.mousePos.x and mouseY == self.mousePos.y then return end

            local newX = self.pos.x + (mouseX - self.mousePos.x)
            local newY = self.pos.y + (mouseY - self.mousePos.y)

            self.pos.x = math.Clamp(newX, self.MinX, self.MaxX)
            self.pos.y = math.Clamp(newY, self.MinY, self.MaxY)
            self.mousePos.x, self.mousePos.y = self:CursorPos()

            for k, v in pairs(self.items) do
                v:SetPos(self.pos.x + self.itemsLog[k].x, self.pos.y + self.itemsLog[k].y)
            end
        end
    end

end

function PANEL:SetBounds(minX, minY, maxX, maxY)
    self.MinX = minX
    self.MinY = minY
    self.MaxX = maxX
    self.MaxY = maxY
end

function PANEL:AddItem(panel, id, x, y, w, h) -- conflicting means you can't have this item if you have the conflicting item
    
    self.itemsLog[id] = {
        x = x,
        y = y,
        w = w,
        h = h
    }

    self.items[id] = self:Add(panel)
    self.items[id]:SetPos(self.pos.x + x, self.pos.y + y)
    self.items[id]:SetSize(w, h)

    return self.items[id]

end

function PANEL:AddTextButton(id, x, y, w, h, required, conflicting) -- conflicting means you can't have this item if you have the conflicting item
    
    local pnl = self:AddItem("Elib.TextButton", id, x, y, w, h, required, conflicting)
    pnl:SetText(id)

    if !self.Owned or !required then return end
    if !self.Owned[required] then
       pnl:SetEnabled(false)
    end

end

function PANEL:AddConnection(id, x, y, w, h)
    
    local pnl = self:AddItem("DPanel", id, x, y, w, h)

    pnl.Paint = function(self, w, h)
        surface.SetDrawColor(Elib.Colors.Silver)
        surface.DrawRect(0, 0, w, h)
    end

end

function PANEL:AddImage(id, x, y, w, h, url, col)
    
    self.itemsLog[id] = {
        x = x,
        y = y,
        w = w,
        h = h
    }

    self.items[id] = self:Add("DPanel")
    self.items[id]:SetPos(self.pos.x + x, self.pos.y + y)
    self.items[id]:SetSize(w, h)

    self.items[id].Paint = function(self, w, h)
        Elib.DrawImage(0, 0, w, h, url, col)
    end

end

function PANEL:PerformLayout(w, h)
    
    self:Dock(FILL)

end

function PANEL:Paint(w, h)
    local XDisplay = self.pos.x == 0 and 0 or self.pos.x * -1
    Elib.DrawSimpleText("X:".. XDisplay .." Y:".. self.pos.y, "Elib.InfinitePnl.Coordinates", w - 5, 5, Elib.Colors.PrimaryText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    surface.SetDrawColor(255, 0, 0, 255)
    local thickness = 2

    -- Top border
    if self.pos.y == self.MaxY then
        Elib.DrawRoundedBox(8, w * .25, 0, w / 2, thickness, Elib.Colors.Primary)
    end
    -- Bottom border
    if self.pos.y == self.MinY then
        Elib.DrawRoundedBox(8, w * .25, h - thickness, w / 2, thickness, Elib.Colors.Primary)
    end
    -- Left border
    if self.pos.x == self.MaxX then
        Elib.DrawRoundedBox(8, 0, h * .25, thickness, h / 2, Elib.Colors.Primary)
    end
    -- Right border
    if self.pos.x == self.MinX then
        Elib.DrawRoundedBox(8, w - thickness, h * .25, thickness, h / 2, Elib.Colors.Primary)
    end
end

function PANEL:OnMouseWheeled(delta)
    local moveAmount = 30

    if input.IsKeyDown(KEY_LSHIFT) then
        self.pos.x = math.Clamp(self.pos.x + delta * moveAmount, self.MinX, self.MaxX)
    else
        self.pos.y = math.Clamp(self.pos.y + delta * moveAmount, self.MinY, self.MaxY)
    end

    for k, v in pairs(self.items) do
        v:SetPos(self.pos.x + self.itemsLog[k].x, self.pos.y + self.itemsLog[k].y)
    end
end

vgui.Register("Elib.InfinitePanel", PANEL, "Panel")