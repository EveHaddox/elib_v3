// Script made by Eve Haddox
// discord evehaddox


///////////////////
// SV Notifications
///////////////////
if SERVER then
    util.AddNetworkString("Elib:AddNotification")

    function Elib.AddNotification(ply, text, type, length)
        net.Start("Elib:AddNotification")
        net.WriteString(text)
        net.WriteUInt(type, 3)
        net.WriteUInt(length, 8)
        net.Send(ply)
    end
else
    net.Receive("Elib:AddNotification", function()
        local text = net.ReadString()
        local type = net.ReadUInt(3)
        local length = net.ReadUInt(8)
        notification.AddLegacy(text, type, length)
    end)
end