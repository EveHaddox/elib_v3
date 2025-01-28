--This code can be improved alot.
--Feel free to improve, use or modify in anyway altough credit would be apreciated.
// Thanks to CodeBlue for the original code!

--The original drawing layer
Elib.RenderTarget = GetRenderTarget("bshadows_original", ScrW(), ScrH())
    
--The shadow layer
Elib.RenderTarget2 = GetRenderTarget("bshadows_shadow",  ScrW(), ScrH())

--The matarial to draw the render targets on
Elib.ShadowMaterial = CreateMaterial("bshadows","UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["alpha"] = 1
})

--When we copy the rendertarget it retains color, using this allows up to force any drawing to be black
--Then we can blur it to create the shadow effect
Elib.ShadowMaterialGrayscale = CreateMaterial("bshadows_grayscale","UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$alpha"] = 1,
    ["$color"] = "0 0 0",
    ["$color2"] = "0 0 0"
})

--Call this to begin drawing a shadow
Elib.BeginShadow = function()

    --Set the render target so all draw calls draw onto the render target instead of the screen
    render.PushRenderTarget(Elib.RenderTarget)

    --Clear is so that theres no color or alpha
    render.OverrideAlphaWriteEnable(true, true)
    render.Clear(0,0,0,0)
    render.OverrideAlphaWriteEnable(false, false)

    --Start Cam2D as where drawing on a flat surface 
    cam.Start2D()

    --Now leave the rest to the user to draw onto the surface
end

--This will draw the shadow, and mirror any other draw calls the happened during drawing the shadow
Elib.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)
    
    --Set default opcaity
    opacity = opacity or 255
    direction = direction or 0
    distance = distance or 0
    _shadowOnly = _shadowOnly or false

    --Copy this render target to the other
    render.CopyRenderTargetToTexture(Elib.RenderTarget2)

    --Blur the second render target
    if blur > 0 then
        render.OverrideAlphaWriteEnable(true, true)
        render.BlurRenderTarget(Elib.RenderTarget2, spread, spread, blur)
        render.OverrideAlphaWriteEnable(false, false) 
    end

    --First remove the render target that the user drew
    render.PopRenderTarget()

    --Now update the material to what was drawn
    Elib.ShadowMaterial:SetTexture('$basetexture', Elib.RenderTarget)

    --Now update the material to the shadow render target
    Elib.ShadowMaterialGrayscale:SetTexture('$basetexture', Elib.RenderTarget2)

    --Work out shadow offsets
    local xOffset = math.sin(math.rad(direction)) * distance 
    local yOffset = math.cos(math.rad(direction)) * distance

    --Now draw the shadow
    Elib.ShadowMaterialGrayscale:SetFloat("$alpha", opacity/255) --set the alpha of the shadow
    render.SetMaterial(Elib.ShadowMaterialGrayscale)
    for i = 1 , math.ceil(intensity) do
        render.DrawScreenQuadEx(xOffset, yOffset, ScrW(), ScrH())
    end

    if not _shadowOnly then
        --Now draw the original
        Elib.ShadowMaterial:SetTexture('$basetexture', Elib.RenderTarget)
        render.SetMaterial(Elib.ShadowMaterial)
        render.DrawScreenQuad()
    end

    cam.End2D()
end

--This will draw a shadow based on the texture you passed it.
Elib.DrawShadowTexture = function(texture, intensity, spread, blur, opacity, direction, distance, shadowOnly)

    --Set default opcaity
    opacity = opacity or 255
    direction = direction or 0
    distance = distance or 0
    shadowOnly = shadowOnly or false

    --Copy the texture we wish to create a shadow for to the shadow render target
    render.CopyTexture(texture, Elib.RenderTarget2)

    --Blur the second render target
    if blur > 0 then
        render.PushRenderTarget(Elib.RenderTarget2)
        render.OverrideAlphaWriteEnable(true, true)
        render.BlurRenderTarget(Elib.RenderTarget2, spread, spread, blur)
        render.OverrideAlphaWriteEnable(false, false) 
        render.PopRenderTarget()
    end

    --Now update the material to the shadow render target
    Elib.ShadowMaterialGrayscale:SetTexture('$basetexture', Elib.RenderTarget2)

    --Work out shadow offsets
    local xOffset = math.sin(math.rad(direction)) * distance 
    local yOffset = math.cos(math.rad(direction)) * distance

    --Now draw the shadow 
    Elib.ShadowMaterialGrayscale:SetFloat("$alpha", opacity/255) --Set the alpha
    render.SetMaterial(Elib.ShadowMaterialGrayscale)
    for i = 1 , math.ceil(intensity) do
        render.DrawScreenQuadEx(xOffset, yOffset, ScrW(), ScrH())
    end
    if not shadowOnly then
        --Now draw the original
        Elib.ShadowMaterial:SetTexture('$basetexture', texture)
        render.SetMaterial(Elib.ShadowMaterial)
        render.DrawScreenQuad()
    end
end

--[[ Since I forgot for the 5th time how to use this a quick example
-- Function to draw a rounded box with a shadow
Elib.DrawRoundedBoxShadow = function(cornerRadius, x, y, width, height, boxColor, shadowIntensity, shadowSpread, shadowBlur, shadowOpacity, shadowDirection, shadowDistance)
    -- Begin drawing the shadow
    Elib.BeginShadow()

    -- Draw the rounded box
    draw.RoundedBox(cornerRadius, x, y, width, height, boxColor)

    -- End drawing the shadow and apply the shadow effect
    Elib.EndShadow(shadowIntensity, shadowSpread, shadowBlur, shadowOpacity, shadowDirection, shadowDistance)
end

-- Example usage
hook.Add("HUDPaint", "DrawRoundedBoxShadowExample", function()
    Elib.DrawRoundedBoxShadow(6, 100, 100, 150, 200, Elib.Colors.Scroller, 5, 2, 2, 180, 45, 0)
    Elib.DrawRoundedBox(6, 102, 102, 146, 196, Elib.Colors.Header)
end)
--hook.Remove("HUDPaint", "DrawRoundedBoxShadowExample")
]]
