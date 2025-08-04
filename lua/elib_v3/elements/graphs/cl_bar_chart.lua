// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Bar Chart
///////////////////
local PANEL = {}

function PANEL:Init()
    self.Data       = {}
    self.BarColor   = Elib.Colors.Primary
    self.AxisColor  = Color(56,56,56,200)
    self.BasePad    = 10
    self.Font       = "DermaDefaultBold"
    self.UnitY      = ""
    self.TickY      = 5
    self.BarSpacing = 0.5       -- as fraction of bar width
end

function PANEL:SetData(tbl)          self.Data = tbl or {} end
function PANEL:AddBar(label, val, col)
    table.insert(self.Data, {label = label, value = val, color = col})
end
function PANEL:SetBarColor(col)      self.BarColor  = col end
function PANEL:SetAxisColor(col)     self.AxisColor = col end
function PANEL:SetUnitY(unit)        self.UnitY     = unit or "" end
function PANEL:SetTicksY(n)          self.TickY     = n   or self.TickY end
function PANEL:SetBarSpacing(frac)   self.BarSpacing= math.max(0, frac or self.BarSpacing) end

local function fmt(v)
    local s = tostring(math.floor(v))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function maxVal(tbl)
    local m = 0
    for _,b in ipairs(tbl) do m = math.max(m, b.value) end
    return m
end

function PANEL:Paint(w, h)
    if #self.Data < 1 then return end

    local maxY = maxVal(self.Data)
    if maxY == 0 then maxY = 1 end

    -- Calculate the longest Y label width
    surface.SetFont(self.Font)
    local maxLabelW = 0
    for i = 0, self.TickY do
        local lbl = fmt(maxY * (i/self.TickY)) .. self.UnitY
        local tw, _ = surface.GetTextSize(lbl)
        if tw > maxLabelW then maxLabelW = tw end
    end

    local padL = self.BasePad + maxLabelW + 10 -- 10px extra for spacing
    local padR = self.BasePad
    local padT, padB = self.BasePad, self.BasePad + 16

    local gw, gh = w - padL - padR, h - padT - padB
    local n      = #self.Data
    local bw     = gw / (n + (n+1)*self.BarSpacing)  -- bar width
    local gap    = bw * self.BarSpacing

    -- horizontal grid
    surface.SetDrawColor(self.AxisColor)
    for i = 0, self.TickY do
        local y = h - padB - gh * (i/self.TickY)
        surface.DrawLine(padL, y, w-padR, y)

        local lbl = fmt(maxY * (i/self.TickY)) .. self.UnitY
        draw.SimpleText(lbl, self.Font, padL-6, y, Color(220,220,220,180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- bars & labels
    local x = padL + gap
    for _,bar in ipairs(self.Data) do
        local bh = gh * (bar.value / maxY)
        local by = h - padB - bh
        surface.SetDrawColor(bar.color or self.BarColor)
        surface.DrawRect(x, by, bw, bh)

        draw.SimpleText(bar.label or "", self.Font, x + bw*0.5, h - padB + 2, Color(240,240,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        x = x + bw + gap
    end

    -- axis lines
    surface.SetDrawColor(50,50,50)
    surface.DrawLine(padL, h-padB, w-padR, h-padB) -- X axis
    surface.DrawLine(padL, padT,   padL,   h-padB) -- Y axis
end

vgui.Register("Elib.BarChart", PANEL, "DPanel")