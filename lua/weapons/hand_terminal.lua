AddCSLuaFile()

SWEP.PrintName = "Hand terminal"
SWEP.Author = "DuLL_FoX"
SWEP.Instructions = "Left and right mouse to open the hand terminal"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = "models/joes/c_datapad.mdl"
SWEP.WorldModel = "models/joes/w_datapad.mdl"
SWEP.Category = "Terminals"
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

-- Open the hand terminal text editor
function SWEP:PrimaryAttack()
    if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then return end
    net.Start("OpenHandTerminalText")
    net.WriteString(GetHandTerminalText(self:GetOwner()) or "")
    net.Send(self:GetOwner())
    end

-- Open the hand terminal text editor
function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end