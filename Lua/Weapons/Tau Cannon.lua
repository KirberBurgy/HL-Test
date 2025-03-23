freeslot("MT_TAUPROJECTILE", "MT_WORLDTAU", "MT_HLCORONA")

freeslot("SPR_TAUP", "SPR_HLCR", "SPR_WTAU")
freeslot("S_TAU_PROJECTILE", "S_HL_CORONA", "S_TAU_WORLD")

freeslot("sfx_taudsc", "sfx_tauwd1", "sfx_tauwd2", "sfx_tauwd3")

states[S_TAU_PROJECTILE] = {
    tics = -1,
    sprite = SPR_TAUP,
    frame = A | FF_PAPERSPRITE,
    nextstate = S_NULL
}

states[S_HL_CORONA] = {
    tics = -1,
    sprite = SPR_HLCR,
    frame = A | FF_FLOORSPRITE | FF_ADD,
    nextstate = S_NULL
}

states[S_TAU_WORLD] = {
    tics = -1,
    sprite = SPR_WTAU,
    frame = A,
    nextstate = S_NULL
}

mobjinfo[MT_TAUPROJECTILE] = {
    spawnstate = S_TAU_PROJECTILE,
    spawnhealth = 1,
    radius = 5 * FU,
    height = 5 * FU,
    flags = MF_MISSILE | MF_PAPERCOLLISION,
}

mobjinfo[MT_HLCORONA] = {
    spawnstate = S_HL_CORONA,
    spawnhealth = 10000,
    radius = 48 * FU,
    height = 48 * FU,
    flags = MF_NOGRAVITY | MF_NOCLIPHEIGHT | MF_NOCLIP
}

mobjinfo[MT_WORLDTAU] = {
    spawnstate = S_TAU_WORLD,
    spawnhealth = 10000,
    radius = 32 * FU,
    height = 32 * FU,
    flags = MF_SPECIAL
}

HL.AnimationType.TauCannon = {
    SpinUp = HL.CreateAnimationType(),
    Spin   = HL.CreateAnimationType()
}

HL.RegisterProjectile(MT_TAUPROJECTILE)

---@param player player_t
HL.AnimationMap[HL.AnimationType.TauCannon.SpinUp] = function(player)
    if not (player.cmd.buttons & BT_FIRENORMAL) then
        return HL.AnimationType.Idle
    end

    return HL.AnimationType.TauCannon.Spin
end

HL.AnimationMap[HL.AnimationType.TauCannon.Spin] = function(player)
    if not (player.cmd.buttons & BT_FIRENORMAL) then
        return HL.AnimationType.Idle
    end

    return HL.AnimationType.TauCannon.Spin
end

---@class hlweapon_t
HL.Weapons.TauCannon = {
    Name = "Tau Cannon",
    Class = HL.WeaponClass.Experimental,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Uranium,

        Fire = {
            Cooldown = 10,
            Automatic = true,
            Damage = FU * 20,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 2,
            FireSound = {
                sfx_taudsc
            },

            Projectile = {
                Object = MT_TAUPROJECTILE,
                Speed = 200 * FU,
                Gravity = false,
                Homing = false
            }
        },
    },
    SecondaryFire = {
        AmmoType = HL.AmmunitionType.Uranium,

        Fire = {
            Cooldown = 0,
            Automatic = true,
            Damage = FU * 25,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 1,
        }
    }
}

HL.Viewmodels[HL.Weapons.TauCannon.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0 * FU,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("TAU_READY", 36, { [1] = 1 }),
    [HL.AnimationType.Idle] = HL.NewWeaponAnimation("TAU_IDLE1-", 61, { [1] = 3 }),
    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("TAU_FIRE", 31, { [1] = 1 }),
    [HL.AnimationType.Secondary] = HL.NewWeaponAnimation("TAU_SFIRE", 41, { [1] = 1 }),

    [HL.AnimationType.TauCannon.SpinUp] = HL.NewWeaponAnimation("TAU_SPINUP", 31, { 
        [1] = 1 
    }, { 
        [10] = sfx_tauwd1 
    }),

    [HL.AnimationType.TauCannon.Spin] = HL.NewWeaponAnimation("TAU_SPIN", 16, { 
        [1] = 1 
    }, { 
        [8] = { sfx_tauwd2, sfx_tauwd3 } 
    })
}

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    ---@class hlplayer_t
    local hl = player.HL

    if hl.ViewmodelData.State == HL.AnimationType.TauCannon.SpinUp
    or hl.ViewmodelData.State == HL.AnimationType.TauCannon.Spin then
        return true
    end
