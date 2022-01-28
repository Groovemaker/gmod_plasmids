if SERVER then
	util.AddNetworkString("plasmid_doattackeffects")
end

-- SWEP Info
SWEP.Author = "Runic, StyledStrike"
SWEP.Contact = "Steam"
SWEP.Purpose = "Splice your Genes"

-- SWEP Vars
SWEP.Spawnable = false
SWEP.AdminOnly = false


SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.5


SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 77
SWEP.Throwable = false



SWEP.UseHands			= true

SWEP.HoldType = "magic"
SWEP.FiresUnderwater = true
SWEP.CSMuzzleFlashes = false

function SWEP:Initialize()
	if self.Throwable == true then
		self.ViewModel			= "models/weapons/c_bugbait.mdl"
		self.WorldModel			= "models/weapons/w_bugbait.mdl"
	else
		self.ViewModel			= "models/jessev92/weapons/telekinesis_1h_c.mdl"
		self.WorldModel			= "models/effects/teleporttrail_alyx.mdl"
	end
	self:Setup(self:GetOwner())
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:EmitSound(self.PlasmidDeploySound,75,math.random(100,155))
	self:Setup(self:GetOwner())
end

function SWEP:Setup(ply)
	if not IsValid(ply) then return end

	if ply.GetViewModel and ply:GetViewModel():IsValid() then
		self.VM = ply:GetViewModel()
	end
end

function SWEP:GetHoldType()
	return self.HoldType
end

function SWEP:BroadcastAttackEffects()
	if SERVER then
		net.Start("plasmid_doattackeffects", true)
		net.WriteEntity(self)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive("plasmid_doattackeffects", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		if not ent.DoAttackEffects then return end

		ent:DoAttackEffects()
	end)
end