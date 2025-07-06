///////////////////////
// Shaking
///////////////////////
local function DrawShakingText(text, font, x, y, color, time, intensity)
    surface.SetFont(font)
    
    local offsetX = x
    intensity = intensity or 1.05
    time = time or CurTime() * 1.8
    
    for i = 1, #text do
        local char = text[i]
        
        local shakeX = math.sin(time * 10 + i * 1.3) * intensity
        local shakeY = math.cos(time * 10 + i * 2.1) * intensity

        local w, h = surface.GetTextSize(char)
        
        surface.SetTextColor(color)
        surface.SetTextPos(offsetX + shakeX, y + shakeY)
        surface.DrawText(char)
        
        offsetX = offsetX + w
    end
end

///////////////////////
// Waving
///////////////////////
local function DrawWavingText(text, font, x, y, color, time, intensity)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local offsetX = x
    intensity = intensity or 3
    time = time or CurTime()

    for i = 1, #text do
        local char = text[i]
        local w, h = surface.GetTextSize(char)
        local waveY = math.sin(time * 5 + i * 0.5) * intensity

        surface.SetTextPos(offsetX, y + waveY)
        surface.DrawText(char)

        offsetX = offsetX + w
    end
end

///////////////////////
// Waving Sides
///////////////////////
local function DrawIteratingHorizontalRippleText(text, font, x, y, color, time, amplitude, speed, wavelength)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local offsetX = x

    for i = 1, #text do
        local char = text[i]
        local w, h = surface.GetTextSize(char)

        -- horizontal shift, moving along text
        local offset = math.sin((time * speed) + i * wavelength) * amplitude

        surface.SetTextPos(offsetX + offset, y)
        surface.DrawText(char)

        offsetX = offsetX + w
    end
end

///////////////////////
// Iterating
///////////////////////
local lastWaveStart = 0

