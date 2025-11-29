// Script made by Eve Haddox
// discord evehaddox


///////////////////////
// Lines
///////////////////////
function Elib.DrawLineAnim() end
function Elib.DrawRoundedLineAnim() end
do
    local offset = 0
    local cooldown = 0
    local function DrawAnim(x, y, w, h, col)
        local stripeWidth = 10      -- width of each stripe in pixels
        local spacing     = 20      -- distance between stripes
        local angle       = 45
        local radians     = math.rad(angle)
        local d_x, d_y    = math.cos(radians), math.sin(radians)   -- direction of the stripe
        local n_x, n_y    = -d_y, d_x                              -- normal (perpendicular) to stripe

        if CurTime() > cooldown then
            offset = (offset + FrameTime() * 100) % spacing
            cooldown = CurTime() + FrameTime()
        end

        -- compute projection range of rectangle corners onto the normal vector
        local corners = {
            {x,       y},
            {x + w,   y},
            {x,     y + h},
            {x + w, y + h},
        }

        local minProj, maxProj = math.huge, -math.huge
        for _, c in ipairs(corners) do
            local cx, cy = c[1], c[2]
            local proj = (cx - x) * n_x + (cy - y) * n_y
            if proj < minProj then minProj = proj end
            if proj > maxProj then maxProj = proj end
        end

        -- draw stripes: choose a long enough line length to cover the rectangle
        local L = math.sqrt(w * w + h * h) + 64

        surface.SetDrawColor(col)

        local start = minProj - stripeWidth - L
        local finish = maxProj + stripeWidth + L
        local t = start + offset

        while t <= finish do
            for thick = 0, stripeWidth - 1 do
                local tt = t + thick
                local cx = x + tt * n_x
                local cy = y + tt * n_y

                local x1 = cx - d_x * L
                local y1 = cy - d_y * L
                local x2 = cx + d_x * L
                local y2 = cy + d_y * L

                surface.DrawLine(x1, y1, x2, y2)
            end
            t = t + spacing
        end
    end

    function Elib.DrawLineAnim(x, y, w, h, col1, col2)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- Draw background rect (this writes 1 into the stencil inside rect)
        surface.SetDrawColor(col1)
        surface.DrawRect(x, y, w, h)

        -- Now only draw where stencil == 1
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h, col2)

        render.SetStencilEnable(false)
    end

    function Elib.DrawEoundedLineAnim(rounded, x, y, w, h, col1, col2)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- Draw background rect (this writes 1 into the stencil inside rect)
        Elib.DrawRoundedBox(rounded, x, y, w, h, col1)

        -- Now only draw where stencil == 1
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h, col2)

        render.SetStencilEnable(false)
    end
end


