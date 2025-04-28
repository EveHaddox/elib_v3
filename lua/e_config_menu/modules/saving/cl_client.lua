// Script made by Eve Haddox
// discord evehaddox


local TABLENAME = "elib_user_config"
local ROW_ID    = 1

-- Ensure the SQLite table exists
if not sql.TableExists(TABLENAME) then
    sql.Query(string.format(
        "CREATE TABLE %s(id INTEGER PRIMARY KEY, data TEXT);", TABLENAME
    ))
end

-- Load the entire config blob from SQLite and decode it
-- @return table: { [panelName] = settingsTable, ... }
function Elib.Config.LoadUserConfig()
    local raw = sql.QueryValue(string.format(
        "SELECT data FROM %s WHERE id = %d;", TABLENAME, ROW_ID
    ))
    if raw and raw ~= "" then
        local ok, tbl = pcall(util.JSONToTable, raw)
        if ok and type(tbl) == "table" then
            return tbl
        else
            -- Corrupt data: clear the row
            sql.Query(string.format(
                "DELETE FROM %s WHERE id = %d;", TABLENAME, ROW_ID
            ))
        end
    end
    return {}
end

-- Encode and save all panel settings to SQLite
-- @param allSettings table: { [panelName] = settingsTable, ... }
function Elib.Config.SaveUserConfig(allSettings)
    local json = util.TableToJSON(allSettings, true)
    -- Check if row exists
    if sql.QueryValue(string.format(
        "SELECT id FROM %s WHERE id = %d;", TABLENAME, ROW_ID
    )) then
        sql.Query(string.format(
            "UPDATE %s SET data = %s WHERE id = %d;",
            TABLENAME, sql.SQLStr(json), ROW_ID
        ))
    else
        sql.Query(string.format(
            "INSERT INTO %s(id, data) VALUES(%d, %s);",
            TABLENAME, ROW_ID, sql.SQLStr(json)
        ))
    end
end

-- Hook: Load and apply settings when the config menu opens
hook.Add("ELib_ConfigMenuOpen", "ELib_LoadUserConfig", function(menu)
    local saved = Elib.Config.LoadUserConfig()
    for _, panel in ipairs(menu:GetUserPanels()) do
        local name = panel.Name or panel:GetName()
        if istable(saved[name]) then
            panel:ApplySettingsTable(saved[name])
        end
    end
end)

-- Hook: Gather settings and save to SQLite when the config menu is saved
hook.Add("ELib_ConfigMenuSave", "ELib_SaveUserConfig", function(menu)
    local toSave = {}
    for _, panel in ipairs(menu:GetUserPanels()) do
        local name = panel.Name or panel:GetName()
        toSave[name] = panel:GetSettingsTable() or {}
    end
    Elib.Config.SaveUserConfig(toSave)
end)