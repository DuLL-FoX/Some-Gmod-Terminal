if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Hand hack terminal"
SWEP.Author = "DuLL_FoX"
SWEP.Instructions = "Left and right mouse to open the hand terminal"
SWEP.Spawnable = true
SWEP.ViewModel = "models/joes/c_datapad.mdl"
SWEP.WorldModel = "models/joes/w_datapad.mdl"
SWEP.DrawAmmo = false
SWEP.UseHands = true
SWEP.Category = "Terminals"
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

-- Open the hand terminal text editor
function SWEP:PrimaryAttack()
    if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then return end
    self:SendOpenHandTerminalText()
end

-- Open the hand terminal text editor
function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

-- Network the hand terminal text editor open event
function SWEP:SendOpenHandTerminalText()
    if CLIENT then
        OpenHandTerminal()
    end
end