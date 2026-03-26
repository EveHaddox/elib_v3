// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Network Module
///////////////////

Elib.Network = Elib.Network or {}
Elib.Network.Registered = Elib.Network.Registered or {}

local NETWORK = {}
NETWORK.__index = NETWORK


///////////////////
// Create Instance
///////////////////
function Elib.NewNetwork(addonName)
    local instance = setmetatable({}, NETWORK)

    instance.addonName = addonName or "Unknown"
    instance.prefix = string.lower(addonName) .. "_"
    instance.messages = {}
    instance.cooldowns = {}
    instance.debug = false

    table.insert(Elib.Network.Registered, instance)

    MsgC(Color(49, 149, 207), "[Elib Network] ", Color(230, 230, 230), "Initialized network for: " .. instance.addonName .. "\n")

    return instance
end


///////////////////
// Configuration
///////////////////
function NETWORK:SetDebug(enabled)
    self.debug = enabled
end


///////////////////
// Registration
///////////////////
function NETWORK:GetNetString(name)
    local msg = self.messages[name]
    if msg then return msg.netString end

    return self.prefix .. name
end

function NETWORK:Register(name, options)
    options = options or {}

    local netString = options.netString or (self.prefix .. name)

    self.messages[name] = {
        netString = netString,
        cooldown = options.cooldown or 0,
    }

    if SERVER then
        util.AddNetworkString(netString)
    end

    return self
end


///////////////////
// Receive
///////////////////
function NETWORK:Receive(name, handler)
    local netString = self:GetNetString(name)
    local msg = self.messages[name]
    local cooldown = msg and msg.cooldown or 0

    if SERVER then
        net.Receive(netString, function(len, ply)
            if cooldown > 0 then
                self.cooldowns[ply] = self.cooldowns[ply] or {}
                local lastTime = self.cooldowns[ply][name] or 0

                if CurTime() - lastTime < cooldown then
                    if self.debug then
                        MsgC(Color(207, 144, 49), "[Elib.Network:" .. self.addonName .. "] ",
                            Color(230, 230, 230), "Cooldown blocked: " .. name .. " from " .. ply:Nick() .. "\n")
                    end
                    return
                end

                self.cooldowns[ply][name] = CurTime()
            end
            handler(ply)
        end)
    else
        net.Receive(netString, function()
            handler()
        end)
    end

    return self
end


///////////////////
// Send
///////////////////
function NETWORK:Send(name, a, b)
    local netString = self:GetNetString(name)

    if SERVER then
        local target = a
        local writeFunc = b

        net.Start(netString)
        if writeFunc then writeFunc() end
        net.Send(target)
    else
        local writeFunc = a

        net.Start(netString)
        if writeFunc then writeFunc() end
        net.SendToServer()
    end
end


///////////////////
// Broadcast
///////////////////
function NETWORK:Broadcast(name, writeFunc)
    if CLIENT then return end

    local netString = self:GetNetString(name)

    net.Start(netString)
    if writeFunc then writeFunc() end
    net.Broadcast()
end


///////////////////
// Cleanup
///////////////////
if SERVER then
    hook.Add("PlayerDisconnected", "Elib.Network.ClearCooldowns", function(ply)
        for _, network in ipairs(Elib.Network.Registered) do
            network.cooldowns[ply] = nil
        end
    end)
end


--[[
Yo eve, little example of how to use this.

EAddon.Net = Elib.NewNetwork("myaddon")

EAddon.Net:Register("use_item", { cooldown = 0.3, netString = "EGInv:UseItem" }) -- table is optional. can use a custom netstring name if you want...
EAddon.Net:Register("open") -- bog standard. no cooldown etc

EAddon.Net:Send("open", ply, function()
    net.WriteString("string!")

    net.WriteUInt(120, 8)
    net.WriteUInt(120, 8)
end)

AND ON THE CLIENT, JUST USE

EAddon.Net:Send("use_item", function()
    net.WriteString("item_id_example")  
end)


simple shit!


TO DO::::
add chunking. auto compress tables even if we use it in the code, it reworks it :)
]]--
