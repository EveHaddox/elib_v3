// Script made by Eve Haddox
// discord evehaddox


//////////////////////////////
// Initialising Config Menu //
//////////////////////////////
local path = "e_config_menu/"

Elib.LoadDirectory(path .."panels")

Elib.IncludeShared(path .. "modules/main/sh_main")
Elib.IncludeServer(path .. "modules/main/sv_main")

Elib.IncludeClient(path .."modules/saving/cl_client")
Elib.IncludeServer(path .."modules/saving/sv_server")

Elib.IncludeClient(path .."elements/cl_menu")
Elib.IncludeClient(path .."elements/cl_addons")

////////////
// Values //
////////////
Elib.Config = Elib.Config or {}
Elib.Config.Addons = Elib.Config.Addons or {}

//////////////////////
// Config Functions //
//////////////////////
-- add functions to actualy use this

hook.Run("Elib.FullyLoaded")
Elib.FullyLoaded = true // If the library finishes loading before addons hook this will make them load