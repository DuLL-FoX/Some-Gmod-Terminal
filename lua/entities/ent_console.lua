AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Console"
ENT.Category = "Consoles"
ENT.Author = "DuLL_FoX"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    self:SetModel("models/props_lab/securitybank.mdl")
    if (SERVER) then
        self:SetUseType(SIMPLE_USE)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end
end

function ENT:Use(activator)
    if (not activator:IsPlayer()) then return end
    net.Start("TerminalOpen")
    net.WriteEntity(self)
    net.WriteString(GetTerminalText(self) or "")
    net.WriteString(GetTerminalPassword(self) or "")
    net.Send(activator)
end