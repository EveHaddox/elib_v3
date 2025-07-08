// Script made by Eve Haddox
// discord evehaddox


// Config Builder
Elib.Config = Elib.Config or {}
Elib.Config.Addons = Elib.Config.Addons or {}
Elib.Config.Values = Elib.Config.Values or {}

local AddonCount = 0
function Elib.Config:AddAddon(name, order, author)
    AddonCount = AddonCount + 1

    if CLIENT then
        Elib.Config.Addons[name] = {
            name = name,
            order = order or AddonCount,
            author = { name = author and author[1] or "Eve Haddox", steamid = author and author[2] or "76561198847312396" },
        }
    else
        Elib.Config.Addons[name] = {
            order = order or AddonCount,
        }
    end
    
end

local count = 0
function Elib.Config:AddValue(addon, realm, category, id, name, value, type, order, onComplete, resetMenu, table, network)
    count = count + 1
    order = order or count

    realm = string.lower(realm)
    category = string.lower(category)

    Elib.Config.Addons[addon] = Elib.Config.Addons[addon] or {}
    if not Elib.Config.Addons[addon] then
        Elib.Config:AddAddon(name)
    end

    Elib.Config.Addons[addon][realm] = Elib.Config.Addons[addon][realm] or {}
    Elib.Config.Addons[addon][realm][category] = Elib.Config.Addons[addon][realm][category] or {}

    if realm == "client" and SERVER then return end

    Elib.Config.Addons[addon][realm][category][id] = {
        name = name,
        value = value,
        default = value,
        type = type,
        onComplete = onComplete,
        order = order,
        resetMenu = resetMenu or false,
        table = table or nil,
        network = network or false,
    }
end

function Elib.Config:GetValue(addon, realm, category, id)
    realm = string.lower(realm)
    category = string.lower(category)
    
    if SERVER and realm == "client" then return nil end

    if not Elib.Config.Addons[addon] then
        printf("Elib.Config: Addon '%s' not found!", addon)
        return nil
    elseif not Elib.Config.Addons[addon][realm][category] then
        printf("Elib.Config: Category '%s' for addon '%s' in realm '%s' not found!", category, addon, realm)
        return nil
    elseif not Elib.Config.Addons[addon][realm][category][id] then
        printf("Elib.Config: ID '%s' for addon '%s' in realm '%s' and category '%s' not found!", id, addon, realm, category)
        return nil
    end

    return Elib.Config.Addons[addon][realm][category][id].value
end

// Panel list

-- Number (int)
-- Float
-- String
-- Toggle (bool)
-- Key (keybind)
-- Color (color)
-- Dropdown (string)

---- XX not done yet XX ----
-- list (numeric table)
-- table (table)

// Example
Elib.Config:AddAddon("Elib")

// Test / Example values
Elib.Config:AddValue("Elib", "client", "Test", "test_num", "Test Number", 2, "Number")
Elib.Config:AddValue("Elib", "client", "Test", "test_toggle", "Test Toggle", true, "Toggle")
Elib.Config:AddValue("Elib", "client", "Test", "test_key", "Test Key", KEY_1, "Key")
Elib.Config:AddValue("Elib", "client", "Test", "test_color", "Test Color", Color(153, 57, 57), "Color")
Elib.Config:AddValue("Elib", "client", "Test", "test_deopdown", "Test Dropdown", "test", "Dropdown", nil, nil, nil, {"test", "smth?", "idk", "idk 2", "long one, like really long one"})

Elib.Config:AddValue("Elib", "server", "Test", "test_num", "Test Number Server", 7, "Number", nil, nil, true)

// Colors
Elib.Config:AddValue("Elib", "client", "colors", "background_color", "Background Color", Color(20, 20, 20), "Color", 1, function(value)
    if not value then return end
    Elib.Colors.Background = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "header_color", "Header Color", Color(30, 30, 30), "Color", 2, function(value)
    if not value then return end
    Elib.Colors.Header = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "scroller_color", "Scroller Color", Color(48, 48, 48), "Color", 3, function(value)
    if not value then return end
    Elib.Colors.Scroller = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "primary_text_color", "Primary Text Color", Color(240, 240, 240), "Color", 4, function(value)
    if not value then return end
    Elib.Colors.PrimaryText = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "secondary_text_color", "Secondary Text Color", Color(200, 200, 200), "Color", 5, function(value)
    if not value then return end
    Elib.Colors.SecondaryText = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "disabled_text_color", "Disabled Text Color", Color(100, 100, 100), "Color", 6, function(value)
    if not value then return end
    Elib.Colors.DisabledText = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "primary_color", "Primary Color", Color(180, 58, 58), "Color", 7, function(value)
    if not value then return end
    Elib.Colors.Primary = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "disabled_color", "Disabled Color", Color(120, 120, 120), "Color", 8, function(value)
    if not value then return end
    Elib.Colors.Disabled = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "positive_color", "Positive Color", Color(70, 175, 70), "Color", 9, function(value)
    if not value then return end
    Elib.Colors.Positive = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "negative_color", "Negative Color", Color(190, 65, 65), "Color", 10, function(value)
    if not value then return end
    Elib.Colors.Negative = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "gold_color", "Gold Color", Color(214, 174, 34), "Color", 11, function(value)
    if not value then return end
    Elib.Colors.Gold = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "silver_color", "Silver Color", Color(192, 192, 192), "Color", 12, function(value)
    if not value then return end
    Elib.Colors.Silver = value
end)
Elib.Config:AddValue("Elib", "client", "colors", "bronze_color", "Bronze Color", Color(145, 94, 49), "Color", 13, function(value)
    if not value then return end
    Elib.Colors.Bronze = value
end)