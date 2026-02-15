// Script made by Eve Haddox
// discord evehaddox


local PANEL = {}
 
function PANEL:Init()
    -- left to right
    self.gradientH = Material("gui/gradient")
    -- top to bottom
    self.gradientV = Material("gui/gradient_down")
end
// snow particles
local particles = {}

for i = 1, 100 do
    table.insert(particles, {
        x = math.random(0, ScrW()),
        y = math.random(0, ScrH()),
        speed = math.random(20, 100),
        size = math.random(2, 6),
        alpha = math.random(100, 255)
    })
end

// beams
local beams = {}
local maxBeams = 10
local beamSpeed = 300 -- Speed of beam movement
local beamLength = 40 -- Fixed length of each beam
local explosionRadius = 20 -- Radius of explosion particles
local particleLifetime = 5 -- Time (in seconds) before particles disappear

-- Function to add a new beam
local function AddBeam()
    local startX = math.random(0, ScrW())
    local angle = math.random(11, 16) / 10 -- Random angle going downward
    table.insert(beams, {
        x = startX,
        y = 0, -- Start at the top of the screen
        angle = angle,
        distance = 0,
        exploded = false,
        particles = {},
        lifetime = 0 -- Tracks time since beam creation
    })
end

-- Generate initial beams
for i = 1, maxBeams do
    AddBeam()
end

// pixels
local staticPixels = {}
local pixelDensity = 4000 -- Number of static pixels
local staticOpacity = 50 -- Alpha of the static effect
local updateRate = 0.01 -- Fraction of pixels to refresh per update
local updateInterval = 0.1 -- Time (in seconds) to refresh some static noise
local lastUpdate = 0

-- Function to generate a random color within a range
local function RandomizeColor(baseColor, variation)
    local function Clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end

    return {
        r = Clamp(baseColor.r + math.random(-variation, variation), 0, 255),
        g = Clamp(baseColor.g + math.random(-variation, variation), 0, 255),
        b = Clamp(baseColor.b + math.random(-variation, variation), 0, 255)
    }
end

-- Initialize static noise
local function InitializeStatic()
    for i = 1, pixelDensity do
        table.insert(staticPixels, {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            size = math.random(1, 3),
            color = RandomizeColor({r = 200, g = 200, b = 200}, 55) -- Base color with variation
        })
    end
end

