// Script made by Eve Haddox
// discord evehaddox


// Client saving
if not sql.TableExists("Elib_client_settings") then
    sql.Query("CREATE TABLE IF NOT EXISTS Elib_client_settings (addon TEXT PRIMARY KEY, category TEXT, id TEXT, value TEXT, vType TEXT)")
end

local function SaveServer(addon, category, id, value, vType)

    if not LocalPlayer():IsSuperAdmin() then return end

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
        value = sql.SQLStr(util.TableToJSON(value), true)
    else
        value = tostring(value)
    end

    if realm == "client" then
        sql.Query(string.format("INSERT OR REPLACE INTO Elib_client_settings (addon, category, id, value, vType) VALUES (%q, %q, %q, %q, %q)", addon, category, id, value, vType))

        local err = sql.LastError()
        if err and err ~= "" then
            ErrorNoHalt("[Elib.Config.Save] SQL error: " .. err .. "\n")
        end
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
        end
    end
end

Elib.Config.LoadClientSettings()

// networking
net.Receive("Elib.Config.SendToAdmins", function()
    local updated = net.ReadTable()

    -- loop each addon
    for addonName, addonData in pairs(updated) do
        local localAddon = Elib.Config.Addons[addonName]
        if not localAddon then
            -- unknown addon, skip
            continue
        end

        -- only these two realms matter
        for _, realm in ipairs({"server", "client"}) do
            local realmData = addonData[realm]
            if type(realmData) ~= "table" then
                -- no data for this realm (or it wasn't a table)
                continue
            end

            local localRealm = localAddon[realm]
            if type(localRealm) ~= "table" then
                -- you didn't define this realm locally
                continue
            end

            -- now loop categories and entries
            for category, entries in pairs(realmData) do
                if type(entries) ~= "table" then
                    continue
                end

                local localCat = localRealm[category]
                if type(localCat) ~= "table" then
                    continue
                end

                for id, entryData in pairs(entries) do
                    if type(entryData) == "table" and localCat[id] then
                        -- finally update only the .value field
                        localCat[id].value = entryData.value
                    end
                end
            end
        end
    end

    -- optional hook so any menus/UI know to refresh
    hook.Run("Elib.Config.OnReceived", updated)
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