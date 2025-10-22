// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Pie Chart
///////////////////
local PANEL = {}

Elib.RegisterFont("Elib.PieChart.Procent", "Space Grotesk SemiBold", 22)

function PANEL:Init()
    self.Data = {}  -- Table to store data points
    self.Total = 0  -- Sum of all values for percentage calculation
    self.Radius = nil  -- Will be calculated based on panel size
    self.StartAngle = 0  -- Starting angle (0 = right)
    self.ArcCache = {}  -- Cache for arc calculations
    
    -- Default colors for sections
    self.Colors = {
        Color(204, 57, 41),   -- Red
        Color(41, 158, 204),  -- Blue
        Color(45, 180, 97),  -- Green
        Color(156, 68, 190),  -- Purple
        Color(221, 186, 46),  -- Yellow
        Color(52, 73, 94),    -- Dark Blue
        Color(199, 113, 38),  -- Orange
        Color(37, 190, 160)   -- Turquoise
    }
    
    self.ShowLegend = true
    self.LegendFont = "DermaDefault"
end

-- Add a single data point
function PANEL:AddDataPoint(value, label, color)
    color = color or self.Colors[(#self.Data % #self.Colors) + 1]
    
    table.insert(self.Data, {
        value = value,
        label = label or "",
        color = color
    })
    
    self.Total = self.Total + value
end

-- Set all data at once
function PANEL:SetData(data)
    self.Data = {}
    self.Total = 0
    
    for i, entry in ipairs(data) do
        local value = entry[1] or 0
        local label = entry[2] or ""
        local color = entry[3] or self.Colors[(i % #self.Colors) + 1]
        
        table.insert(self.Data, {
            value = value,
            label = label,
            color = color
        })
        
        self.Total = self.Total + value
    end
end

-- Set start angle (in degrees)
function PANEL:SetStartAngle(angle)
    self.StartAngle = angle
end

-- Toggle legend display
function PANEL:SetLegendVisible(visible)
    self.ShowLegend = visible
end

-- Draw a filled pie segment
function PANEL:DrawFilledPieSegment(x, y, radius, startAngle, endAngle, color)
    local vertices = {}
    local step = math.min(1, (endAngle - startAngle) / 36) -- Adjust step size for smoothness
    
    -- Add center vertex
    table.insert(vertices, {x = x, y = y})
    
    -- Add vertices for the arc
    for angle = startAngle, endAngle, step do
        local rad = math.rad(angle)
        table.insert(vertices, {
            x = x + math.cos(rad) * radius,
            y = y + math.sin(rad) * radius
        })
    end
    
    -- Add final vertex to complete the arc
    local rad = math.rad(endAngle)
    table.insert(vertices, {
        x = x + math.cos(rad) * radius,
        y = y + math.sin(rad) * radius
    })    

    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)

    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

    -- 4) Draw the "allowed" area
    surface.SetDrawColor(Elib.Colors.Stencil)
    draw.NoTexture()
    surface.DrawPoly(vertices)

    -- 5) Draw the "excluded" area (set stencil reference to 0 for excluded areas)
    render.SetStencilReferenceValue(0)
    --Elib.RNDX.DrawCircle(x, y, radius * .8, Elib.Colors.Stencil)
    Elib.DrawCircleUncached(x, y, 0, 360, 360, radius * .3)

    -- 6) Now switch to only drawing where the stencil == 1
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    -- 7) Draw Inside
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(vertices)

    local lc = Elib.OffsetColor(Elib.CopyColor(color), -30)
    Elib.DrawImage(x - radius, y - radius, radius * 2, radius * 2, "https://construct-cdn.physgun.com/images/1c1ed238-7a70-48ef-bcb2-ee0810162686.png", Color(lc.r, lc.g, lc.b))

    -- 8) Disable stencil
    render.SetStencilEnable(false)
    render.ClearStencil()
end

function PANEL:Paint(w, h)
    local centerX, centerY = w / 2, h / 2
    local radius = self.Radius or math.min(w, h) / 2 - 10
    
    -- Don't try to draw if there's no data or all values are 0
    if self.Total <= 0 then return end
    
    local currentAngle = self.StartAngle
    
    -- Draw the pie segments
    for i, data in ipairs(self.Data) do
        local percentage = data.value / self.Total
        local segmentAngle = percentage * 360
        
        -- Draw the pie segment using our custom function
        self:DrawFilledPieSegment(
            centerX, 
            centerY, 
            radius, 
            currentAngle, 
            currentAngle + segmentAngle, 
            data.color
        )
        
        -- Calculate position for percentage label (mid-point of arc)
        local midAngle = math.rad(currentAngle + segmentAngle/2)
        local labelRadius = radius * 0.7
        local labelX = centerX + math.cos(midAngle) * labelRadius
        local labelY = centerY + math.sin(midAngle) * labelRadius
        
        -- Only draw percentage label if segment is large enough
        if segmentAngle > 20 then
            local percentText = math.Round(percentage * 100) .. "%"
            Elib.DrawSimpleText(percentText, "Elib.PieChart.Procent", labelX, labelY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Move to next segment
        currentAngle = currentAngle + segmentAngle
    end
    
    -- Draw legend if enabled
    if self.ShowLegend and #self.Data > 0 then
        local legendX = 10
        local legendY = h - 10 - (#self.Data * 20)
        local boxSize = 15
        
        for i, data in ipairs(self.Data) do
            Elib.DrawRoundedBox(6, legendX, legendY, boxSize, boxSize, data.color)
            
            -- Calculate percentage text
            local percentage = math.Round((data.value / self.Total) * 100, 1)
            local labelText = data.label .. " (" .. percentage .. "%)"
            
            -- Draw label
            draw.SimpleText(labelText, self.LegendFont, legendX + boxSize + 5, legendY + boxSize/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            legendY = legendY + 20
        end
    end
end

vgui.Register("Elib.PieChart", PANEL, "DPanel")