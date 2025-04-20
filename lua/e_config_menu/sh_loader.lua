// Script made by Eve Haddox
// discord evehaddox


//////////////////////////////
// Initialising Config Menu //
//////////////////////////////
if (CLIENT) then
    local path = "e_config_menu/"

    Elib.IncludeClient(path .."elements/cl_menu")
    Elib.IncludeClient(path .."elements/cl_addons")
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