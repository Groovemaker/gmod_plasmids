-- SWEP Info
SWEP.Base = "plasmid_base"
SWEP.PrintName = "Hypnotize"
SWEP.Instructions = "M1 to Cope!"
SWEP.Category = "Runics Bioshock Plasmids"

-- SWEP Vars
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "grenade"
SWEP.FiresUnderwater = true
SWEP.CSMuzzleFlashes = false
SWEP.Primary.Damage = 1
SWEP.Throwable = true

-- Sounds
SWEP.PlasmidSounds = {
	"items/suitchargeok1.wav",
}

SWEP.PlasmidDeploySound = "weapons/bugbait/bugbait_squeeze3.wav"

---- Main Shared Part
function SWEP:Think()
	if self:GetNextPrimaryFire() < CurTime() && self.Drawn == 0 then
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:EmitSound(self.PlasmidDeploySound,75,math.random(77,88))
		self.Drawn = 1
	end
end

-- Primary Attack
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	-- Send Primary Attack Anim
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:SetAnimation(PLAYER_ATTACK1)
	
	-- Serverside Part
	if SERVER then
		self:BroadcastAttackEffects()

		local TargNPC = owner:GetEyeTrace().Entity
		if TargNPC != nil and TargNPC:IsNPC() then
			TargNPC:AddEntityRelationship(owner, D_LI, 99)
		end
	end

	-- Shared
	self:EmitSound(table.Random(self.PlasmidSounds),75,math.random(111,188))
	self.Drawn = 0
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

-- We have No Secondary Attack
function SWEP:SecondaryAttack()
	return false
end

---- Main Clientside Code
if CLIENT then
	-- Electrobeam Material
	SWEP.SPRITE = Material("sprites/light_glow02_add")

	-- Variables
	local WH = 44

	function SWEP:DrawGlow(useViewModel)
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local att

		if useViewModel then
			att = self.VM:GetAttachment(self.VM:LookupAttachment("0"))
		else
			att = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		end

		if not att then return end

		if useViewModel then
			local Light_Hand = DynamicLight(owner:EntIndex())
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 11
				Light_Hand.b = 255
				Light_Hand.brightness = 11
				Light_Hand.Decay = 11
				Light_Hand.Style = 5
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		else
			local Light_Hand = DynamicLight(owner:EntIndex())
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 11
				Light_Hand.b = 255
				Light_Hand.brightness = 8
				Light_Hand.Decay = 11
				Light_Hand.Style = 5
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		end
	end

	function SWEP:DrawEffects(useViewModel)
		if useViewModel and not self.VM then return end
		if not self.EffectTimer then 

			return 
		end

		if RealTime() > self.EffectTimer then
			self.EffectTimer = nil
			return
		end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local att

		if useViewModel then
			att = self.VM:GetAttachment(self.VM:LookupAttachment("0"))
			PrintTable(self.VM:GetAttachments())
		else
			att = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		end

		if not att then return end

		render.SetMaterial(self.SPRITE)

		if useViewModel then
			render.DrawSprite(att.Pos, WH, WH, Color( 1, 11, 255 ) )
			local Light_Hand = DynamicLight(owner:EntIndex()*2)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 11
				Light_Hand.b = 255
				Light_Hand.brightness = 17
				Light_Hand.Decay = 11
				Light_Hand.Style = 5
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		else
			render.DrawSprite(att.Pos, WH, WH, Color( 1, 11, 255 ) )
			local Light_Hand = DynamicLight(owner:EntIndex()*2)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 11
				Light_Hand.b = 255
				Light_Hand.brightness = 14
				Light_Hand.Decay = 11
				Light_Hand.Style = 5
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		end
	end

	-- Viewmodel is Drawn
	function SWEP:ViewModelDrawn()
		self:DrawEffects(true)
		self:DrawGlow(true)
	end

	-- Worldmodel is Drawn
	function SWEP:DrawWorldModel()
		self:DrawModel(1)
		self:DrawEffects(false)
		self:DrawGlow(false)
	end

	function SWEP:DoAttackEffects()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		self.EffectTimer = RealTime() + (self.Primary.Delay/1.5)
	end
end