///////////////////////
// Square Particles
///////////////////////
local function DrawBoxParticleAnim() end
local function DrawRoundedBoxParticleAnim() end
do
    local CSSBG = {
        Bubbles = {},
        generatedW = 0,
        generatedH = 0
    }

    CSSBG.Generate = function(w, h)
        CSSBG.Bubbles = {}
        CSSBG.generatedW = w
        CSSBG.generatedH = h

        local baseScale = h / 1080
        local areaFactor = (w * h) / (1920 * 1080)

        -- number of circles scales with area; keep within reasonable bounds
        local count = math.Clamp(math.floor(10 * areaFactor + 0.5), 8, 24)

        local now = RealTime()
        -- stagger spawn over a few seconds to avoid everything appearing at once
        local maxStagger = math.Clamp(3 * areaFactor, 1, 6) -- seconds

        for i = 1, count do
            local dur = math.Rand(10, 45)
            local size = math.Rand(15, 160)          -- "CSS px" base size (will be scaled later)
            local x = math.Rand(0.05, 0.95)          -- avoid being exactly on the edges
            local delay = math.Rand(0, dur)

            -- staggered spawn time (spread bubbles over maxStagger seconds) + small jitter
            local spawnBase = ((i - 1) / count) * maxStagger
            local spawnJitter = math.Rand(-maxStagger * 0.25, maxStagger * 0.25)
            local spawnTime = now + spawnBase + spawnJitter
            local spawnDur = math.Rand(0.3, 1.0) -- fade-in duration

            table.insert(CSSBG.Bubbles, {
                x = x,
                size = size,
                delay = delay,
                dur = dur,
                -- new spawn control:
                spawnTime = spawnTime,
                spawnDur = spawnDur,
            })
        end
    end


    local function DrawAnim(x, y, w, h)
        -- regenerate bubbles when resolution changes
        if CSSBG.generatedW ~= w or CSSBG.generatedH ~= h or #CSSBG.Bubbles == 0 then
            CSSBG.Generate(w, h)
        end

        local rt = RealTime()

        ----------------------------------------------------------------
        -- Circles animation
        ----------------------------------------------------------------
        local baseScale = h / 1080 -- scale from “CSS pixels” to screen height
        local travel    = 1000 * baseScale
        local offset    = 150  * baseScale

        for _, b in ipairs(CSSBG.Bubbles) do
            -- don't start rendering this bubble until its spawn time
            if b.spawnTime and rt < b.spawnTime then
                continue
            end

            local dur   = b.dur or 25
            local t     = (rt + (b.delay or 0)) % dur
            local frac  = t / dur  -- 0 → 1 over full animation

            -- Position: start below the screen (bottom: -150px) and move up
            local size  = b.size * baseScale
            local cx    = x + b.x * w
            local startY = y + h + offset
            local endY   = y - offset
            local cy     = Lerp(frac, startY, endY)

            -- Opacity: from ~0.2 alpha to 0 (CSS: rgba(255,255,255,0.2) → 0)
            local baseAlpha = 255 * 0.20
            local alpha     = baseAlpha * (1 - frac)

            -- apply spawn fade-in if within spawnDur
            if b.spawnTime then
                local spawnFrac = math.Clamp((rt - b.spawnTime) / (b.spawnDur or 0.6), 0, 1)
                alpha = alpha * spawnFrac
            end

            if alpha > 0 then
                -- Border radius: 0 → 50% (square → circle)
                local radius = (size / 2) * frac

                Elib.DrawRoundedBox(radius, cx - size / 2, cy - size / 2, size, size, Color(255, 255, 255, alpha))
            end
        end
    end

    function DrawBoxParticleAnim(x, y, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- Draw background rect (this writes 1 into the stencil inside rect)
        Elib.DrawRoundedBox(0, x, y, w, h, Elib.Colors.Background)

        -- Now only draw where stencil == 1
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h)

        render.SetStencilEnable(false)
    end

    function DrawRoundedBoxParticleAnim(rounded, x, y, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- Draw background rect (this writes 1 into the stencil inside rect)
        Elib.DrawRoundedBox(rounded, x, y, w, h, Elib.Colors.Stencil)

        -- Now only draw where stencil == 1
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h)

        render.SetStencilEnable(false)
    end
end


