// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Line Graph
///////////////////
local PANEL = {}

function PANEL:Init()
    self.Data        = {}
    self.LineColor   = Elib.Colors.Primary
    self.AxisColor   = Color(56, 56, 56, 200) -- low-α grid
    self.BasePad     = 10
    self.Font        = "DermaDefaultBold"

    self.UnitX, self.UnitY = "", ""
    self.TickX, self.TickY = 5, 5

    self.SamplesPerSeg = 10   -- spline smoothness
    self.FillAlphaTop  = 120   -- gradient opacity at curve

    hook.Add("Elib.ThemeChanged", self, function(s) s:UpdateColors() end)
end

function PANEL:UpdateColors()
    self.LineColor = Elib.Colors.Primary
end

function PANEL:SetData(tbl)             self.Data = tbl or {} end
function PANEL:AddPoint(x, y)           table.insert(self.Data, {x = x, y = y}) end
function PANEL:SetLineColor(col)        self.LineColor = col end
function PANEL:SetAxisColor(col)        self.AxisColor = col end
function PANEL:SetTicks(nx, ny)         self.TickX, self.TickY = nx or self.TickX, ny or self.TickY end
function PANEL:SetUnits(xUnit, yUnit)   self.UnitX, self.UnitY = xUnit or "", yUnit or "" end

local function range(tbl, key)
    local lo, hi = math.huge, -math.huge
    for _, pt in ipairs(tbl) do
        lo = (pt[key] < lo) and pt[key] or lo
        hi = (pt[key] > hi) and pt[key] or hi
    end
    if lo == hi then lo, hi = lo-1, hi+1 end
    return lo, hi
end

local function fmt(val)
    local s = tostring(math.floor(val))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function catmull(p0, p1, p2, p3, t)
    local t2, t3 = t*t, t*t*t
    return 0.5*((2*p1)
              + (-p0 + p2)*t
              + (2*p0 - 5*p1 + 4*p2 - p3)*t2
              + (-p0 + 3*p1 - 3*p2 + p3)*t3)
end

local function buildSpline(mapX, mapY, data, samples)
    local out, n = {}, #data
    for i = 1, n-1 do
        local p0 = data[math.max(i-1,1)]
        local p1 = data[i]
        local p2 = data[i+1]
        local p3 = data[math.min(i+2,n)]
        for s = 0, samples-1 do
            local t = s / samples
            out[#out+1] = {
                x = mapX(catmull(p0.x,p1.x,p2.x,p3.x,t)),
                y = mapY(catmull(p0.y,p1.y,p2.y,p3.y,t))
            }
        end
    end
    local last = data[n]
    out[#out+1] = { x = mapX(last.x), y = mapY(last.y) }
    return out
end

function PANEL:Paint(w, h)
    surface.SetFont(self.Font)

    if #self.Data < 2 then return end

    local minX, maxX = range(self.Data, "x")
    local minY, maxY = range(self.Data, "y")

    local widest = 0
    for i = 0, self.TickY do
        local txt = fmt(Lerp(i/self.TickY, minY, maxY)) .. self.UnitY
        widest = math.max(widest, surface.GetTextSize(txt))
    end
    
    local padL, padR, padT = self.BasePad + widest, self.BasePad, self.BasePad
    local padB = self.BasePad + 14
    local gw, gh = w - padL - padR, h - padT - padB

    local mapX = function(x) return padL      + (x-minX)/(maxX-minX) * gw end
    local mapY = function(y) return h - padB - (y-minY)/(maxY-minY) * gh end

    local spline = buildSpline(mapX, mapY, self.Data, self.SamplesPerSeg)
    local poly   = {}
    for _, pt in ipairs(spline) do poly[#poly+1] = {x = pt.x, y = pt.y} end
    local baseY = h - padB
    for i = #spline, 1, -1 do
        poly[#poly+1] = {x = spline[i].x, y = baseY}
    end

    surface.SetDrawColor(self.AxisColor)
    for i = 0, self.TickY do
        local y = mapY(Lerp(i/self.TickY, minY, maxY))
        surface.DrawLine(padL, y, w-padR, y)
    end

    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)

    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)

    surface.SetDrawColor(255,255,255,255)
    for i = 2, #spline do
        local p1, p2 = spline[i-1], spline[i]
        surface.DrawPoly({
            {x = p1.x, y = p1.y},
            {x = p2.x, y = p2.y},
            {x = p2.x, y = baseY},
            {x = p1.x, y = baseY},
        })
    end

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    surface.SetMaterial(Material("vgui/gradient-u"))
    local lc = self.LineColor
    surface.SetDrawColor(lc.r, lc.g, lc.b, self.FillAlphaTop)
    surface.DrawTexturedRect(padL, padT, gw, gh)

    surface.SetDrawColor(self.LineColor)
    for i = 2, #spline do
        local p1, p2 = spline[i-1], spline[i]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
        surface.DrawLine(p1.x+1, p1.y, p2.x+1, p2.y)
    end

    render.SetStencilEnable(false)

    surface.SetDrawColor(50,50,50)
    surface.DrawLine(padL, h-padB, w-padR, h-padB) -- X
    --surface.DrawLine(padL, padT, padL, h-padB) -- Y

    local function drawTick(v, isX)
        if isX then
            local x  = mapX(v)
            local str = fmt(v)..self.UnitX
            local tw  = surface.GetTextSize(str)

            local labelX = math.Clamp(x, padL + tw/2, w - padR - tw/2)

            surface.DrawLine(x, h-padB, x, h-padB+3)
            draw.SimpleText(str, self.Font, labelX, h-padB+5,
                            Color(220,220,220,180), TEXT_ALIGN_CENTER)
        else
            local y  = mapY(v)
            local str = fmt(v)..self.UnitY
            surface.DrawLine(padL-3, y, padL, y)
            draw.SimpleText(str, self.Font, padL-6, y,
                            Color(220,220,220,180), TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end
    end
    for i = 0, self.TickX do drawTick(Lerp(i/self.TickX, minX, maxX), true)  end
    for i = 0, self.TickY do drawTick(Lerp(i/self.TickY, minY, maxY), false) end
end

vgui.Register("Elib.LineGraph", PANEL, "DPanel")