// Script made by Eve Haddox
// discord evehaddox


// Client saving
if not sql.TableExists("Elib_client_settings") then
    sql.Query("CREATE TABLE IF NOT EXISTS Elib_client_settings (addon TEXT PRIMARY KEY, category TEXT, id TEXT, value TEXT)")
end

function Elib.Config.Save(addon, realm, category, id, value)
    sql.Query(string.format("INSERT OR REPLACE INTO Elib_client_settings (addon, category, id, value) VALUES (%q, %q, %q, %q)", addon, category, id, value))
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

        if Elib.Config.Addons[addon] and Elib.Config.Addons[addon][realm] and Elib.Config.Addons[addon][realm][category] and Elib.Config.Addons[addon][realm][category][id] then
            Elib.Config.Addons[addon][realm][category][id].value = value
            print("Loaded setting: " .. addon .. ", " .. category .. ", " .. id .. ", " .. value)
        else
            print("Setting not found in config: " .. addon .. ", " .. category .. ", " .. id)
        end
    end
end

Elib.Config.LoadClientSettings()