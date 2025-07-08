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
-- Color (color) X BROKEN X
-- Dropdown (string)

---- XX not done yet XX ----
-- list (numeric table)
-- table (table)

// Example
Elib.Config:AddAddon("Elib")

Elib.Config:AddValue("Elib", "client", "main", "test_num", "Test Number", 2, "Number")
Elib.Config:AddValue("Elib", "client", "main", "test_toggle", "Test Toggle", true, "Toggle")
Elib.Config:AddValue("Elib", "client", "main", "test_key", "Test Key", KEY_1, "Key")
Elib.Config:AddValue("Elib", "client", "main", "test_color", "Test Color", Color(153, 57, 57), "Color")
Elib.Config:AddValue("Elib", "client", "main", "test_deopdown", "Test Dropdown", "test", "Dropdown", nil, nil, nil, {"test", "smth?", "idk", "idk 2", "long one, like really long one"})

Elib.Config:AddValue("Elib", "server", "main", "test_num", "Test Number Server", 7, "Number", nil, nil, true)