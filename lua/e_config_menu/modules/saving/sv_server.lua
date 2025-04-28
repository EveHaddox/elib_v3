// Script made by Eve Haddox
// discord evehaddox


// Saving server side
if not sql.TableExists("Elib_settings") then
    sql.Query("CREATE TABLE IF NOT EXISTS Elib_settings (addon TEXT PRIMARY KEY, category TEXT, id TEXT, value TEXT, vType TEXT)")
end

local function Save(addon, realm, category, id, value, vType)
    sql.Query(string.format("INSERT OR REPLACE INTO Elib_settings (addon, category, id, value, vType) VALUES (%q, %q, %q, %q, %q)", addon, category, id, value, vType))
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

        if Elib.Config.Addons[addon] and Elib.Config.Addons[addon][realm] and Elib.Config.Addons[addon][realm][category] and Elib.Config.Addons[addon][realm][category][id] then
            Elib.Config.Addons[addon][realm][category][id].value = value
            print("Loaded setting: " .. addon .. ", " .. category .. ", " .. id .. ", " .. value .. ", " .. vType)
        else
            // not found
            --print("Setting not found in config: " .. addon .. ", " .. category .. ", " .. id)
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

Elib.Config.LoadSettings()

// networking
util.AddNetworkString("Elib.Config.Save")

net.Receive("Elib.Config.Save", function(len, ply)

    if not ply:IsSuperAdmin() then return end

    local addon    = net.ReadString()
    local category = net.ReadString()
    local id       = net.ReadString()
    local value    = net.ReadString()
    local vType    = net.ReadString()

    Save(addon, "server", category, id, value, vType)

end)