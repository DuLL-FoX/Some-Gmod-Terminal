if SERVER then
    AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Console"
ENT.Category = "Consoles"
ENT.Author = "DuLL_FoX"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Terminal Data
function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ConsoleText")
    self:NetworkVar("String", 1, "ConsolePassword")

    if SERVER then
        self:SetConsoleText("")
        self:SetConsolePassword("")
    end
end

-- Terminal Initialize
function ENT:Initialize()
    self:SetModel("models/props_lab/securitybank.mdl")

    if SERVER then
        self:SetUseType(SIMPLE_USE)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:Wake()
        end
    end
end

-- Terminal Use
function ENT:Use(activator)
    if not activator:IsPlayer() then return end
    net.Start("ConsoleOpen")
    net.WriteEntity(self)
    net.Send(activator)
end