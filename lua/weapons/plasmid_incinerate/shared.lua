-- Plasmid Cvars
local VAR_RANGE = CreateConVar("plasmids_incinerate_range",300,FCVAR_NONE,"Incinerate Plasmid Range",1)
local VAR_FDMG = CreateConVar("plasmids_incinerate_fire_damage",1,FCVAR_NONE,"Incinerate Plasmid Fire Damage",1)
local VAR_FFUEL = CreateConVar("plasmids_incinerate_fire_life",5,FCVAR_NONE,"Incinerate Plasmid Fire Lifetime",1)
local VAR_FSIZ = CreateConVar("plasmids_incinerate_fire_size",111,FCVAR_NONE,"Incinerate Plasmid Fire Size",1)

-- SWEP Info
SWEP.PrintName = "Incinerate"
SWEP.Instructions = "M1 to Burn!"
SWEP.Category = "Runics Bioshock Plasmids"

-- SWEP Vars
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "plasmid_base"

SWEP.HoldType = "magic"
SWEP.FiresUnderwater = true
SWEP.CSMuzzleFlashes = false
SWEP.Primary.Damage = 1

-- Electrobeam Material
SWEP.SPRITE = Material("sprites/light_glow02_add")

-- Sounds
SWEP.PlasmidSounds = {
	"ambient/fire/gascan_ignite1.wav",
	"ambient/fire/ignite.wav"
}

SWEP.PlasmidDeploySound = "ambient/fire/ignite.wav"

---- Main Serverside Part

if SERVER then

	-- Modded Fire Function from ttt_flame.lua
	function SWEP:SpawnFire(pos)
		local fire = ents.Create("env_fire")
		if not IsValid(fire) then return end
		fire:SetPos(pos)
		fire:SetKeyValue("spawnflags", tostring(128 + 4))
		fire:SetKeyValue("firesize", VAR_FSIZ:GetInt() * math.Rand(0.7, 1.1))
		fire:SetKeyValue("fireattack", 1)
		fire:SetKeyValue("health", VAR_FFUEL:GetInt())
		fire:SetKeyValue("damagescale", VAR_FDMG:GetInt())

		fire:Spawn()
		fire:Activate()

		return fire
	end

end

---- Main Shared Part

-- Primary Attack
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	-- Send Primary Attack Anim
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- Serverside Part
	if SERVER then
		self:BroadcastAttackEffects()
		self:SpawnFire(owner:GetEyeTrace().HitPos)

		local Things = ents.FindInSphere(owner:GetEyeTrace().HitPos, VAR_RANGE:GetInt())
		for K, V in pairs(Things) do
			if V:IsPlayer() or V:IsNPC() or string.sub(V:GetClass(),1,5) =="prop_" then
				print(V)
				if(V:EntIndex() == owner:EntIndex()) then
					return
				else
					V:Ignite(VAR_FFUEL)
				end
			end
		end
	end

	-- Shared
	if not IsFirstTimePredicted() then return end

	self:EmitSound(table.Random(self.PlasmidSounds),75,math.random(77,88))

	local effect = EffectData()
	effect:SetOrigin(owner:GetEyeTrace().HitPos)
	util.Effect( "HelicopterMegaBomb" , effect )

end

-- We have No Secondary Attack
function SWEP:SecondaryAttack()
	return false
end

---- Main Clientside Code
if CLIENT then

	-- Variables
	local WH = 44

	-- Draw Viewmodel Glow FX
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
			local Light_Hand = DynamicLight(owner:EntIndex())
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 255
				Light_Hand.g = 33
				Light_Hand.b = 11
				Light_Hand.brightness = 11
				Light_Hand.Decay = 11
				Light_Hand.Style = 11
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		else
			local Light_Hand = DynamicLight(owner:EntIndex())
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 255
				Light_Hand.g = 33
				Light_Hand.b = 11
				Light_Hand.brightness = 8
				Light_Hand.Decay = 11
				Light_Hand.Style = 11
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

		-- Draw the flame.
		render.SetMaterial(self.SPRITE)
		render.DrawSprite(att.Pos, WH, WH, Color( 255, 99, 44 ) )
		if useViewModel then
			local Light_Hand = DynamicLight(owner:EntIndex()*2)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 255
				Light_Hand.g = 33
				Light_Hand.b = 11
				Light_Hand.brightness = 17
				Light_Hand.Decay = 11
				Light_Hand.Style = 5
				Light_Hand.Size = 33
				Light_Hand.DieTime = CurTime() + self.Primary.Delay/1.5
			end
		else
			local Light_Hand = DynamicLight(owner:EntIndex()*2)
			if ( Light_Hand ) then
				Light_Hand.pos = att.Pos
				Light_Hand.r = 255
				Light_Hand.g = 33
				Light_Hand.b = 11
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
