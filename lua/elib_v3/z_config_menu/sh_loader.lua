// manual initializing
function Elib.IncludeClient(path)
    local str = "elib_v3/z_config_menu/" .. path .. ".lua"

    --MsgC(Color(200, 180, 100), "[eve] ", Color(220, 220, 220), "client loaded ".. str .."\n")

    if (CLIENT) then
        include(str)
    end

    if (SERVER) then
        AddCSLuaFile(str)
    end
end

function Elib.IncludeServer(path)
    local str = "elib_v3/z_config_menu/" .. path .. ".lua"

    --MsgC(Color(100, 150, 200), "[eve] ", Color(220, 220, 220), "server loaded ".. str .."\n")

    if (SERVER) then
        include(str)
    end
end

function Elib.IncludeShared(path)
    Elib.IncludeServer(path)
    Elib.IncludeClient(path)
end

//////////////////////////////
// Initialising Config Menu //
//////////////////////////////
if (CLIENT) then
    Elib.IncludeClient("elements/cl-menu")
    Elib.IncludeClient("elements/cl-addons")
end

//////////////////////////////

////////////
// Values //
////////////
Elib.Config = Elib.Config or {}
Elib.Config.Addons = Elib.Config.Addons or {}

//////////////////////
// Config Functions //
//////////////////////
-- add functions to actualy use this

hook.Run("Elib:ConfigLoaded")