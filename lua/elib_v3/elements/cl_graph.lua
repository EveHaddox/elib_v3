// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}

------------------------------------------------------------------
--  INITIALISE
------------------------------------------------------------------
function PANEL:Init()
    self.Data        = {}
    self.LineColor   = Color(  0, 150, 255 )
    self.AxisColor   = Color(200, 200, 200, 40) -- low-α grid
    self.BgColor     = Color( 30,  30,  30, 200 )
    self.BasePad     = 10
    self.Font        = "DermaDefaultBold"

    self.UnitX, self.UnitY = "", ""
    self.TickX, self.TickY = 5, 5

    self.SamplesPerSeg = 10   -- spline smoothness
    self.FillAlphaTop  = 80   -- gradient opacity at curve
end

------------------------------------------------------------------
--  PUBLIC API
------------------------------------------------------------------
function PANEL:SetData(tbl)             self.Data = tbl or {} end
function PANEL:AddPoint(x, y)           table.insert(self.Data, {x = x, y = y}) end
function PANEL:SetLineColor(col)        self.LineColor = col end
function PANEL:SetAxisColor(col)        self.AxisColor = col end
function PANEL:SetBackgroundColor(col)  self.BgColor   = col end
function PANEL:SetTicks(nx, ny)         self.TickX, self.TickY = nx or self.TickX,
                                                                  ny or self.TickY end
function PANEL:SetUnits(xUnit, yUnit)   self.UnitX, self.UnitY = xUnit or "",
                                                                  yUnit or "" end

------------------------------------------------------------------
--  INTERNAL HELPERS
------------------------------------------------------------------
local function range(tbl, key)
    local lo, hi = math.huge, -math.huge
    for _, pt in ipairs(tbl) do
        lo = (pt[key] < lo) and pt[key] or lo
        hi = (pt[key] > hi) and pt[key] or hi
    end
    if lo == hi then lo, hi = lo-1, hi+1 end
    return lo, hi
end

local function fmt(val) -- simple thousands separator
    local s = tostring(math.floor(val))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Catmull-Rom spline sampler for one dimension
local function catmull(p0, p1, p2, p3, t)
    local t2, t3 = t*t, t*t*t
    return 0.5*((2*p1)
              + (-p0 + p2)*t
              + (2*p0 - 5*p1 + 4*p2 - p3)*t2
              + (-p0 + 3*p1 - 3*p2 + p3)*t3)
end

-- Produce screen-space points along the spline
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

------------------------------------------------------------------
--  PAINT
------------------------------------------------------------------
function PANEL:Paint(w, h)
    surface.SetFont(self.Font)

    -- 1 ▸ background
    --surface.SetDrawColor(self.BgColor)
    --surface.DrawRect(0, 0, w, h)

    if #self.Data < 2 then return end

    -- 2 ▸ data range
    local minX, maxX = range(self.Data, "x")
    local minY, maxY = range(self.Data, "y")

    -- 3 ▸ dynamic padding (left)
    local widest = 0
    for i = 0, self.TickY do
        local txt = fmt(Lerp(i/self.TickY, minY, maxY)) .. self.UnitY
        widest = math.max(widest, surface.GetTextSize(txt))
    end
    local padL, padR, padT = self.BasePad + widest,
                             self.BasePad,
                             self.BasePad
    local padB = self.BasePad + 14
    local gw, gh = w - padL - padR, h - padT - padB

    local mapX = function(x) return padL      + (x-minX)/(maxX-minX) * gw end
    local mapY = function(y) return h - padB - (y-minY)/(maxY-minY) * gh end

    -- 4 ▸ spline & polygon for fill mask
    local spline = buildSpline(mapX, mapY, self.Data, self.SamplesPerSeg)
    local poly   = {}
    for _, pt in ipairs(spline) do poly[#poly+1] = {x = pt.x, y = pt.y} end
    local baseY = h - padB
    for i = #spline, 1, -1 do
        poly[#poly+1] = {x = spline[i].x, y = baseY}
    end

    ----------------------------------------------------------------
    -- 5 ▸ gradient fill via stencil
    ----------------------------------------------------------------
    render.ClearStencil()
    render.SetStencilEnable(true)
        render.SetStencilWriteMask(1)
        render.SetStencilTestMask (1)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation  (STENCIL_KEEP)
        render.SetStencilZFailOperation (STENCIL_KEEP)
        render.SetStencilPassOperation  (STENCIL_REPLACE)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- ▸ build stencil one quad per segment
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

        -- ▸ restrict drawing to where stencil == 1
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation  (STENCIL_KEEP)

        -- vertical gradient (opaque at top → 0 α at base)
        surface.SetMaterial(Material("vgui/gradient-u"))   -- fades downward
        local lc = self.LineColor
        surface.SetDrawColor(lc.r, lc.g, lc.b, self.FillAlphaTop)
        surface.DrawTexturedRect(padL, padT, gw, gh)

    render.SetStencilEnable(false)

    -- 6 ▸ horizontal grid (drawn after gradient so lines stay visible)
    surface.SetDrawColor(self.AxisColor)
    for i = 0, self.TickY do
        local y = mapY(Lerp(i/self.TickY, minY, maxY))
        surface.DrawLine(padL, y, w-padR, y)
    end

    -- 7 ▸ smoothed curve (2-px)
    surface.SetDrawColor(self.LineColor)
    for i = 2, #spline do
        local p1, p2 = spline[i-1], spline[i]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
        surface.DrawLine(p1.x+1, p1.y, p2.x+1, p2.y)
    end

    -- 8 ▸ axes
    surface.SetDrawColor(200,200,200,120)
    surface.DrawLine(padL, h-padB, w-padR, h-padB) -- X
    surface.DrawLine(padL, padT,   padL,   h-padB) -- Y

    -- 9 ▸ ticks & labels
    local function drawTick(v, isX)
        if isX then
            local x  = mapX(v)
            local str = fmt(v)..self.UnitX
            local tw  = surface.GetTextSize(str)

            -- keep the label fully inside [padL , w-padR]
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

vgui.Register("Elib.Graph", PANEL, "DPanel")