if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ConsoleUpdateText")
    util.AddNetworkString("ConsoleUpdatePassword")
    util.AddNetworkString("SendConsole")
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Console"
ENT.Category = "Consoles"
ENT.Author = "DuLL_FoX"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Console Data
function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ConsolePassword")

    if SERVER then
        self:SetConsolePassword("")
    end
end

-- Console Initialize
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

-- Console Use
function ENT:Use(activator)
    if not activator:IsPlayer() then return end
    net.Start("SendConsole")
    net.WriteEntity(self)
    net.WriteString(GetConsoleText(self))
    net.WriteString(self:GetConsolePassword())
    net.Send(activator)
end