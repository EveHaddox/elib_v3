// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Pie Chart
///////////////////
local PANEL = {}

function PANEL:Init()
    self.Data     = {}
    self.Font     = "DermaDefaultBold"
    self.Radius   = 0
    self.HoleFrac = 10
    self.BasePad  = 10
end

function PANEL:SetData(tbl) self.Data = tbl or {} end
function PANEL:AddSlice(label, value, col)
    table.insert(self.Data, {label = label, value = value, color = col})
end
function PANEL:SetRadius(r)      self.Radius   = r    or self.Radius   end
function PANEL:SetDonut(frac)    self.HoleFrac = math.Clamp(frac or 0, 0, .9) end

local rad, cos, sin = math.rad, math.cos, math.sin
local function sum(tbl) local t=0 for _,s in ipairs(tbl) do t = t + s.value end return t end

local function buildArc(cx, cy, r, a0, a1, steps)
    local poly = {}
    for i=0, steps do
        local a = rad(a0 + (a1-a0)*(i/steps))
        poly[#poly+1] = {x = cx + cos(a)*r, y = cy + sin(a)*r}
    end
    return poly
end

function PANEL:Paint(w, h)
    if #self.Data < 1 then return end

    local cx, cy = w*0.5, h*0.5
    local R   = (self.Radius>0 and self.Radius) or math.min(w, h)*0.5 - self.BasePad
    local rIn = R * self.HoleFrac
    local total = sum(self.Data)
    if total == 0 then return end

    surface.SetFont(self.Font)
    draw.NoTexture()

    local startAng = -90
    for idx, seg in ipairs(self.Data) do
        local sweep = 360 * (seg.value / total)
        local col   = seg.color or HSVToColor((idx/#self.Data)*360, .65, 1)
        surface.SetDrawColor(col)

        local outer = buildArc(cx, cy, R, startAng, startAng+sweep, math.max(2, math.floor(sweep/4)))
        local inner = (rIn>0) and buildArc(cx, cy, rIn, startAng+sweep, startAng, math.max(2, math.floor(sweep/4))) or {{x=cx,y=cy}}

        local poly = {}
        for _,p in ipairs(outer) do poly[#poly+1]=p end
        for _,p in ipairs(inner) do poly[#poly+1]=p end
        surface.DrawPoly(poly)

        -- label
        local midAng = startAng + sweep*0.5
        local tx, ty = cx + cos(rad(midAng))*(R + 14), cy + sin(rad(midAng))*(R + 14)
        local pct    = math.floor((seg.value/total)*100 + 0.5)
        draw.SimpleText((seg.label or "") .. " ("..pct.."%)", self.Font, tx, ty, Color(240,240,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        startAng = startAng + sweep
    end

    -- optional donut hole mask
    if rIn>0 then
        surface.SetDrawColor(30,30,30,255)
        local inner = buildArc(cx, cy, R * .8, 0, 360, 40)
        surface.DrawPoly(inner)
    end
end

vgui.Register("Elib.PieChart", PANEL, "DPanel")