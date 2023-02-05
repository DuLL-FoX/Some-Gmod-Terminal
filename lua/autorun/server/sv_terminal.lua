local terminalText = {}

util.AddNetworkString("TerminalText")

net.Receive("TerminalText", function(len, ply)
  local entity = net.ReadEntity()
  local text = net.ReadString()
  terminalText[entity:EntIndex()] = text
end)

hook.Add("EntityRemoved", "ClearTerminalText", function(ent)
  terminalText[ent:EntIndex()] = nil
end)

function GetTerminalText(ent)
  return terminalText[ent:EntIndex()]
end