end, HL.Weapons.TauCannon.Name)

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnSecondaryUse", function(player, weapon)
    ---@class hlplayer_t
    local hl = player.HL
    
    -- If the weapon is not in SpinUp or Spin, start the spin-up animation.
    if hl.ViewmodelData.State ~= HL.AnimationType.TauCannon.SpinUp
    and hl.ViewmodelData.State ~= HL.AnimationType.TauCannon.Spin then
        HL.SetAnimation(player, HL.AnimationType.TauCannon.SpinUp)
        
        weapon.SpinTime = 1
        weapon.AmmoUsed = 0

        return true
    end

    if hl.ViewmodelData.State == HL.AnimationType.TauCannon.SpinUp then
        return true
    end

    weapon.SpinTime = $ + 1

    if weapon.SpinTime % 10 == 0 and weapon.SpinTime <= (13 * 10) and hl.Inventory.Ammo[HL.AmmunitionType.Uranium] > 0 then
        weapon.AmmoUsed = weapon.AmmoUsed + 1
        hl.Inventory.Ammo[HL.AmmunitionType.Uranium] = hl.Inventory.Ammo[HL.AmmunitionType.Uranium] - 1
    end 

    if weapon.SpinTime > 10 * TICRATE then
        HL.TauCannonMisfire(player, weapon)
    end

    return true
end, HL.Weapons.TauCannon.Name)


---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnSecondaryStop", function(player, weapon)
    ---@class hlplayer_t
    local hl = player.HL

    if not (weapon.SpinTime and weapon.AmmoUsed and hl.ViewmodelData.State == HL.AnimationType.TauCannon.Spin) then
        return
    end

    if weapon.AmmoUsed < 1 then
        return
    end
    
    local multiplier = FRACUNIT * (weapon.AmmoUsed + 1) / 14

    -- Max charge: 13 ammo → 200 damage
    weapon.PrimaryFire.Fire.Damage = 200 * multiplier

    HL.FireProjectileWeapon(player, weapon, weapon.PrimaryFire)
    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Secondary)
    
    local force = 80 * multiplier

    local yaw = player.mo.angle
    local pitch = player.aiming

    player.mo.momx = $ - FixedMul( force, FixedMul( cos(yaw), cos(pitch) ) )
    player.mo.momy = $ - FixedMul( force, FixedMul( sin(yaw), cos(pitch) ) )
    player.mo.momz = $ - FixedMul( force / 2, sin(pitch) )

    player.HL.Cooldown = 3 * TICRATE / 2

    -- Reset the weapon damage after firing.
    weapon.PrimaryFire.Fire.Damage = FRACUNIT * 20
    return true

end, HL.Weapons.TauCannon.Name)


---@param player player_t
---@param projectile mobj_t
---@param line line_t
addHook("HL_OnWeaponLineHit", function(player, projectile, line)
    -- atan2(-dx, dy)
---@diagnostic disable-next-line: param-type-mismatch
    local perpendicular_angle = R_PointToAngle2(line.v1.x, line.v1.y, line.v2.x, line.v2.y)
    local lx, ly = P_ClosestPointOnLine(projectile.x, projectile.y, line)

    local spot = P_SpawnMobj(lx, ly, projectile.z, MT_HLCORONA)
    spot.color = SKINCOLOR_ORANGE
    spot.fuse = 4 * TICRATE
    spot.angle = perpendicular_angle
end, HL.Weapons.TauCannon.Name)

---@param corona mobj_t
addHook("MobjThinker", function(corona)
    if not (corona and corona.valid) then
        return
    end

    if corona.fuse % 14 == 0 then
        local transparency = FF_TRANS10 * (13 - corona.fuse / 14)

        corona.frame = A | FF_PAPERSPRITE | FF_ADD | transparency
    end
end, MT_HLCORONA)


