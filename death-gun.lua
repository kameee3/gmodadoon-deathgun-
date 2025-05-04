if CLIENT then
    SWEP.Icon = "materials/icon/death-gun.png"
end

SWEP.PrintName = "Deathgun"
SWEP.Author = "りれみ"
SWEP.Instructions = "Hold left mouse button to shoot, right mouse button for explosion"
SWEP.Category      = "death"
SWEP.Spawnable = true
SWEP.AdminOnly = true 
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = Sound("Weapon_SMG1.Single")
SWEP.ClassName = "weapon_deathgun"

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1
SWEP.Secondary.Automatic = false


function SWEP:CreateExplosion(position)
       if SERVER then
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(position)
    explosion:SetOwner(self:GetOwner())
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "100")
    explosion:Fire("Explode", 0, 0)
    explosion:EmitSound("ambient/explosions/explode_4.wav")
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    local aimVector = owner:GetAimVector()
    local startPos = owner:GetShootPos()
    local endPos = startPos + aimVector * 1000

    local trace = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = owner
    })

    if trace.Hit then
        
        if trace.Entity:IsNPC() and trace.Entity:GetClass() == "npc_helicopter" then
            local dmg = DamageInfo()
            dmg:SetDamage(100)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            trace.Entity:TakeDamageInfo(dmg)
        end
        
        
        self:CreateExplosion(trace.HitPos)
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end


function SWEP:PrimaryAttack()
    if self:Clip1() > 0 then
        self:EmitSound(self.Primary.Sound)
        self:TakePrimaryAmmo(1)

        
        self:ShootBullet(50, 0, 0)
  if VManip then
            VManip:PlayAnim("use", 1.0)
        end

        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    end
end



function SWEP:Reload()
    local ammoCount = self:GetOwner():GetAmmoCount(self.Primary.Ammo)

    
    if ammoCount > 0 and self:Clip1() < self.Primary.ClipSize then
        self:DefaultReload(ACT_VM_RELOAD)
        self:EmitSound("Weapon_SMG1.Reload")
    end
end
