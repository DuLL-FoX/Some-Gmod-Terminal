local terminalText = {}
local terminalPassword = {}
local handTerminalText = {}

-- Add network strings for communication between server and client
util.AddNetworkString("TerminalOpen")
util.AddNetworkString("SetTerminalText")
util.AddNetworkString("SetTerminalPassword")
util.AddNetworkString("OpenHandTerminalText")

-- Clear terminal text and password when the entity is removed
hook.Add("EntityRemoved", "ClearTerminalText", function(ent)
  terminalText[ent:EntIndex()] = nil
  terminalPassword[ent:EntIndex()] = nil
end)

-- Receive terminal text update from client
net.Receive("SetTerminalText", function(len, ply)
  local entity = net.ReadEntity()
  local text = net.ReadString()
  terminalText[entity:EntIndex()] = text
end)

-- Receive terminal password update from client
net.Receive("SetTerminalPassword", function(len, ply)
  local entity = net.ReadEntity()
  local password = net.ReadString()
  terminalPassword[entity:EntIndex()] = password
end)

-- Receive hand terminal text update from client
net.Receive("OpenHandTerminalText", function(len, ply)
  local text = net.ReadString()
  handTerminalText[ply:SteamID()] = text
end)

-- Function to get the text for a terminal entity
function GetTerminalText(ent)
  return terminalText[ent:EntIndex()]
end

-- Function to get the password for a terminal entity
function GetTerminalPassword(ent)
  return terminalPassword[ent:EntIndex()]
end

-- Function to get the text for a hand terminal
function GetHandTerminalText(ply)
  return handTerminalText[ply:SteamID()]
end