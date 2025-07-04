// Script made by Eve Haddox
// discord evehaddox


// Saving server side
--sql.Query("DROP TABLE IF EXISTS Elib_settings")
if not sql.TableExists("Elib_settings") then
    sql.Query("CREATE TABLE IF NOT EXISTS Elib_settings (addon TEXT, category TEXT, id TEXT, value TEXT, vType TEXT, PRIMARY KEY(addon, category, id))")
end

local function Save(addon, realm, category, id, value, vType)
    -- serialize tables, stringify everything else
    if vType == "table" then
        value = util.TableToJSON(value)
    else
        value = tostring(value)
    end

    local qAddon    = sql.SQLStr(addon)
    local qCategory = sql.SQLStr(category)
    local qID       = sql.SQLStr(id)
    local qValue    = sql.SQLStr(value)
    local qVType    = sql.SQLStr(vType)

    sql.Query(string.format(
        "INSERT OR REPLACE INTO Elib_settings (addon, category, id, value, vType) VALUES(%s, %s, %s, %s, %s)",
        qAddon, qCategory, qID, qValue, qVType
    ))
end

util.AddNetworkString("Elib.Config.SendToAdmins")
function Elib.Config.LoadSettings()
    local results = sql.Query("SELECT * FROM Elib_settings")
    if not results then return end // No results found

    for _, row in ipairs(results) do
        local addon = row.addon
        local realm = "server"
        local category = row.category
        local id = row.id
        local value = row.value
        local vType = row.vType

        -- deserialize tables
        if vType == "table" then
            value = util.JSONToTable(value)
        end

        if Elib.Config.Addons[addon]
        and Elib.Config.Addons[addon][realm]
        and Elib.Config.Addons[addon][realm][category]
        and Elib.Config.Addons[addon][realm][category][id] then

            Elib.Config.Addons[addon][realm][category][id].value = value
        else
            // not found
        end
    end

    -- send config only to superadmins
    local targets = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsSuperAdmin() then
            table.insert(targets, ply)
        end
    end

    net.Start("Elib.Config.SendToAdmins")
        net.WriteTable(Elib.Config.Addons)
    net.Send(targets)
    
end

// networking
util.AddNetworkString("Elib.Config.Save")
util.AddNetworkString("Elib.Config.SendToAdmins")

net.Receive("Elib.Config.Save", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    local addon, category, id, value, vType =
        net.ReadString(),
        net.ReadString(),
        net.ReadString(),
        net.ReadString(),
        net.ReadString()

    -- 1) Persist to SQL
    Save(addon, "server", category, id, value, vType)

    -- 2) Update in-memory table
    if Elib.Config.Addons[addon]
    and Elib.Config.Addons[addon].server
    and Elib.Config.Addons[addon].server[category]
    and Elib.Config.Addons[addon].server[category][id] then

        local entry = Elib.Config.Addons[addon].server[category][id]
        if vType == "table" then
            entry.value = util.JSONToTable(value)
        else
            entry.value = value
        end
    end

    -- 3) Broadcast the updated config to all superadmins
    local targets = {}
    for _, v in ipairs(player.GetAll()) do
        if v:IsSuperAdmin() then
            table.insert(targets, v)
        end
    end

    net.Start("Elib.Config.SendToAdmins")
        net.WriteTable(Elib.Config.Addons)
    net.Send(targets)
end)


// loading
timer.Simple(0.1, Elib.Config.LoadSettings) // config didn't load without this delay

hook.Add("PlayerInitialSpawn", "Elib.Config.SendOnJoin", function(ply)
    if not ply:IsSuperAdmin() then return end

    timer.Simple(0.5, function()
        if not IsValid(ply) then return end // safety check

        net.Start("Elib.Config.SendToAdmins")
            net.WriteTable(Elib.Config.Addons)
        net.Send(ply)
    end)
end)