-- Function to update a fraction of static noise
local function UpdateStatic()
    local pixelsToUpdate = math.ceil(pixelDensity * updateRate)
    for i = 1, pixelsToUpdate do
        local index = math.random(1, #staticPixels)
        staticPixels[index] = {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            size = math.random(1, 3),
            color = RandomizeColor({r = 200, g = 200, b = 200}, 55) -- Base color with variation
        }
    end
end

InitializeStatic()

local snow, EnableBeams, static = true, false, false

// paint
function PANEL:Paint(w, h)

    // static noise
    if static then
        if SysTime() - lastUpdate > updateInterval then
            UpdateStatic()
            lastUpdate = SysTime()
        end

        for _, pixel in ipairs(staticPixels) do
            surface.SetDrawColor(pixel.color.r, pixel.color.g, pixel.color.b, staticOpacity)
            surface.DrawRect(pixel.x, pixel.y, pixel.size, pixel.size)
        end
    end

    // Draw the snow particles
    if snow then
        for _, p in ipairs(particles) do
            p.y = (p.y + p.speed * FrameTime()) % ScrH()
            Elib.DrawRoundedBox(p.size, p.x, p.y, p.size, p.size, Color(255, 255, 255, p.alpha))
        end
    end

    // Draw the beams
    if EnableBeams then
        for i = #beams, 1, -1 do
            local beam = beams[i]

            if not beam.exploded then
                -- Calculate the end position of the beam
                local endX = beam.x + math.cos(beam.angle) * beamLength
                local endY = beam.y + math.sin(beam.angle) * beamLength

                -- Draw the beam
                surface.SetDrawColor(255, 255, 255)
                surface.DrawLine(beam.x, beam.y, endX, endY)

                -- Check collision with screen bounds
                if endX < 0 or endX > w or endY < 0 or endY > h then
                    beam.exploded = true

                    -- Create particles on explosion
                    for j = 1, 20 do
                        local explosionAngle = math.random() * math.pi * 2
                        local particleSpeed = math.random(50, 150)
                        table.insert(beam.particles, {
                            x = endX,
                            y = endY,
                            angle = explosionAngle,
                            speed = particleSpeed,
                            lifetime = 0
                        })
                    end
                else
                    -- Move the beam forward
                    beam.x = beam.x + math.cos(beam.angle) * FrameTime() * beamSpeed
                    beam.y = beam.y + math.sin(beam.angle) * FrameTime() * beamSpeed
                    beam.lifetime = beam.lifetime + FrameTime()

                    -- Remove beam if it's too old
                    if beam.lifetime > 10 then
                        table.remove(beams, i)
                    end
                end
            else
                -- Handle particles
                for k = #beam.particles, 1, -1 do
                    local particle = beam.particles[k]

                    -- Update particle position
                    particle.x = particle.x + math.cos(particle.angle) * FrameTime() * particle.speed
                    particle.y = particle.y + math.sin(particle.angle) * FrameTime() * particle.speed
                    particle.speed = math.max(0, particle.speed - FrameTime() * 50)
                    particle.lifetime = particle.lifetime + FrameTime()

                    -- Draw particle
                    surface.SetDrawColor(255, 0, 0, 255)
                    surface.DrawRect(particle.x, particle.y, 2, 2)

                    -- Remove particle if it's too old
                    if particle.lifetime > particleLifetime then
                        table.remove(beam.particles, k)
                    end
                end

                -- Remove beam if all particles are gone
                if #beam.particles == 0 then
                    table.remove(beams, i)
                end
            end
        end

        if #beams < maxBeams then
            AddBeam()
        end
    end
end
 
vgui.Register("MenuBackgroundGradient", PANEL)

local PANEL = {}

---
-- Initialize defaults. We won't actually create the grid here yet,
-- because we don't know the panel size. We'll do that in PerformLayout.
function PANEL:Init()
    -- "Base" is how large the smaller dimension starts out in cells.
    -- e.g. if base=50, a square panel would have ~50 columns and 50 rows.
    -- You can raise/lower this number as you like.
    self.baseCells = 150
    
    -- We also define the alpha boundaries for the instant jump.
    self.alphaMin = 0
    self.alphaMax = 255
    
    self.spacing = 1
    
    -- We'll keep track of how many columns/rows we decided on last layout,
    -- so we only regenerate data if the count changes.
    self.lastCols = 0
    self.lastRows = 0
    
    -- We'll store the cell data in self.Grid, which is a 2D table:
    --   self.Grid[x][y] = { alpha = number, dir = 1/-1 }
    self.Grid = {}
end

---
-- Figure out how many columns and rows to use, so the cells stay as square
-- as possible. Then if that differs from our old count, regenerate the grid.
function PANEL:PerformLayout()
    local w, h = self:GetSize()
    if w <= 0 or h <= 0 then return end  -- Avoid weirdness if panel is 0-sized.
    
    -- We compute aspect ratio to decide how many columns vs rows:
    -- ratio = w / h. If ratio > 1, panel is wider than tall => more columns than rows.
    local ratio = w / h
    
    -- Start with "base" on the smaller dimension. So if ratio >= 1,
    -- that means height is the smaller dimension, so we set rows ~ baseCells
    -- and columns ~ baseCells * ratio (and vice-versa).
    
    local desiredRows, desiredCols
    if ratio >= 1 then
        -- Panel is wider than it is tall
        desiredRows = self.baseCells
        desiredCols = math.floor(self.baseCells * ratio + 0.5)
    else
        -- Panel is taller than it is wide
        desiredCols = self.baseCells
        desiredRows = math.floor(self.baseCells / ratio + 0.5)
    end
    
    -- If the new desired counts differ from the old ones, rebuild the grid data
    if desiredCols ~= self.lastCols or desiredRows ~= self.lastRows then
        self.lastCols = desiredCols
        self.lastRows = desiredRows
        self:RebuildGrid(desiredCols, desiredRows)
    end
    
    -- Now calculate each cell's width/height to stretch the entire panel dimension.
    -- You can either:
    --   (a) stretch the entire area exactly (rectangular cells if ratio != exact).
    --   (b) keep them perfect squares, centered, leaving blank space.
    --
    -- Below is approach (a): each cell will be as tall as (h / rowCount) and as wide
    -- as (w / colCount). This *may* make them rectangular if ratio changed the count.
    
    self.cellWidth  = (w - (self.lastCols - 1) * self.spacing) / self.lastCols
    self.cellHeight = (h - (self.lastRows - 1) * self.spacing) / self.lastRows
    
    -- If you absolutely want each cell to be a *perfect square*, you'll need to base
    -- the cell size on the smaller dimension and possibly center the grid. Let me know
    -- if you need that snippet specifically.
end

---
-- Builds (or rebuilds) the grid data with the specified number of columns and rows.
function PANEL:RebuildGrid(cols, rows)
    self.Grid = {}  -- wipe old data
    
    for x = 1, cols do
        self.Grid[x] = {}
        for y = 1, rows do
            self.Grid[x][y] = {
                -- Random starting alpha in [alphaMin, alphaMax]
                alpha = math.random(self.alphaMin, self.alphaMax),
                -- "dir" is 1 if we’re currently counting upward, -1 if downward.
                -- We'll use it to decide how alpha changes each Think() if we
                -- were slowly fading. But for instant jump, we only use it to
                -- know which boundary we’re traveling *toward*.
                dir   = (math.random(1, 2) == 1) and 1 or -1,
            }
        end
    end
end

---
-- Paint all cells as rectangles at their current alpha.
function PANEL:Paint(w, h)
    -- Loop over columns and rows
    for x = 1, self.lastCols do
        for y = 1, self.lastRows do
            local cell = self.Grid[x][y]
            if cell then
                --surface.SetDrawColor(math.random(190, 230), math.random(40, 60), math.random(200, 240), cell.alpha)
                surface.SetDrawColor(210, 50,220, cell.alpha)
                
                local xPos = (x - 1) * (self.cellWidth + self.spacing)
                local yPos = (y - 1) * (self.cellHeight + self.spacing)
                
                surface.DrawRect(xPos, yPos, self.cellWidth, self.cellHeight)
            end
        end
    end
end

---
-- Update the alpha for each cell. We *instantly jump* at the boundaries:
--   - If alpha goes below alphaMin, jump to alphaMax
--   - If alpha goes above alphaMax, jump to alphaMin
--
-- This produces a strobe/blink effect at the boundaries instead of a smooth fade.
function PANEL:Think()
    for x = 1, self.lastCols do
        for y = 1, self.lastRows do
            local cell = self.Grid[x][y]
            if cell then
                -- Move alpha by direction
                cell.alpha = cell.alpha + cell.dir
                
                -- Check boundaries
                if cell.alpha <= self.alphaMin then
                    -- Instantly jump to alphaMax
                    cell.alpha = self.alphaMax
                    cell.dir   = -1  -- now move downward
                elseif cell.alpha >= self.alphaMax then
                    -- Instantly jump to alphaMin
                    cell.alpha = self.alphaMin
                    cell.dir   = 1   -- now move upward
                end
            end
        end
    end
end

-- Finally, register the panel so we can create it via vgui.Create(...)
vgui.Register("Elib.BgEffect", PANEL)


--[[
local gridSize = 50
local particles = {}
local repelDistance = 100
local repelForce = 200
local maxSpeed = 30
local speed = 4

-- Set up particles
hook.Add("Initialize", "InitFloatingParticles", function()
    for x = 1, ScrW(), gridSize do
        particles[x] = {}
        for y = 1, ScrH(), gridSize do
            particles[x][y] = {
                px = x,
                py = y,
                vx = math.Rand(-10, 10),
                vy = math.Rand(-10, 10)
            }
        end
    end
end)

-- Update & Draw
hook.Add("HUDPaint", "DrawFloatingParticles", function()
    surface.SetDrawColor(255, 255, 255, 60)

    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local dt = FrameTime() * speed

    for x, col in pairs(particles) do
        for y, p in pairs(col) do
            -- Mouse interaction (repel)
            local dx = p.px - mouseX
            local dy = p.py - mouseY
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < repelDistance then
                local force = (repelDistance - dist) / repelDistance * repelForce
                local angle = math.atan2(dy, dx)
                p.vx = p.vx + math.cos(angle) * force * dt
                p.vy = p.vy + math.sin(angle) * force * dt
            end

            -- Update position
            p.px = p.px + p.vx * dt
            p.py = p.py + p.vy * dt

            -- Bounce off screen bounds
            if p.px <= 0 or p.px >= ScrW() then p.vx = -p.vx end
            if p.py <= 0 or p.py >= ScrH() then p.vy = -p.vy end

            -- Clamp speed a bit
            p.vx = math.Clamp(p.vx, -maxSpeed, maxSpeed)
            p.vy = math.Clamp(p.vy, -maxSpeed, maxSpeed)

            -- Draw cross lines
            surface.DrawLine(p.px - 5, p.py, p.px + 5, p.py)
            surface.DrawLine(p.px, p.py - 5, p.px, p.py + 5)
        end
    end
end)
]]
--hook.Remove("HUDPaint", "DrawFloatingParticles")

///////////////////
// Menu & Opening
///////////////////
local function CreateMenu()
    Elib.EffectsMenu = vgui.Create("Elib.Frame")
    Elib.EffectsMenu:SetTitle("Elib.Effects Menu")
    Elib.EffectsMenu:SetImageURL("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    Elib.EffectsMenu:SetSize(Elib.Scale(950), Elib.Scale(600))
    Elib.EffectsMenu:SetSizable(true)
    Elib.EffectsMenu:Center()
    Elib.EffectsMenu:SetRemoveOnClose(false)

    Elib.EffectsMenu.Content = Elib.EffectsMenu:Add("MenuBackgroundGradient")
    Elib.EffectsMenu.Content:Dock(FILL)

    Elib.EffectsMenu:MakePopup()
end

local function ToggleMenu(enable)
    if not IsValid(Elib.EffectsMenu) then
        CreateMenu()
        return
    end
    if not IsValid(Elib.EffectsMenu) then return end
    if Elib.EffectsMenu:IsVisible() then
        Elib.EffectsMenu:Close()
    else
        Elib.EffectsMenu:MakePopup()
    end
end

local function RefreshMenu()
    if IsValid(Elib.EffectsMenu) then Elib.EffectsMenu:Remove() CreateMenu() end
end

concommand.Add("Elib.Effects_menu", function()
    if not IsValid(Elib.EffectsMenu) then
        CreateMenu()
        return
    end
    if not IsValid(Elib.EffectsMenu) then return end
    if Elib.EffectsMenu:IsVisible() then
        Elib.EffectsMenu:Close()
    else
        Elib.EffectsMenu:MakePopup()
    end
end)


// Refreshing Menu to see updates in real time
RefreshMenu()