freeslot("MT_HLMELEESENTINEL")
freeslot(
    "sfx_crbmss",
    "sfx_crbhw1",
    "sfx_crbhw2",
    "sfx_crbhe1",
    "sfx_crbhe2",
    "sfx_crbhe3"
)

mobjinfo[MT_HLMELEESENTINEL] = {
    spawnstate = S_INVISIBLE,
    spawnhealth = 1,
    flags = MF_MISSILE | MF_NOGRAVITY,
    radius = 3 * FU,
    height = 3 * FU,
}

HL.AnimationType.Crowbar = {
    Hit = HL.CreateAnimationType()
}

---@class hlweapon_t
HL.Weapons.Crowbar = {
    Name = "Crowbar",
    Class = HL.WeaponClass.Melee,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.None,

        Fire = {
            Cooldown = 9,
            Automatic = true,
            Damage = FU * 5,
            DamageVariance = 0,
            Spread = 0,

            Projectile = {
                -- Set the speed to an incredibly miniscule
                -- value so that it can run line collision hooks
                Speed = 1,
                Object = MT_HLMELEESENTINEL,
                Homing = false,
                Gravity = false,
                Fuse = 4
            },

            FireSound = {
                sfx_crbmss
            },

            HitEnemySound = {
                sfx_crbhe1,
                sfx_crbhe2,
                sfx_crbhe3
            },

            HitWallSound = {
                sfx_crbhw1,
                sfx_crbhw2
            }
        }
    }
}

HL.Viewmodels[HL.Weapons.Crowbar.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("CROWBAR_READY", 12, { [1] = 2 }),
    [HL.AnimationType.Idle] = {
        HL.NewWeaponAnimation("CROWBAR_IDLE1-", 35, { [1] = 3 }),
        HL.NewWeaponAnimation("CROWBAR_IDLE2-", 77, { [1] = 3 })
    },
    [HL.AnimationType.Primary] = {
        HL.NewWeaponAnimation("CROWBAR_MISS1-", 10, { [1] = 2 }),
        HL.NewWeaponAnimation("CROWBAR_MISS2-", 13, { [1] = 2 }),
        HL.NewWeaponAnimation("CROWBAR_MISS3-", 18, { [1] = 2 })
    },
    [HL.AnimationType.Crowbar.Hit] = {
        HL.NewWeaponAnimation("CROWBAR_HIT1-", 10, { [1] = 2 }),
        HL.NewWeaponAnimation("CROWBAR_HIT2-", 13, { [1] = 2 }),
        HL.NewWeaponAnimation("CROWBAR_HIT3-", 18, { [1] = 2 })
    }
}

HL.AnimationMap[HL.AnimationType.Crowbar.Hit] = function() return HL.AnimationType.Idle end

---@param player player_t
---@param weapon hlweapon_t
---@return boolean
addHook("HL_OnPrimaryUse", function(player, weapon)
    local yaw = player.mo.angle
    local pitch = player.aiming

    local projectile = HL.FireProjectileWeapon(player, weapon, weapon.PrimaryFire)

    P_MoveOrigin( 
        projectile,
        projectile.x + FixedMul(cos(yaw), cos(pitch)) * 40,
        projectile.y + FixedMul(sin(yaw), cos(pitch)) * 40,
        projectile.z + sin(pitch) * 40
    )
    
    -- Height should be at its largest
    -- when the aiming angle is centered.
    projectile.height = 32 * abs( cos(pitch) ) + 16 * FRACUNIT

    -- Radius should be at its largest
    -- when the player is looking straight up.
    projectile.radius = 32 * abs( sin(pitch) ) + 16 * FRACUNIT

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Primary)
    return true
end, HL.Weapons.Crowbar.Name)

---@param player player_t
local function CrowbarSetAnimation(player)
    ---@class hlplayer_t

    -- stupid fucking hack,
    -- if you're reading this don't do this
    local hl = player.HL

    local anim_number = hl.ViewmodelData.Animation.Sentinel:match("CROWBAR_MISS(%d+)-")

    if anim_number then
        hl.ViewmodelData.Animation = HL.Viewmodels[HL.Weapons.Pistol.Name][HL.AnimationType.Crowbar.Hit][anim_number]
    end
end

addHook("HL_OnProjectileHit", function(player, projectile, target)
    if not (target.flags & MF_ENEMY) then
        return
    end

    HL.SetAnimation(player, HL.AnimationType.Crowbar.Hit, true)
end, HL.Weapons.Crowbar.Name)

addHook("HL_OnWeaponLineHit", function(player, projectile, line)
    HL.SetAnimation(player, HL.AnimationType.Crowbar.Hit, true)
end, HL.Weapons.Crowbar.Name)