local function DrawSequentialJumpText_SingleWave(
    text, font, x, y, color,
    time, jumpDuration, spacing, amplitude, delayBetweenWaves
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local waveLength = (#text - 1) * spacing + jumpDuration

    -- Check if we need to start a new wave
    if (time - lastWaveStart) > (waveLength + delayBetweenWaves) then
        lastWaveStart = time
    end

    local timeInWave = time - lastWaveStart

    local offsetX = x

    for i = 1, #text do
        local char = text[i]
        local w, h = surface.GetTextSize(char)

        -- Calculate when this character's jump starts and ends
        local charStart = (i - 1) * spacing
        local charEnd = charStart + jumpDuration

        local offsetY = 0

        if timeInWave >= charStart and timeInWave <= charEnd then
            -- Animate the jump using sine curve
            local t = (timeInWave - charStart) / jumpDuration
            offsetY = -math.sin(t * math.pi) * amplitude
        end

        surface.SetTextPos(offsetX, y + offsetY)
        surface.DrawText(char)

        offsetX = offsetX + w
    end
end

///////////////////////
// Flipping
///////////////////////
local lastFlipStart = 0

local function DrawFlippingLetterText(
    text, font, x, y, color,
    time, flipDuration, spacing, delayBetweenFlips
)
    surface.SetFont(font)

    color = color or Color(255, 255, 255)
    time = time or CurTime()
    flipDuration = flipDuration or 0.5
    spacing = spacing or 0.05
    delayBetweenFlips = delayBetweenFlips or 0.5

    local waveLength = (#text - 1) * spacing + flipDuration

    if (time - lastFlipStart) > (waveLength + delayBetweenFlips) then
        lastFlipStart = time
    end

    local timeInWave = time - lastFlipStart

    local offsetX = x

    for i = 1, #text do
        local char = text[i]
        local w, h = surface.GetTextSize(char)

        local charStart = (i - 1) * spacing
        local charEnd = charStart + flipDuration

        local scaleX = 1
        local drawChar = char

        if timeInWave >= charStart and timeInWave <= charEnd then
            local t = (timeInWave - charStart) / flipDuration

            if t <= 0.5 then
                -- First half → scale down
                scaleX = 1 - (t * 2)
                drawChar = char
            else
                -- Second half → scale up and swap letter
                scaleX = (t - 0.5) * 2
                -- Draw mirrored version or a different color if you wish
                drawChar = string.reverse(char)
            end

            scaleX = math.Clamp(scaleX, 0.01, 1)
        end

        -- Matrix transform
        local mat = Matrix()
        mat:Translate(Vector(offsetX + w/2, y + h/2, 0))
        mat:Scale(Vector(scaleX, 1, 1))
        mat:Translate(Vector(-(offsetX + w/2), -(y + h/2), 0))

        cam.PushModelMatrix(mat)
            surface.SetTextColor(color.r, color.g, color.b, color.a or 255)
            surface.SetTextPos(offsetX, y)
            surface.DrawText(drawChar)
        cam.PopModelMatrix()

        offsetX = offsetX + w
    end
end

///////////////////////
// Gradient
///////////////////////
local GradientTextPanel = nil

-- Create the panel once
local function EnsureGradientPanel()
    if IsValid(GradientTextPanel) then return end

    GradientTextPanel = vgui.Create("DHTML")
    GradientTextPanel:SetSize(512, 128)
    GradientTextPanel:SetMouseInputEnabled(false)
    GradientTextPanel:SetPaintedManually(true)
end

-- Function to draw gradient text anywhere
function DrawGradientText(text, fontSize, x, y, gradientCSS, width, height)

    EnsureGradientPanel()

    width = width or 512
    height = height or 128

    GradientTextPanel:SetSize(width, height)

    local htmlTemplate = [[
        <html>
        <body style="
            margin:0;
            padding:0;
            background:transparent;
        ">
            <span style="
                display:inline-block;
                background: %s;
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                font-size: %dpx;
                font-family: Arial, sans-serif;
                font-weight: bold;
            ">
                %s
            </span>
        </body>
        </html>
    ]]

    local html = string.format(htmlTemplate, gradientCSS, fontSize, text)
    GradientTextPanel:SetHTML(html)

    GradientTextPanel:SetPos(x, y)
    GradientTextPanel:PaintManual()
end


///////////////////////
// Rainbow
///////////////////////
local RainbowGradientPanel = nil
local lastParams = {}

local function EstimateTextSize(text, fontSize)
    local charWidth = fontSize * 0.65
    local textWidth = math.max(#text * charWidth + 20, 100)
    local textHeight = fontSize * 1.4
    return textWidth, textHeight
end

local function EnsureRainbowPanel(text, fontSize, font, speed, align)
    text = text or "RAINBOW"
    fontSize = fontSize or 64
    font = font or "Arial"
    speed = speed or 15
    align = align or TEXT_ALIGN_LEFT

    local paramsKey = table.concat({
        text, fontSize, font, speed, align
    }, "|")

    if IsValid(RainbowGradientPanel) and lastParams.key == paramsKey then
        return
    end

    lastParams.key = paramsKey

    if not IsValid(RainbowGradientPanel) then
        RainbowGradientPanel = vgui.Create("DHTML")
        RainbowGradientPanel:SetMouseInputEnabled(false)
        RainbowGradientPanel:SetPaintedManually(true)
    end

    local textAlign = "left"
    if align == TEXT_ALIGN_CENTER then
        textAlign = "center"
    elseif align == TEXT_ALIGN_RIGHT then
        textAlign = "right"
    end

    local rainbowHTML = string.format([[
        <html>
        <head>
        <style>
        @keyframes gradientAnim {
            0%% { background-position: 0%% 50%%; }
            100%% { background-position: 100%% 50%%; }
        }
        .gradient-text {
            background: linear-gradient(
                270deg,
                red,
                orange,
                yellow,
                green,
                cyan,
                blue,
                violet,
                red
            );
            background-size: 800%% 800%%;
            animation: gradientAnim %.2fs linear infinite;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: %dpx;
            font-family: '%s', sans-serif;
            font-weight: bold;
            display: inline-block;
            text-align: %s;
        }
        body {
            margin: 0;
            padding: 0;
            background: transparent;
            overflow: hidden;
        }
        </style>
        </head>
        <body>
            <span class="gradient-text">%s</span>
        </body>
        </html>
    ]],
        speed,
        fontSize,
        font,
        textAlign,
        text
    )

    RainbowGradientPanel:SetHTML(rainbowHTML)
end

function DrawRainbowGradientText(text, fontSize, font, speed, align, x, y, width, height)
    text = text or "RAINBOW"
    fontSize = fontSize or 64
    font = font or "Arial"
    speed = speed or 15
    align = align or TEXT_ALIGN_LEFT
    x = x or 100
    y = y or 100

    if not width or not height then
        width, height = EstimateTextSize(text, fontSize)
    end

    EnsureRainbowPanel(text, fontSize, font, speed, align)

    RainbowGradientPanel:SetSize(width, height)
    RainbowGradientPanel:SetPos(x, y)
    RainbowGradientPanel:PaintManual()
end

///////////////////////
// Shimmer
///////////////////////
local ShimmerLetterPanel = nil
local lastShimmerTime = 0

local function EscapeHTML(str)
    return str
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
        :gsub('"', "&quot;")
        :gsub("'", "&#39;")
end

local function CreateShimmerHTML(text, fontSize, font, duration, baseColor, align, intensity)
    local textAlign = "left"
    if align == TEXT_ALIGN_CENTER then
        textAlign = "center"
    elseif align == TEXT_ALIGN_RIGHT then
        textAlign = "right"
    end

    -- Build shimmering letters
    local spans = {}
    for i = 1, #text do
        local char = EscapeHTML(text:sub(i, i))
        table.insert(spans, string.format(
            [[<span class="shimmer-letter">%s</span>]],
            char
        ))
    end

    local lettersHTML = table.concat(spans, "")

    local html = string.format([[
        <html>
        <head>
        <style>
        @keyframes shimmerLetter {
            0%% {
                background-position: -200%% -200%%;
                opacity: 0;
            }
            10%% {
                opacity: 1;
            }
            100%% {
                background-position: 200%% 200%%;
                opacity: 0;
            }
        }
        .base-text {
            color: %s;
            position: absolute;
            left: 0;
            top: 0;
        }
        .shimmer-text {
            position: absolute;
            left: 0;
            top: 0;
        }
        .shimmer-letter {
            color: %s;
            background: linear-gradient(
                135deg,
                rgba(255,255,255,0) 20%%,
                rgba(255,255,255,%.3f) 40%%,
                rgba(255,255,255,%.3f) 60%%,
                rgba(255,255,255,0) 80%%);
            background-size: 200%% 200%%;
            background-repeat: no-repeat;
            background-position: -200%% -200%%;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: shimmerLetter %.2fs ease-out 1;
            display: inline-block;
            white-space: pre;
        }
        .container {
            position: relative;
            width: max-content;
            height: max-content;
            font-size: %dpx;
            font-family: '%s', sans-serif;
            font-weight: bold;
            text-align: %s;
            white-space: nowrap;
        }
        body {
            margin: 0;
            padding: 0;
            background: transparent;
            overflow: hidden;
        }
        </style>
        </head>
        <body>
            <div class="container">
                <span class="base-text">%s</span>
                <span class="shimmer-text">%s</span>
            </div>
        </body>
        </html>
    ]],
        baseColor,
        baseColor,
        intensity,
        intensity,
        duration,
        fontSize,
        font,
        textAlign,
        EscapeHTML(text),
        lettersHTML
    )

    return html
end

function DrawShimmerLetterText(
    text, fontSize, font,
    x, y,
    align, baseColor,
    speed, frequency, intensity,
    width, height
)
    -- Defaults
    text = text or "SHIMMER"
    fontSize = fontSize or 24
    font = font or "Arial"
    x = x or 100
    y = y or 100
    align = align or TEXT_ALIGN_LEFT
    baseColor = baseColor or "#ffffff"
    speed = speed or 1.0
    frequency = frequency or 0.33
    intensity = intensity or 0.8

    intensity = math.Clamp(intensity, 0, 1)

    local period = (1 / frequency)
    local cooldown = math.max(0, period - speed)

    local charWidth = fontSize * 0.7
    width = width or math.max(#text * charWidth + 20, 100)
    height = height or fontSize * 1.6

    if not IsValid(ShimmerLetterPanel) then
        ShimmerLetterPanel = vgui.Create("DHTML")
        ShimmerLetterPanel:SetMouseInputEnabled(false)
        ShimmerLetterPanel:SetPaintedManually(true)
    end

    local now = CurTime()
    if now - lastShimmerTime >= speed + cooldown then
        local html = CreateShimmerHTML(
            text, fontSize, font,
            speed, baseColor, align, intensity
        )
        ShimmerLetterPanel:SetHTML(html)
        lastShimmerTime = now
    end

    ShimmerLetterPanel:SetSize(width, height)
    ShimmerLetterPanel:SetPos(x, y)
    ShimmerLetterPanel:PaintManual()
end

///////////////////////
// Chromatic
///////////////////////
local chromaNextTime = 0
local chromaOffsets = {}

local function DrawChromaticAberrationText(text, font, x, y, intensity, time, speed)
    surface.SetFont(font)

    intensity = intensity or 2
    speed = speed or 5
    time = time or CurTime()

    -- If time to update, randomize new offsets
    if time >= chromaNextTime then
        chromaOffsets = {
            {math.Rand(-intensity, intensity), math.Rand(-intensity, intensity)}, -- Red
            {math.Rand(-intensity, intensity), math.Rand(-intensity, intensity)}, -- Green
            {math.Rand(-intensity, intensity), math.Rand(-intensity, intensity)}, -- Blue
        }
        local randomFactor = math.Rand(0.7, 1.3)
        chromaNextTime = time + randomFactor * (1 / speed)
    end

    local channels = {
        {255, 0, 0},   -- Red
        {0, 255, 0},   -- Green
        {0, 0, 255},   -- Blue
    }

    for i, color in ipairs(channels) do
        local ox, oy = unpack(chromaOffsets[i])
        surface.SetTextColor(color[1], color[2], color[3], 255)
        surface.SetTextPos(x + ox, y + oy)
        surface.DrawText(text)
    end

    -- Base white text on top
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

///////////////////////
// Glitch
///////////////////////
local glitchNextUpdate = 0
local glitchCurrentText = ""
local glitchChars = {}
local glitchPositions = {}

-- Define characters you want to randomly inject
local glitchSet = {}
do
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local numbers = "0123456789"
    local symbols = "@#$%&*+?/=~"

    glitchSet = {}
    for i = 1, #letters do table.insert(glitchSet, letters:sub(i,i)) end
    for i = 1, #numbers do table.insert(glitchSet, numbers:sub(i,i)) end
    for i = 1, #symbols do table.insert(glitchSet, symbols:sub(i,i)) end
end

local function DrawGlitchText(text, font, x, y, color, time, glitchSpeed, glitchIntensity)
    surface.SetFont(font)
    surface.SetTextColor(color)

    glitchSpeed = glitchSpeed or 15         -- how many updates per second
    glitchIntensity = glitchIntensity or 0.2 -- % of letters glitching (e.g. 0.2 = 20%)
    time = time or CurTime()

    -- Time to update glitch?
    if time >= glitchNextUpdate then
        glitchNextUpdate = time + (1 / glitchSpeed)

        glitchCurrentText = {}
        glitchPositions = {}

        for i = 1, #text do
            if math.Rand(0, 1) < glitchIntensity then
                -- replace this character with random glitch char
                local randomChar = glitchSet[math.random(#glitchSet)]
                table.insert(glitchCurrentText, randomChar)
                table.insert(glitchPositions, i)
            else
                table.insert(glitchCurrentText, text:sub(i, i))
            end
        end
    end

    -- Join table into final string
    local displayText = table.concat(glitchCurrentText, "")

    surface.SetTextPos(x, y)
    surface.DrawText(displayText)
end

///////////////////////
// Chromatic Glitch
///////////////////////
local chromaGlitchNextTime = 0
local chromaGlitchOffsets = {}
local chromaGlitchText = ""

local glitchSet = {}
do
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local numbers = "0123456789"
    local symbols = "@#$%&*+?/=~"

    for i = 1, #letters do table.insert(glitchSet, letters:sub(i,i)) end
    for i = 1, #numbers do table.insert(glitchSet, numbers:sub(i,i)) end
    for i = 1, #symbols do table.insert(glitchSet, symbols:sub(i,i)) end
end

local function DrawChromaticGlitchText(text, font, x, y, time, chromaIntensity, glitchSpeed, glitchIntensity, chromaSpeed)
    surface.SetFont(font)

    chromaIntensity = chromaIntensity or 2
    glitchSpeed = glitchSpeed or 15
    glitchIntensity = glitchIntensity or 0.2
    chromaSpeed = chromaSpeed or 5
    time = time or CurTime()

    -- Check if it's time to update
    if time >= chromaGlitchNextTime then
        -- Generate one glitched string
        local glitched = {}
        for i = 1, #text do
            if math.Rand(0, 1) < glitchIntensity then
                local randChar = glitchSet[math.random(#glitchSet)]
                table.insert(glitched, randChar)
            else
                table.insert(glitched, text:sub(i, i))
            end
        end
        chromaGlitchText = table.concat(glitched, "")

        -- Generate separate offsets for each channel
        chromaGlitchOffsets = {
            { math.Rand(-chromaIntensity, chromaIntensity), math.Rand(-chromaIntensity, chromaIntensity) }, -- Red
            { math.Rand(-chromaIntensity, chromaIntensity), math.Rand(-chromaIntensity, chromaIntensity) }, -- Green
            { math.Rand(-chromaIntensity, chromaIntensity), math.Rand(-chromaIntensity, chromaIntensity) }  -- Blue
        }

        -- Randomize interval slightly
        local interval = math.Rand(0.7, 1.3) * (1 / math.max(glitchSpeed, chromaSpeed))
        chromaGlitchNextTime = time + interval
    end

    local channels = {
        {255, 0, 0},   -- Red
        {0, 255, 0},   -- Green
        {0, 0, 255},   -- Blue
    }

    for i, color in ipairs(channels) do
        local ox, oy = unpack(chromaGlitchOffsets[i])
        surface.SetTextColor(color[1], color[2], color[3], 255)
        surface.SetTextPos(x + ox, y + oy)
        surface.DrawText(chromaGlitchText)
    end

    -- Base white text on top
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(x, y)
    surface.DrawText(chromaGlitchText)
end

///////////////////////
// Deciphering
///////////////////////
local decipherStates = {}

local glitchSet = {}
do
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local numbers = "0123456789"
    local symbols = "@#$%&*+?/=~"

    glitchSet = {}
    for i = 1, #letters do table.insert(glitchSet, letters:sub(i,i)) end
    for i = 1, #numbers do table.insert(glitchSet, numbers:sub(i,i)) end
    for i = 1, #symbols do table.insert(glitchSet, symbols:sub(i,i)) end
end

local function DrawDecipherText(
    key,           -- unique key for this text block
    text, font, x, y,
    colorRandom,   -- color for flickering letters
    time,
    speed,         -- letters per second
    loop,          -- true/false
    loopDelay,     -- delay before restarting (seconds)
    colorRevealed  -- optional color for revealed text
)
    surface.SetFont(font)

    speed = speed or 10
    loop = loop or false
    loopDelay = loopDelay or 0.5
    colorRevealed = colorRevealed or colorRandom
    time = time or CurTime()

    if not decipherStates[key] then
        decipherStates[key] = {
            revealProgress = 0,
            nextRevealTime = time,
            fullyRevealedUntil = nil,
            displayChars = {}
        }
    end

    local state = decipherStates[key]

    -- Handle progress
    if state.fullyRevealedUntil then
        if time >= state.fullyRevealedUntil then
            state.revealProgress = 0
            state.nextRevealTime = time + (1 / speed)
            state.fullyRevealedUntil = nil
        end
    else
        if time >= state.nextRevealTime then
            if state.revealProgress < #text then
                state.revealProgress = state.revealProgress + 1
                state.nextRevealTime = time + (1 / speed)
            elseif loop then
                -- start loop delay
                state.fullyRevealedUntil = time + loopDelay
            end
        end
    end

    -- Build text segments
    local revealedText = ""
    local glitchText = ""

    for i = 1, #text do
        if i <= state.revealProgress then
            revealedText = revealedText .. text:sub(i, i)
        else
            glitchText = glitchText .. glitchSet[math.random(#glitchSet)]
        end
    end

    -- Draw revealed text
    surface.SetTextColor(colorRevealed.r, colorRevealed.g, colorRevealed.b, colorRevealed.a or 255)
    surface.SetTextPos(x, y)
    surface.DrawText(revealedText)

    -- Measure revealed text width for offset
    local revealedWidth = 0
    if #revealedText > 0 then
        revealedWidth = surface.GetTextSize(revealedText)
    end

    -- Draw glitching text
    if #glitchText > 0 then
        surface.SetTextColor(colorRandom.r, colorRandom.g, colorRandom.b, colorRandom.a or 255)
        surface.SetTextPos(x + revealedWidth, y)
        surface.DrawText(glitchText)
    end
end

///////////////////////
// Typing
///////////////////////
local typingStates = {}

local function DrawTypingText(
    key, text, font, x, y,
    color,
    time,
    speed,
    loop,
    loopDelay,
    cursorChar
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    speed = speed or 15
    loop = loop or false
    loopDelay = loopDelay or 0.5
    cursorChar = cursorChar or ""

    time = time or CurTime()

    if not typingStates[key] then
        typingStates[key] = {
            progress = 0,
            nextRevealTime = time,
            fullyRevealedUntil = nil,
        }
    end

    local state = typingStates[key]

    if state.fullyRevealedUntil then
        if time >= state.fullyRevealedUntil then
            state.progress = 0
            state.nextRevealTime = time + (1 / speed)
            state.fullyRevealedUntil = nil
        end
    else
        if time >= state.nextRevealTime then
            if state.progress < #text then
                state.progress = state.progress + 1
                state.nextRevealTime = time + (1 / speed)
            elseif loop then
                state.fullyRevealedUntil = time + loopDelay
            end
        end
    end

    local visibleText = text:sub(1, state.progress)

    if cursorChar ~= "" then
        if state.progress < #text then
            visibleText = visibleText .. cursorChar
        else
            if math.floor(time * 2) % 2 == 0 then
                visibleText = visibleText .. cursorChar
            end
        end
    end

    surface.SetTextPos(x, y)
    surface.DrawText(visibleText)
end

///////////////////////
// Typing Human
///////////////////////
local typingHumanStates = {}

local function generateTypingDelays(text)
    local delays = {}
    for i = 1, #text do
        local char = text:sub(i, i)

        local delay
        if char:match("[%.,%?!]") then
            delay = math.Rand(0.25, 0.5)
        elseif char == " " then
            delay = math.Rand(0.08, 0.2)
        else
            delay = math.Rand(0.03, 0.12)
        end

        -- Add random small variation to mimic stuttering
        if math.Rand(0, 1) < 0.3 then
            -- Apply ± variation of up to 20% of the delay
            local jitter = delay * math.Rand(-0.2, 0.2)
            delay = math.max(0.01, delay + jitter)
        end

        table.insert(delays, delay)
    end
    return delays
end

local function DrawTypingTextHuman(
    key, text, font, x, y,
    color,
    time,
    loop,
    loopDelay,
    cursorChar
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    loop = loop or false
    loopDelay = loopDelay or 1.0
    cursorChar = cursorChar or ""
    time = time or CurTime()

    if not typingHumanStates[key] then
        typingHumanStates[key] = {
            progress = 0,
            nextRevealTime = time,
            delays = generateTypingDelays(text),
            fullyRevealedUntil = nil,
        }
    end

    local state = typingHumanStates[key]

    if state.fullyRevealedUntil then
        if time >= state.fullyRevealedUntil then
            state.progress = 0
            state.nextRevealTime = time
            state.delays = generateTypingDelays(text)
            state.fullyRevealedUntil = nil
        end
    else
        if time >= state.nextRevealTime then
            if state.progress < #text then
                state.progress = state.progress + 1
                local delay = state.delays[state.progress] or 0.05
                state.nextRevealTime = time + delay
            elseif loop then
                state.fullyRevealedUntil = time + loopDelay
            end
        end
    end

    local visibleText = text:sub(1, state.progress)

    if cursorChar ~= "" then
        if state.progress < #text then
            visibleText = visibleText .. cursorChar
        else
            if math.floor(time * 2) % 2 == 0 then
                visibleText = visibleText .. cursorChar
            end
        end
    end

    surface.SetTextPos(x, y)
    surface.DrawText(visibleText)
end

///////////////////////
// Typing Human & Mistakes
///////////////////////
local typingHumanMistakeStates = {}

local function generateTypingDelays(text, mistakeMap)
    local delays = {}
    local i = 1
    while i <= #text do
        local char = text:sub(i, i)

        local delay
        if char:match("[%.,%?!]") then
            delay = math.Rand(0.25, 0.5)
        elseif char == " " then
            delay = math.Rand(0.08, 0.2)
        else
            delay = math.Rand(0.03, 0.12)
        end

        -- Random jitter
        if math.Rand(0, 1) < 0.3 then
            local jitter = delay * math.Rand(-0.2, 0.2)
            delay = math.max(0.01, delay + jitter)
        end

        table.insert(delays, delay)

        -- For each mistake, we have extra delays:
        if mistakeMap and mistakeMap[i] then
            -- Pause after typing the wrong letter
            table.insert(delays, math.Rand(0.2, 0.4))
        end

        i = i + 1
    end
    return delays
end

local function DrawTypingTextHumanAdvanced(
    key, text, font, x, y,
    color,
    time,
    loop,
    loopDelay,
    cursorChar,
    mistakeMap
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    loop = loop or false
    loopDelay = loopDelay or 1.0
    cursorChar = cursorChar or ""
    time = time or CurTime()

    if not typingHumanMistakeStates[key] then
        typingHumanMistakeStates[key] = {
            progress = 0,
            nextRevealTime = time,
            delays = generateTypingDelays(text, mistakeMap),
            fullyRevealedUntil = nil,
            displayText = "",
            mistakeMap = mistakeMap,
            madeMistake = {},
            step = "normal",
            targetPos = 1,
            errorStartPos = nil,
            errorTypedChars = 0,
            typedPastMistake = "",
        }
    end

    local state = typingHumanMistakeStates[key]

    if state.fullyRevealedUntil then
        if time >= state.fullyRevealedUntil then
            -- Reset for loop
            state.progress = 0
            state.nextRevealTime = time
            state.delays = generateTypingDelays(text, mistakeMap)
            state.displayText = ""
            state.madeMistake = {}
            state.step = "normal"
            state.targetPos = 1
            state.errorStartPos = nil
            state.errorTypedChars = 0
            state.typedPastMistake = ""
            state.fullyRevealedUntil = nil
        end
    else
        if time >= state.nextRevealTime then
            state.progress = state.progress + 1

            if state.step == "wrong_letter" then
                local mistake = state.mistakeMap[state.targetPos]
                state.displayText = state.displayText .. mistake.wrong

                -- Save where mistake started
                state.errorStartPos = state.targetPos

                -- Decide how many letters we'll type past the error before correcting
                state.errorTypedChars = math.random(0, 6)
                state.typedPastMistake = ""
                state.step = "typing_past_mistake"
                state.nextRevealTime = time + state.delays[state.progress] or 0.1

            elseif state.step == "typing_past_mistake" then
                if state.errorTypedChars > 0 and state.targetPos < #text then
                    -- type next letter past the mistake
                    local nextChar = text:sub(state.targetPos + 1, state.targetPos + 1)
                    state.displayText = state.displayText .. nextChar
                    state.typedPastMistake = state.typedPastMistake .. nextChar
                    state.targetPos = state.targetPos + 1
                    state.errorTypedChars = state.errorTypedChars - 1
                    state.nextRevealTime = time + state.delays[state.progress] or 0.05
                else
                    state.step = "backspacing"
                    state.nextRevealTime = time + 0.1
                end

            elseif state.step == "backspacing" then
                -- remove one character at a time
                if #state.displayText > state.errorStartPos - 1 then
                    state.displayText = state.displayText:sub(1, -2)
                    state.nextRevealTime = time + 0.05
                else
                    state.step = "correct_letter"
                    state.nextRevealTime = time + 0.05
                end

            elseif state.step == "correct_letter" then
                -- type the correct letter
                local mistake = state.mistakeMap[state.errorStartPos]
                state.displayText = state.displayText .. mistake.right
                state.step = "retype_past"
                state.nextRevealTime = time + 0.05

            elseif state.step == "retype_past" then
                if #state.typedPastMistake > 0 then
                    local nextChar = state.typedPastMistake:sub(1,1)
                    state.displayText = state.displayText .. nextChar
                    state.typedPastMistake = state.typedPastMistake:sub(2)
                    state.nextRevealTime = time + 0.05
                else
                    -- done fixing
                    state.targetPos = state.targetPos + 1
                    state.step = "normal"
                    state.nextRevealTime = time + 0.05
                end

            else
                -- Normal typing
                if state.targetPos > #text then
                    if loop then
                        state.fullyRevealedUntil = time + loopDelay
                    end
                    state.nextRevealTime = math.huge
                else
                    if mistakeMap and mistakeMap[state.targetPos] and not state.madeMistake[state.targetPos] then
                        -- initiate mistake
                        state.step = "wrong_letter"
                        state.madeMistake[state.targetPos] = true
                        state.nextRevealTime = time
                    else
                        -- type normal char
                        local nextChar = text:sub(state.targetPos, state.targetPos)
                        if nextChar ~= "" then
                            state.displayText = state.displayText .. nextChar
                        end
                        state.targetPos = state.targetPos + 1
                        state.nextRevealTime = time + (state.delays[state.progress] or 0.05)
                    end
                end
            end
        end
    end

    local visibleText = state.displayText

    if cursorChar ~= "" then
        if state.displayText ~= text then
            visibleText = visibleText .. cursorChar
        else
            if math.floor(time * 2) % 2 == 0 then
                visibleText = visibleText .. cursorChar
            end
        end
    end

    surface.SetTextPos(x, y)
    surface.DrawText(visibleText)
end

///////////////////////
// Growing
///////////////////////
local generatedFonts = {}

local function GetDynamicFont(baseFont, targetSize)
    local key = baseFont .. "_" .. math.floor(targetSize)
    if generatedFonts[key] then return key end

    surface.CreateFont(key, {
        font = baseFont,
        size = targetSize,
        weight = 800,
        antialias = true
    })

    generatedFonts[key] = true
    return key
end

local function DrawGrowingText(
    text,
    baseFont,
    baseSize,
    x, y,
    color,
    time,
    minScale,
    maxScale,
    speed
)
    minScale = minScale or 1
    maxScale = maxScale or 2
    speed = speed or 2

    if not text or #text == 0 then return end

    if not baseFont or baseFont == "" then
        baseFont = "DermaLarge"
    end

    -- Calculate scale factor
    local scale = minScale + (math.sin(time * speed) * 0.5 + 0.5) * (maxScale - minScale)

    -- Compute scaled font size
    local scaledSize = math.max(1, math.floor(baseSize * scale))
    local scaledFont = GetDynamicFont(baseFont, scaledSize)

    -- Measure base slot positions
    surface.SetFont(baseFont)
    local slotCentersX = {}
    local slotCentersY = {}
    local offsetX = x
    local maxBaseHeight = 0

    for i = 1, #text do
        local char = text:sub(i, i)
        local w, h = surface.GetTextSize(char)
        if not w then w = 10 end
        if not h then h = baseSize end

        slotCentersX[i] = offsetX + w / 2
        slotCentersY[i] = y + h / 2
        offsetX = offsetX + w

        if h > maxBaseHeight then
            maxBaseHeight = h
        end
    end

    -- Draw scaled letters centered on slot centers
    surface.SetFont(scaledFont)

    for i = 1, #text do
        local char = text:sub(i, i)
        if char ~= "" then
            local w, h = surface.GetTextSize(char)

            if w and h then
                local centerX = slotCentersX[i]
                local centerY = slotCentersY[i]

                -- Center the scaled letter vertically around the slot
                local drawX = centerX - w / 2
                local drawY = centerY - h / 2

                surface.SetTextColor(color)
                surface.SetTextPos(drawX, drawY)
                surface.DrawText(char)
            end
        end
    end
end

///////////////////////
// Blinking
///////////////////////
local function DrawBlinkingText(
    text, font, x, y,
    color,
    time,
    blinkSpeed,
    dutyCycle
)
    blinkSpeed = blinkSpeed or 2         -- how many times per second it blinks
    dutyCycle = dutyCycle or 0.5         -- % of time it's visible

    local phase = (time * blinkSpeed) % 1

    if phase < dutyCycle then
        surface.SetFont(font)
        surface.SetTextColor(color)
        surface.SetTextPos(x, y)
        surface.DrawText(text)
    end
end

///////////////////////
// Skewing
///////////////////////
local SkewingPanel = nil

local function DrawSkewingText(
    text,
    fontSize,
    font,
    x, y,
    maxAngle,
    color,
    time,
    speed,
    w, h
)
    if not IsValid(SkewingPanel) then
        SkewingPanel = vgui.Create("DHTML")
        SkewingPanel:SetMouseInputEnabled(false)
        SkewingPanel:SetPaintedManually(true)
    end

    w = w or 512
    h = h or 128
    SkewingPanel:SetSize(w, h)

    -- calculate live angle in Lua
    local angle = math.sin(time * speed) * maxAngle
    local colorStr = string.format("rgba(%d,%d,%d,%d)", color.r, color.g, color.b, color.a or 255)

    local html = string.format([[
        <html>
        <body style="
            margin: 0;
            padding: 0;
            background: transparent;
            overflow: hidden;
        ">
            <span style="
                display: inline-block;
                transform: skewX(%fdeg);
                color: %s;
                font-family: '%s', sans-serif;
                font-size: %dpx;
                font-weight: bold;
            ">
                %s
            </span>
        </body>
        </html>
    ]],
        angle,
        colorStr,
        font,
        fontSize,
        text
    )

    SkewingPanel:SetHTML(html)
    SkewingPanel:SetPos(x, y)
    SkewingPanel:PaintManual()
end

///////////////////////
// Pulsing
///////////////////////
local function DrawColorPulseText(text, font, x, y, color1, color2, time, speed)
    surface.SetFont(font)
    
    local t = (math.sin(time * speed) * 0.5) + 0.5
    local r = Lerp(t, color1.r, color2.r)
    local g = Lerp(t, color1.g, color2.g)
    local b = Lerp(t, color1.b, color2.b)
    local a = Lerp(t, color1.a or 255, color2.a or 255)
    
    surface.SetTextColor(r, g, b, a)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

///////////////////////
// Scrolling
///////////////////////
local function DrawVerticalScrollText(text, font, x, y, color, time, speed, height)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local textHeight = select(2, surface.GetTextSize(text))
    local offsetY = (time * speed) % (textHeight + height)

    surface.SetTextPos(x, y - offsetY)
    surface.DrawText(text)
end

///////////////////////
// fade in/out
///////////////////////
local function DrawFadeText(text, font, x, y, color, time, speed)
    surface.SetFont(font)

    local alpha = (math.sin(time * speed) * 0.5 + 0.5) * 255
    surface.SetTextColor(color.r, color.g, color.b, alpha)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

///////////////////////
// jittering
///////////////////////
local jitterActiveUntil = 0
local jitterCooldownNext = 0

local function DrawControlledJitterText(
    text, font, x, y,
    color,
    time,
    jitterChance,   -- e.g. 0.1 = 10% chance per second
    jitterDuration, -- e.g. 0.15 seconds
    magnitude       -- e.g. 1-2 pixels
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    -- Check if we should trigger a new jitter burst
    if time >= jitterCooldownNext then
        if math.Rand(0, 1) < jitterChance then
            jitterActiveUntil = time + jitterDuration
        end
        -- Next cooldown check in 0.2 seconds
        jitterCooldownNext = time + 0.2
    end

    local jitterX, jitterY = 0, 0
    if time < jitterActiveUntil then
        jitterX = math.Rand(-magnitude, magnitude)
        jitterY = math.Rand(-magnitude, magnitude)
    end

    surface.SetTextPos(x + jitterX, y + jitterY)
    surface.DrawText(text)
end

///////////////////////
// flickering
///////////////////////
local flickerActiveUntil = 0
local flickerCooldownNext = 0

local function DrawControlledFlickerText(
    text, font, x, y,
    color,
    time,
    flickerChance,      -- chance per second
    flickerDuration     -- how long the flicker lasts
)
    surface.SetFont(font)
    surface.SetTextColor(color)

    if time >= flickerCooldownNext then
        if math.Rand(0, 1) < flickerChance then
            flickerActiveUntil = time + flickerDuration
        end
        flickerCooldownNext = time + 0.2
    end

    local visible = true

    if time < flickerActiveUntil then
        -- Randomly visible or invisible during flicker
        visible = math.Rand(0, 1) > 0.5
    end

    if visible then
        surface.SetTextPos(x, y)
        surface.DrawText(text)
    end
end

///////////////////////
// circular
///////////////////////
local function DrawCircularText(text, font, centerX, centerY, radius, color, time, speed)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local angleStep = 360 / #text

    for i = 1, #text do
        local angle = math.rad((i - 1) * angleStep + time * speed * 360)
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius

        local char = text:sub(i, i)
        surface.SetTextPos(x, y)
        surface.DrawText(char)
    end
end

///////////////////////
// Scamnlines
///////////////////////
local ScanlinesPanel = nil
local lastScanlinesParams = {}

local function EnsureScanlinesPanel()
    if not IsValid(ScanlinesPanel) then
        ScanlinesPanel = vgui.Create("DHTML")
        ScanlinesPanel:SetMouseInputEnabled(false)
        ScanlinesPanel:SetPaintedManually(true)
    end
end

function DrawScanlinesHTMLText(
    text,
    fontSize,
    font,
    x, y,
    baseColor,
    lineColor,
    lineOpacity,
    lineThickness,
    lineSpacing,
    speed,
    align,
    w, h
)
    EnsureScanlinesPanel()

    text = text or "SCANLINES"
    fontSize = fontSize or 64
    font = font or "Arial"
    baseColor = baseColor or "#00FF00"
    lineColor = lineColor or "#000000"
    lineOpacity = lineOpacity or 0.4
    lineThickness = lineThickness or 2
    lineSpacing = lineSpacing or 4
    speed = speed or 20
    align = align or TEXT_ALIGN_LEFT

    local textAlign = "left"
    if align == TEXT_ALIGN_CENTER then
        textAlign = "center"
    elseif align == TEXT_ALIGN_RIGHT then
        textAlign = "right"
    end

    local rgbaLine = string.format("rgba(%d,%d,%d,%.3f)",
        lineColor.r or 0,
        lineColor.g or 0,
        lineColor.b or 0,
        lineOpacity
    )

    local backgroundCSS = string.format([[
        repeating-linear-gradient(
            0deg,
            %s,
            %s %dpx,
            rgba(0,0,0,0) %dpx,
            rgba(0,0,0,0) %dpx
        )
    ]],
        rgbaLine,
        rgbaLine,
        lineThickness,
        lineThickness,
        lineSpacing
    )

    local html = string.format([[
        <html>
        <head>
        <style>
        @keyframes scanlinesAnim {
            0%% { background-position: 0 0; }
            100%% { background-position: 0 %dpx; }
        }
        body {
            margin: 0;
            padding: 0;
            background: transparent;
            overflow: hidden;
        }
        .container {
            position: relative;
            font-size: %dpx;
            font-family: '%s', sans-serif;
            font-weight: bold;
            text-align: %s;
            white-space: nowrap;
        }
        .base {
            color: %s;
            position: absolute;
            top: 0;
            left: 0;
        }
        .scanlines {
            background: %s;
            background-size: 100%% %dpx;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: scanlinesAnim %.2fs linear infinite;
            position: absolute;
            top: 0;
            left: 0;
        }
        </style>
        </head>
        <body>
            <div class="container">
                <span class="base">%s</span>
                <span class="scanlines">%s</span>
            </div>
        </body>
        </html>
    ]],
        lineSpacing,
        fontSize,
        font,
        textAlign,
        baseColor,
        backgroundCSS,
        lineSpacing,
        lineSpacing / speed,
        text,
        text
    )

    local key = table.concat({
        text, fontSize, font, baseColor,
        rgbaLine, lineThickness, lineSpacing, speed, align
    }, "|")

    if lastScanlinesParams.key ~= key then
        ScanlinesPanel:SetHTML(html)
        lastScanlinesParams.key = key
    end

    w = w or 800
    h = h or 200

    ScanlinesPanel:SetSize(w, h)
    ScanlinesPanel:SetPos(x, y)
    ScanlinesPanel:PaintManual()
end

///////////////////////
// Test
///////////////////////
--[[
hook.Add("HUDPaint", "MyWavyText", function()

    local CurTime = CurTime()

    DrawShakingText("Shaking", "DermaLarge", 50, 60, Color(255,255,0), CurTime * 1.8, 1.05)
    DrawWavingText("Waving", "DermaLarge", 50, 100, Color(255,255,0))
    DrawIteratingHorizontalRippleText("Waving 2", "DermaLarge", 50, 140, Color(255,255,0), CurTime, 5, 5, .5)
    DrawSequentialJumpText_SingleWave("Iterating", "DermaLarge", 50, 180, Color(255,255,0), CurTime, 0.3, 0.1, 5, .5)
    DrawFlippingLetterText("Flipping", "DermaLarge", 50, 220, Color(255,255,0), nil, 0.5, 0.1, 0.5)

    DrawGradientText("Gradient", 24, 50, 260, "linear-gradient(to right, red, orange, yellow)", 800, 100)
    DrawRainbowGradientText("Rainbow", 24, "Arial", 10, TEXT_ALIGN_LEFT, 50, 300)

    DrawShimmerLetterText("Shimer", 24, "Arial", 50, 340, TEXT_ALIGN_LEFT, "#ffcc00", 2.3, .5, .8)
    DrawChromaticAberrationText("Chromatic", "DermaLarge", 50, 380, 2, nil, 8)
    
    DrawGlitchText("Glitch", "DermaLarge", 50, 420, Color(255,255,0), CurTime, 20, .05)
    DrawChromaticGlitchText("CHROMATIC GLITCH", "DermaLarge", 50, 460, CurTime, 2, 20, 0.05, 5)
    DrawDecipherText("loopKey", "Access Granted", "DermaLarge", 50, 500, Color(255, 255, 255), CurTime, 8, true, 1.5, Color(35, 172, 35))

    DrawTypingText("typingKey", "HELLO, USER. SYSTEM ONLINE.", "DermaLarge", 50, 540, Color(90, 230, 34), CurTime, 20, true)
    DrawTypingText("typingLoopKey", "Robot with cursor:", "DermaLarge", 50, 580, Color(90, 230, 34), CurTime, 15, true, 1.5, "_")

    DrawTypingTextHuman("humanKey", "Human typing. looks nice!", "DermaLarge", 50, 620, Color(255, 255, 255), CurTime, true, 0.5, "_")
    DrawTypingTextHumanAdvanced("humanMistakeKey", "Welcome fellow human.", "DermaLarge", 50, 660, Color(255, 255, 255), CurTime, true, 1.5, "_", {[11] = { wrong = "k", right = "l" }})

    DrawGrowingText("GROWING", "DermaLarge", 32, 50, 700, Color(255, 0, 0), CurTime, 1, 1.4, 5)
    DrawBlinkingText("BLINKING", "DermaLarge", 50, 740, Color(255, 255, 0), CurTime, 1, 0.5)
    DrawSkewingText("Skewing", 26, "Arial", 50, 780, 20, Color(0, 0, 255), CurTime, 2.0, 800, 100)

    DrawColorPulseText("Pulsing", "DermaLarge", 50, 820, Color(255, 255, 0), Color(255, 0, 0), CurTime, 2)
    DrawControlledJitterText("Jittering", "DermaLarge", 50, 860, Color(255, 255, 0), CurTime, 0.2, 0.15, 1.5)
    DrawControlledFlickerText("Flickering", "DermaLarge", 50, 900, Color(255, 0, 0), CurTime, 0.3, 0.15)
    DrawCircularText("Orbit", "DermaLarge", 50 + 25, 940, 25, Color(255, 255, 0), CurTime, .6)
    DrawVerticalScrollText("Scroll", "DermaLarge", 50, 980, Color(255, 255, 0), CurTime, 20, .5)

    DrawScanlinesHTMLText(
        "SCANLINES HTML",
        24,
        "Arial",
        50, 1020,
        "#e8b135",     -- base color (text color)
        Color(126, 109, 47),     -- scanline color
        0.5,                   -- scanline opacity
        2,             -- line thickness
        6,             -- line spacing
        20,            -- speed
        TEXT_ALIGN_LEFT,
        800, 120
    )
end)
]]















--[[ 

	Moat's text effects for garry's mod :D

	https://steamcommunity.com/id/moat_

]]--


local function m_AlignText( text, font, x, y, xalign, yalign )

	surface.SetFont( font )

	local textw, texth = surface.GetTextSize( text )

	if ( xalign == TEXT_ALIGN_CENTER ) then

		x = x - ( textw / 2 )

	elseif ( xalign == TEXT_ALIGN_RIGHT ) then
		
		x = x - textw

	end

	if ( yalign == TEXT_ALIGN_BOTTOM ) then
		
		y = y - texth

	end

	return x, y

end

function DrawShadowedText( shadow, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	draw.SimpleText( text, font, x + shadow, y + shadow, Color( 0, 0, 0, color.a or 255 ), xalign, yalign )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end


function GlowColor( col1, col2, mod )

	local newr = col1.r + ( ( col2.r - col1.r ) * ( mod ) )

	local newg = col1.g + ( ( col2.g - col1.g ) * ( mod ) )

	local newb = col1.b + ( ( col2.b - col1.b ) * ( mod ) )

	return Color( newr, newg, newb )

end


function DrawEnchantedText( speed, text, font, x, y, color, glow_color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	local glow_color = glow_color or Color( 127, 0, 255 )

	local texte = string.Explode( "", text )

	local x, y = m_AlignText( text, font, x, y, xalign, yalign )

	surface.SetFont( font )

	local chars_x = 0

	for i = 1, #texte do

		local char = texte[i]

		local charw, charh = surface.GetTextSize( char )

		local color_glowing = GlowColor( glow_color, color, math.abs( math.sin( ( RealTime() - ( i * 0.08 ) ) * speed ) ) )

		draw.SimpleText( char, font, x + chars_x, y, color_glowing, xalign, yalign )

		chars_x = chars_x + charw

	end

end

function DrawFadingText( speed, text, font, x, y, color, fading_color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	local color_fade = GlowColor( color, fading_color, math.abs( math.sin( ( RealTime() - 0.08 ) * speed ) ) )

	draw.SimpleText( text, font, x, y, color_fade, xalign, yalign )

end

local col1 = Color( 0, 0, 0 )

local col2 = Color( 255, 255, 255 )

local next_col = 0

function DrawRainbowText( speed, text, font, x, y, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	next_col = next_col + 1 / ( 100 / speed )

	if ( next_col >= 1 ) then 

		next_col = 0

		col1 = col2

		col2 = ColorRand()

	end

	draw.SimpleText( text, font, x, y, GlowColor( col1, col2, next_col ), xalign, yalign )

end


function DrawGlowingText( static, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local initial_a = 20

	local a_by_i = 5

	local alpha_glow = math.abs( math.sin( ( RealTime() - 0.1 ) * 2 ) )

	if ( static ) then alpha_glow = 1 end

	for i = 1, 2 do

		draw.SimpleTextOutlined( text, font, x, y, color, xalign, yalign, i, Color( color.r, color.g, color.b, ( initial_a - ( i * a_by_i ) ) * alpha_glow ) )

	end

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end


function DrawBouncingText( style, intesity, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local texte = string.Explode( "", text )

	surface.SetFont( font )

	local chars_x = 0

	local x, y = m_AlignText( text, font, x, y, xalign, yalign )

	for i = 1, #texte do

		local char = texte[i]

		local charw, charh = surface.GetTextSize( char )

		local y_pos = 1

		local mod = math.sin( ( RealTime() - ( i * 0.1 ) ) * ( 2 * intesity ) )

		if ( style == 1 ) then

			y_pos = y_pos - math.abs( mod )

		elseif ( style == 2 ) then
			
			y_pos = y_pos + math.abs( mod )

		else

			y_pos = y_pos - mod

		end

		draw.SimpleText( char, font, x + chars_x, y - ( 5 * y_pos ), color, xalign, yalign )

		chars_x = chars_x + charw

	end

end

local next_electic_effect = CurTime() + 0

local electric_effect_a = 0

function DrawElecticText( intensity, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local charw, charh = surface.GetTextSize( text )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

	if ( electric_effect_a > 0 ) then
		
		electric_effect_a = electric_effect_a - ( 1000 * FrameTime() )

	end

	surface.SetDrawColor( 102, 255, 255, electric_effect_a )

	for i = 1, math.random( 5 ) do

		line_x = math.random( charw )

		line_y = math.random( charh )

		line_x2 = math.random( charw )

		line_y2 = math.random( charh )

		surface.DrawLine( x + line_x, y + line_y, x + line_x2, y + line_y2 )

	end

	local effect_min = 0.5 + ( 1 - intensity )

	local effect_max = 1.5 + ( 1 - intensity )

	if ( next_electic_effect <= CurTime() ) then

		next_electic_effect = CurTime() + math.Rand( effect_min, effect_max )
		
		electric_effect_a = 255

	end

end


function DrawFireText( intensity, text, font, x, y, color, xalign, yalign, glow, shadow )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	surface.SetFont( font )

	local charw, charh = surface.GetTextSize( text )

	local fire_height = charh * intensity

	for i = 1, charw do
		
		local line_y = math.random( fire_height, charh )

		local line_x = math.random( -4, 4 )

		local line_col = math.random( 255 )

		surface.SetDrawColor( 255, line_col, 0, 150 )

		surface.DrawLine( x - 1 + i, y + charh, x - 1 + i + line_x, y + line_y )

	end

	if ( glow ) then
		
		DrawGlowingText( true, text, font, x, y, color, xalign, yalign )

	end

	if ( shadow ) then

		draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0 ), xalign, yalign )

	end

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end

function DrawSnowingText( intensity, text, font, x, y, color, color2, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local color2 = color2 or Color( 255, 255, 255 )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

	surface.SetFont( font )

	local textw, texth = surface.GetTextSize( text )

	surface.SetDrawColor( color2.r, color2.g, color2.b, 255 )

	for i = 1, intensity do
		
		local line_y = math.random( 0, texth )

		local line_x = math.random( 0, textw )

		surface.DrawLine( x + line_x, y + line_y, x + line_x, y + line_y + 1 )

	end

end


local MOAT_SHOW_EFFECT_EXAMPLES = false

function moat_DrawEffectExamples()

	if ( not MOAT_SHOW_EFFECT_EXAMPLES ) then return end

	local font = "DermaLarge"

	draw.RoundedBox( 0, 50, 50, 700, 500, Color( 0, 0, 0, 200 ) )

	local x = 100

	local y = 100

	DrawGlowingText( false, "GLOWING TEXT", font, x, y, Color( 255, 0, 0, 255 ) )

	y = y + 50

	DrawFadingText( 1, "FADING COLORS TEXT", font, x, y, Color( 255, 0, 0 ), Color( 0, 0, 255 ) )

	y = y + 50

	DrawRainbowText( 1, "RAINBOW TEXT", font, x, y )

	y = y + 50

	DrawEnchantedText( 2, "ENCHANTED TEXT", font, x, y, Color( 255, 0, 0 ), Color( 0, 0, 255 ) )

	y = y + 50

	DrawFireText( 0.5, "INFERNO TEXT", font, x, y, Color( 255, 0, 0 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true, true )

	y = y + 50

	DrawElecticText( 1, "ELECTRIC TEXT", font, x, y, Color( 255, 0, 0 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	y = y + 50

	DrawBouncingText( 3, 3, "BOUNCING AND WAVING TEXT", font, x, y, Color( 255, 0, 0 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	y = y + 50

	DrawSnowingText( 10, "SPARKLING/SNOWING TEXT", font, x, y, Color( 255, 0, 0 ), Color( 255, 255, 255 ) )

end

hook.Add( "HUDPaint", "moat_TextEffectsExample", moat_DrawEffectExamples )

concommand.Add( "moat_TextExamples", function() MOAT_SHOW_EFFECT_EXAMPLES = not MOAT_SHOW_EFFECT_EXAMPLES end )