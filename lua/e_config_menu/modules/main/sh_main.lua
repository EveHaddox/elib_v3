// Script made by Eve Haddox
// discord evehaddox


// Config Builder
Elib.Config = Elib.Config or {}
Elib.Config.Addons = Elib.Config.Addons or {}
Elib.Config.Values = Elib.Config.Values or {}

local AddonCount = 0
function Elib.Config:AddAddon(name, order, author)
    AddonCount = AddonCount + 1

    Elib.Config.Addons[name] = {
        name = name,
        order = order or AddonCount,
        author = { name = author and author[1] or "Eve Haddox", steamid = author and author[2] or "76561198847312396" },
    }
end

local count = 0
function Elib.Config:AddValue(addon, id, title, values, default, type, onComplete, order, lines, resetMenu, dontNetwork)
    count = count + 1
    order = order or count

    Elib.Config.Addons[addon] = Elib.Config.Addons[addon] or {}

    Elib.Config.Addons[addon].Options[id] = {
        title = title,
        values = values,
        default = default,
        type = type,
        onComplete = onComplete,
        order = order,
        lines = lines or false,
        resetMenu = resetMenu or false,
        dontNetwork = dontNetwork or false,
    }
end

function Elib.Config:GetValue(addon, id)
    if SERVER then
        return Elib:GetValue(addon, id)
    end

    return Elib.Config.Addons[addon].Options[id].default
end

Elib.Config.Addons = Elib.Config.Addons or {}
Elib.Config:AddAddon("Addon 1")
Elib.Config:AddAddon("Addon 2")
Elib.Config:AddAddon("Addon 3")

Elib.Config.Values = {
    {
        name = "value",
        descruption = "changes the value",
        type = "number",
        default = 0,
        realm = "server",
        onComplete = function(value)
            print("Value changed to: " .. value)
        end,
        order = 1,
    },
    {
        name = "value2",
        descruption = "changes the value",
        type = "number",
        default = 0,
        realm = "server",
        onComplete = function(value)
            print("Value changed to: " .. value)
        end,
        order = 2,
    },
    {
        name = "value3",
        descruption = "changes the value",
        type = "number",
        default = 0,
        realm = "server",
        onComplete = function(value)
            print("Value changed to: " .. value)
        end,
        order = 3,
    },
}