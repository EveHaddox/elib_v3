// Theme System for Elib V3
// Allows switching between named color presets defined in Elib.Themes

--[[
    Returns a sorted list of all registered theme names.
]]
function Elib.GetThemeNames()
    local names = {}
    for name in pairs(Elib.Themes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--[[
    Applies a named theme from Elib.Themes to Elib.Colors.
    Overwrites every color key with a copy from the theme preset,
    then fires the "Elib.ThemeChanged" hook so all live panels can refresh their cached colors.

    @param name (string) - The theme name (must exist in Elib.Themes)
    @param silent (bool)  - If true, skip the hook (used during initial load to avoid double-firing)
]]
function Elib.SetTheme(name, silent)
    local theme = Elib.Themes[name]
    if not theme then
        print("[Elib] Theme '" .. tostring(name) .. "' not found!")
        return false
    end

    -- Use Default as fallback for any missing keys
    local fallback = Elib.Themes["Default"] or {}

    for key, _ in pairs(Elib.Colors) do
        local source = theme[key] or fallback[key]
        if source then
            Elib.Colors[key] = Elib.CopyColor(source)
        end
    end

    Elib.ActiveTheme = name

    -- Sync individual color config values so the config menu shows correct colors
    if Elib.Config and Elib.Config.Addons and Elib.Config.Addons["Elib"] then
        local colorConfigs = Elib.Config.Addons["Elib"]["client"] and Elib.Config.Addons["Elib"]["client"]["colors"]
        if colorConfigs then
            local colorMap = {
                background_color = "Background",
                header_color = "Header",
                scroller_color = "Scroller",
                primary_text_color = "PrimaryText",
                secondary_text_color = "SecondaryText",
                disabled_text_color = "DisabledText",
                primary_color = "Primary",
                disabled_color = "Disabled",
                positive_color = "Positive",
                negative_color = "Negative",
                gold_color = "Gold",
                silver_color = "Silver",
                bronze_color = "Bronze",
            }

            for configId, colorKey in pairs(colorMap) do
                if colorConfigs[configId] then
                    colorConfigs[configId].value = Elib.CopyColor(Elib.Colors[colorKey])
                end
            end
        end
    end

    if not silent then
        hook.Run("Elib.ThemeChanged", name)
    end

    return true
end

// Theme Preset
hook.Add("Elib.FullyLoaded", "Elib:LoadThemes", function()
    Elib.Config:AddValue("Elib", "client", "general", "theme", "Theme Preset", "Default", "Dropdown", 0, function(value)
        if not value then return end
        Elib.SetTheme(value)
    end, true, Elib.GetThemeNames())
end)