// Script made by Eve Haddox
// discord evehaddox


// Config Builder
Elib.Config.Addons = Elib.Config.Addons or {}

Elib.Config.Addons = {
    {
        name = "Addon 1",
        order = 1,
        author = { name = "Eve Haddox", steamid = "76561198847312396" },
    },
    {
        name = "Addon 2",
        order = 2,
        author = { name = "Eve Haddox", steamid = "76561198847312396" },
    },
    {
        name = "Addon 3",
        order = 3,
        author = { name = "Eve Haddox", steamid = "76561198847312396" },
    },
}

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