-- Plasmid Cvars
local VAR_DMG = CreateConVar("plasmids_electrobolt_damage", 20, FCVAR_NONE, "Electrobolt Plasmid Damage",1)

-- SWEP Info
SWEP.Base = "plasmid_base"
SWEP.PrintName = "Electrobolt"
SWEP.Instructions = "M1 to Zap!"
SWEP.Category = "Runics Bioshock Plasmids"

-- SWEP Vars
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "magic"
SWEP.FiresUnderwater = true
SWEP.CSMuzzleFlashes = false
SWEP.Primary.Force = 441

-- Sounds
SWEP.PlasmidSounds = {
	"ambient/energy/zap8.wav",
	"ambient/energy/zap7.wav"
}

SWEP.PlasmidDeploySound = "ambient/energy/spark4.wav"

-- Serverside
if SERVER then
	function SWEP:WireFuckery()
		local owner = self:GetOwner()
		self.ShockAimEnt = owner:GetEyeTrace().Entity
		self.ShockAimClass = self.ShockAimEnt:GetClass()
		if self.ShockAimClass == "gmod_wire_button" then
			WireLib.TriggerOutput(self.ShockAimEnt, "Out", 1)
		end
		if self.ShockAimClass == "gmod_wire_lamp" then
			WireLib.TriggerInput(self.ShockAimEnt, "On", 1)
		end
	end
end

-- Primary Attack
function SWEP:PrimaryAttack()

	local owner = self:GetOwner()

	self:ShootBullet(VAR_DMG:GetInt())
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not IsFirstTimePredicted() then return end

	self:EmitSound(table.Random(self.PlasmidSounds),75,math.random(100,155))

	-- Sparks Effect
	local effect = EffectData()
	effect:SetOrigin(owner:GetEyeTrace().HitPos)
	util.Effect( "cball_explode" , effect )

	-- Electro Hitbox Effect
	effect = EffectData()
	effect:SetEntity(owner:GetEyeTrace().Entity)
	effect:SetMagnitude(111)
	util.Effect( "TeslaHitboxes" , effect )

	if SERVER then
		self:BroadcastAttackEffects()
		self:WireFuckery()
	end
end

-- No Secondary Attack
function SWEP:SecondaryAttack()
	return false
end


---- Main Clientside Code

if CLIENT then
	-- Electrobeam Material
	SWEP.BEAM = Material("cable/blue_elec")
	SWEP.SPRITE = Material("sprites/light_glow02_add")

	-- Variables
	local WH = 44
	local MaxBeams = 11

	function SWEP:DrawGlow(useViewModel)
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local att

		if useViewModel then
			att = self.VM:GetAttachment(self.VM:LookupAttachment("muzzle"))
		else
			att = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		end

		if not att then return end

		if useViewModel then
			local Light_Hand = DynamicLight(owner:EntIndex()*4)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 44
				Light_Hand.b = 255
				Light_Hand.brightness = 9
				Light_Hand.Decay = 11
				Light_Hand.Style = 8
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		else
			local Light_Hand = DynamicLight(owner:EntIndex()*4)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 1
				Light_Hand.g = 44
				Light_Hand.b = 255
				Light_Hand.brightness = 8
				Light_Hand.Decay = 11
				Light_Hand.Style = 8
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		end
	end

	function SWEP:DrawEffects(useViewModel)
		if useViewModel and not self.VM then return end
		if not self.EffectTimer then return end

		if RealTime() > self.EffectTimer then
			self.EffectTimer = nil
			return
		end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local att

		if useViewModel then
			att = self.VM:GetAttachment(self.VM:LookupAttachment("muzzle"))
		else
			att = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		end

		if not att then return end

		local Max = 0.4 * (owner:GetPos():Distance(self.EffectEndPos) / 11)
		local Light_Hand = DynamicLight(owner:EntIndex())
		local startpos = att.Pos

		if ( Light_Hand ) then
			Light_Hand.pos = startpos
			Light_Hand.r = 111
			Light_Hand.g = 111
			Light_Hand.b = 255
			Light_Hand.brightness = 3
			Light_Hand.Decay = 500
			Light_Hand.Size = 512
			Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
		end

		local Light_EndPos = DynamicLight(owner:EntIndex()*3)
		if ( Light_EndPos ) then
			Light_EndPos.pos = self.EffectEndPos
			Light_EndPos.r = 111
			Light_EndPos.g = 111
			Light_EndPos.b = 255
			Light_EndPos.brightness = 3
			Light_EndPos.Decay = 500
			Light_EndPos.Size = 512
			Light_EndPos.DieTime = CurTime() + self.Primary.Delay/1.5
		end

		for I=1,MaxBeams do
			render.SetMaterial(self.BEAM)
			render.DrawBeam(startpos, self.EffectEndPos + Vector(math.random(-Max,Max),math.random(-Max,Max),math.random(-Max,Max)), 5, 3, 1, Color(200, 200, 255, 255))
		end

		render.SetMaterial(self.SPRITE)
		render.DrawSprite(startpos, WH, WH, Color( 111, 155, 255 ) )
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
		self.EffectEndPos = owner:GetEyeTrace().HitPos
	end
end