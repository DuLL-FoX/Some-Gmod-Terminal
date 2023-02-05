local terminalText = {}
local terminalPassword = {}

util.AddNetworkString("TerminalText")
util.AddNetworkString("TerminalPassword")

hook.Add("EntityRemoved", "ClearTerminalText", function(ent)
  terminalText[ent:EntIndex()] = nil
  terminalPassword[ent:EntIndex()] = nil
end)

net.Receive("TerminalText", function(len, ply)
  local entity = net.ReadEntity()
  local text = net.ReadString()
  terminalText[entity:EntIndex()] = text
end)

net.Receive("TerminalPassword", function(len, ply)
  local entity = net.ReadEntity()
  local password = net.ReadString()
  terminalPassword[entity:EntIndex()] = password
end)

function GetTerminalText(ent)
  return terminalText[ent:EntIndex()]
end

function GetTerminalPassword(ent)
  return terminalPassword[ent:EntIndex()]
end