///////////////////////
// Moving Squares
///////////////////////
local function DrawMovingBoxAnim() end
local function DrawRoundedMovingBoxAnim() end
do
    local CubeData = {
        Particles = {},
        generatedW = 0,
        generatedH = 0
    }

    local whiteMat = Material("vgui/white")

    -- two cube border colors (like nth-child(2n) in the CSS)
    local cubeColorA = Color(0x00, 0x32, 0x98) -- #003298
    local cubeColorB = Color(0x00, 0x51, 0xF4) -- #0051F4

    CubeData.Generate = function(w, h)
        CubeData.Particles = {}
        CubeData.generatedW = w
        CubeData.generatedH = h

        local areaFactor = (w * h) / (1920 * 1080)

        -- Number of cubes based on area
        local count = math.Clamp(math.floor(10 * areaFactor + 0.5), 6, 24)

        local now = RealTime()
        local maxStagger = math.Clamp(3 * areaFactor, 1, 6) -- seconds

        for i = 1, count do
            local dur = math.Rand(8, 16)            -- around the CSS 12s
            local baseSize = math.Rand(8, 14)       -- CSS "10px" baseline-ish
            local maxScale = math.Rand(12, 24)      -- CSS: scale(20), we randomize a bit
            local x = math.Rand(0.05, 0.95)         -- 0–1, avoid hard edges
            local y = math.Rand(0.05, 0.95)

            local delay = math.Rand(0, dur)

            local spawnBase = ((i - 1) / count) * maxStagger
            local spawnJitter = math.Rand(-maxStagger * 0.25, maxStagger * 0.25)
            local spawnTime = now + spawnBase + spawnJitter
            local spawnDur = math.Rand(0.3, 1.0)

            -- don't start scale at 0: give each particle a small randomized starting scale
            local startScale = math.Rand(0.5, 2.0) -- start a bit larger than 0, slightly random

            CubeData.Particles[i] = {
                x = x,
                y = y,
                baseSize = baseSize,
                dur = dur,
                delay = delay,
                maxScale = maxScale,
                spawnTime = spawnTime,
                spawnDur = spawnDur,
                even = (i % 2 == 0), -- for alternating color
                startScale = startScale,
                -- housekeeping for respawn logic
                _recentlyRespawned = false
            }
        end
    end

    local function DrawAnim(x, y, w, h)
        -- regenerate particles when resolution changes
        if CubeData.generatedW ~= w or CubeData.generatedH ~= h or #CubeData.Particles == 0 then
            CubeData.Generate(w, h)
        end

        local rt = RealTime()
        local baseScale = h / 1080 -- resolution scaling

        for i, p in ipairs(CubeData.Particles) do
            -- wait until the particle is allowed to start
            if p.spawnTime and rt < p.spawnTime then
                continue
            end

            local dur   = p.dur or 12
            local t     = (rt + (p.delay or 0)) % dur
            local frac  = t / dur           -- 0 → 1
            local eased = frac * frac       -- approximate ease-in

            -- If the animation just restarted (frac very small), respawn/randomize the particle
            local justRestarted = frac < 0.02
            if rt >= (p.spawnTime or 0) then
                if justRestarted and not p._recentlyRespawned then
                    -- randomize position/size/scale for the next cycle
                    p.x = math.Rand(0.05, 0.95)
                    p.y = math.Rand(0.05, 0.95)
                    p.baseSize = math.Rand(8, 14)
                    p.maxScale = math.Rand(12, 24)
                    p.startScale = math.Rand(0.5, 2.0)
                    p.delay = math.Rand(0, dur)
                    p._recentlyRespawned = true
                elseif not justRestarted then
                    -- clear the flag so we can respawn next loop
                    p._recentlyRespawned = false
                end
            end

            -- Scale: start at a small randomized non-zero value and grow to maxScale
            local s0 = p.startScale or 0.8
            local target = p.maxScale or 20
            local scale = s0 + eased * (target - s0)

            local size  = (p.baseSize or 10) * baseScale * scale

            if size <= 0 then
                continue
            end

            -- Position (no movement, just scaling/rotating in place)
            local cx = x + p.x * w
            local cy = y + p.y * h

            -- Rotation: 0deg → 960deg
            local angle = 960 * eased

            -- Opacity: 1 → 0
            local alpha = 255 * (1 - eased)

            -- Spawn fade-in
            if p.spawnTime then
                local spawnFrac = math.Clamp((rt - p.spawnTime) / (p.spawnDur or 0.6), 0, 1)
                alpha = alpha * spawnFrac
            end

            if alpha <= 0 then
                continue
            end

            local colBase = p.even and cubeColorB or cubeColorA
            local col = Color(colBase.r, colBase.g, colBase.b, alpha)

            surface.SetMaterial(whiteMat)
            surface.SetDrawColor(col.r, col.g, col.b, col.a)
            surface.DrawTexturedRectRotated(cx, cy, size, size, angle)
        end
    end

    -- Draw inside a rectangular stencil clip
    function DrawMovingBoxAnim(x, y, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        -- This just defines the clipped area; use whatever bg color you want
        Elib.DrawRoundedBox(0, x, y, w, h, Elib.Colors.Background)

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h)

        render.SetStencilEnable(false)
    end

    -- Draw inside a rounded-rect stencil clip
    function DrawRoundedMovingBoxAnim(rounded, x, y, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        Elib.DrawRoundedBox(rounded, x, y, w, h, Elib.Colors.Stencil)

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        DrawAnim(x, y, w, h)

        render.SetStencilEnable(false)
    end
end


///////////////////////
// Triangle Pattern
///////////////////////
local function DrawTrianglePattern() end
local function DrawRoundedTrianglePattern() end
do
    local x = 1
end


///////////////////////
// Test
///////////////////////
hook.Add("HUDPaint", "Elib:EffectsTest", function()
    // Lines
    --Elib.DrawLineAnim(200, 200, 200, 400, Color(96, 109, 188), Color(70, 82, 152))
    --Elib.DrawEoundedLineAnim(6, 450, 200, 200, 400, Color(96, 109, 188), Color(70, 82, 152))

    // Square Particles
    --Elib.DrawRoundedBox(0, 200, 200, 200, 400, Elib.Colors.Background)
    --DrawBoxParticleAnim(200, 200, 200, 400)
    --Elib.DrawRoundedBox(6, 450, 200, 200, 400, Elib.Colors.Background)
    --DrawRoundedBoxParticleAnim(6, 450, 200, 200, 400)

    // Moving Squares
    --Elib.DrawRoundedBox(0, 200, 200, 200, 400, Elib.Colors.Background)
    --DrawMovingBoxAnim(200, 200, 200, 400)
    --Elib.DrawRoundedBox(6, 450, 200, 200, 400, Elib.Colors.Background)
    --DrawRoundedMovingBoxAnim(6, 450, 200, 200, 400)

    // Triangle Pattern
    
end)