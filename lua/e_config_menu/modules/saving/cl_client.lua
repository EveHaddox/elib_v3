// Script made by Eve Haddox
// discord evehaddox


// Client saving
if not sql.TableExists("Elib_client_settings") then
    sql.Query("CREATE TABLE IF NOT EXISTS Elib_client_settings (addon TEXT PRIMARY KEY, category TEXT, id TEXT, value TEXT, vType TEXT)")
end

local function SaveServer(addon, category, id, value, vType)

    net.Start("Elib.Config.Save")
        net.WriteString(addon)
        net.WriteString(category)
        net.WriteString(id)
        net.WriteString(value)
        net.WriteString(vType)
    net.SendToServer()

end

function Elib.Config.Save(addon, realm, category, id, value)

    local vType = type(value)
    if vType == "table" then
        value = util.TableToJSON(value, false)
    else
        value = tostring(value)
    end

    if realm == "client" then
        sql.Query(string.format("INSERT OR REPLACE INTO Elib_client_settings (addon, category, id, value, vType) VALUES (%q, %q, %q, %q, %q)", addon, category, id, value, vType))
    else
        SaveServer(addon, category, id, value, vType)
    end
end

function Elib.Config.LoadClientSettings()
    local results = sql.Query("SELECT * FROM Elib_client_settings")
    if not results then return end // No results found

    for _, row in ipairs(results) do
        local addon = row.addon
        local realm = "client"
        local category = row.category
        local id = row.id
        local value = row.value
        local vType = row.vType

        if Elib.Config.Addons[addon] and Elib.Config.Addons[addon][realm] and Elib.Config.Addons[addon][realm][category] and Elib.Config.Addons[addon][realm][category][id] then
            Elib.Config.Addons[addon][realm][category][id].value = value
        else
            // not found
            --print("Settings not found in config: " .. addon .. ", " .. category .. ", " .. id)
        end
    end
end

Elib.Config.LoadClientSettings()

// networking
net.Receive("Elib.Config.SendToAdmins", function(len)
    local config = net.ReadTable()
    print("Received config from server: " .. util.TableToJSON(config, true))

    -- replace only the “server” realm in your existing table, leave “client” intact
    for addon, realm in pairs(config) do
        Elib.Config.Addons[addon] = Elib.Config.Addons[addon] or {}
        Elib.Config.Addons[addon].server = realm.server
    end

    PrintTable(Elib.Config.Addons)
end)


--[[ // for debugging purposes
local function PrintAllSettings()
    local results = sql.Query("SELECT * FROM Elib_client_settings")
    if not results then return end // No results found

    for _, row in ipairs(results) do
        PrintTable(row)
        print("Addon: " .. row.addon .. ", Category: " .. row.category .. ", ID: " .. row.id .. ", Value: " .. row.value)
    end
end

PrintAllSettings()
]]