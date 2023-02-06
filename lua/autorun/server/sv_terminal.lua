include("autorun/sh_terminal.lua")
-- Add network strings for communication between server and client
util.AddNetworkString("OpenHandTerminalText")
util.AddNetworkString("ConsoleOpen")
util.AddNetworkString("ConsoleUpdateText")
util.AddNetworkString("ConsoleUpdatePassword")

net.Receive("ConsoleUpdateText", function(len, ply)
    local ent = net.ReadEntity()
    local text = net.ReadString()
    ent:SetConsoleText(text)
end)

net.Receive("ConsoleUpdatePassword", function(len, ply)
    local ent = net.ReadEntity()
    local password = net.ReadString()
    ent:SetConsolePassword(password)
end)