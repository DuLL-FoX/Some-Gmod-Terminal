local consoleText = {}

hook.Add("EntityRemoved", "ConsoleRemoveText", function(ent)
    consoleText[ent:EntIndex()] = nil
end)

net.Receive("ConsoleUpdateText", function(len, ply)
    local ent = net.ReadEntity()
    local text = net.ReadString()
    consoleText[ent:EntIndex()] = text
end)

net.Receive("ConsoleUpdatePassword", function(len, ply)
    local ent = net.ReadEntity()
    local password = net.ReadString()
    ent:SetConsolePassword(password)
end)

function GetConsoleText(ent)
    return consoleText[ent:EntIndex()] or ""
end