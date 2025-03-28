freeslot("MT_GLUONLASER", "MT_GLUONPARTICLE")

freeslot("S_GLUON_LASER", "S_GLUON_PARTICLE")

freeslot("SPR_GLST", "SPR_GLPT")

freeslot("sfx_egonup", "sfx_egongo", "sfx_egondn")

states[S_GLUON_LASER] = {
    sprite = SPR_GLST,
    frame = FF_ADD | FF_FLOORSPRITE | FF_TRANS30,
    tics = -1
}

states[S_GLUON_PARTICLE] = {
    sprite = SPR_GLPT,
    frame = FF_ADD | FF_TRANS90,
    tics = -1
}

mobjinfo[MT_GLUONLASER] = {
    spawnhealth = 1,
    spawnstate = S_GLUON_LASER,
    flags = MF_NOCLIPTHING | MF_NOCLIPHEIGHT | MF_NOGRAVITY
}

mobjinfo[MT_GLUONPARTICLE] = {
    spawnhealth = 1,
    spawnstate = S_GLUON_PARTICLE,
    flags = MF_NOCLIPTHING | MF_NOCLIPHEIGHT | MF_NOGRAVITY
}

---@class hlweapon_t
HL.Weapons.GluonGun = {
    Name = "Gluon Gun",
    Class = HL.WeaponClass.Experimental,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Uranium,

        Fire = {
            Cooldown = 0,
            Automatic = true,
            Damage = FU * 14 / 3,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 1
        },
    }
}

HL.Viewmodels[HL.Weapons.GluonGun.Name] = {
    Flags = V_FLIP,
    
    OffsetX = 352 * FU,
    OffsetY = 0,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("EGON_READY-", 16, { [1] = 1 }),
    [HL.AnimationType.Idle] = {
        HL.NewWeaponAnimation("EGON_IDLE1-", 60, { [1] = 1 }),
        --HL.NewWeaponAnimation("EGON_IDLE2-", 60, { [1] = 1 })
    },
    [HL.AnimationType.Primary] = {
        HL.NewWeaponAnimation("EGON_FIRE1-", 15, { [1] = 1 }),
        HL.NewWeaponAnimation("EGON_FIRE2-", 15, { [1] = 1 }),
        HL.NewWeaponAnimation("EGON_FIRE3-", 15, { [1] = 1 }),
        HL.NewWeaponAnimation("EGON_FIRE4-", 15, { [1] = 1 })
    }
}

---@param player player_t
---@param end_point_x fixed_t
---@param end_point_y fixed_t
local function SpawnGluonRay(player, end_point_x, end_point_y)
    local strip_length = 33

    local strips = FixedInt( R_PointToDist2(player.mo.x, player.mo.y, end_point_x, end_point_y) / strip_length )

    local yaw = player.mo.angle
    local pitch = player.aiming

    local x = FixedMul(cos(yaw), cos(pitch))
    local y = FixedMul(sin(yaw), cos(pitch))
    local z = sin(pitch)

    local muzzle_x = sin(yaw) * 36
    local muzzle_y = -cos(yaw) * 36

    local function SpawnGluonSpiral(strip, j)
        --print(tostring(distance))

        local length = 33 * 4 * FU
        local num_points = 32  -- Number of points in the spiral (one full loop)

    
        for i = 1, num_points do
            ---@type angle_t
            local angle = yaw + (leveltime * ANG1) + ANGLE_11hh * (i - 1) 
            local step = length / num_points * i
    
            local distance = 16 * FU

            if j == 1 then
                distance = 16 * FU * i / num_points
            end

            if j == strips then
                distance = 16 * FU * (num_points - i) / num_points
            end


            -- fucky wucky math stuff i dont like
 
            local particle = P_SpawnMobjFromMobj(
                strip,
                FixedMul( FixedMul(-cos(angle), sin(yaw)) - FixedMul(FixedMul(sin(angle), cos(yaw)), sin(pitch)), distance) + FixedMul(x, step) - muzzle_x / 2,
                FixedMul( FixedMul( cos(angle), cos(yaw)) - FixedMul(FixedMul(sin(angle), sin(yaw)), sin(pitch)), distance) + FixedMul(y, step) - muzzle_y / 2,
                FixedMul( FixedMul( sin(angle), cos(pitch)), distance ) + FixedMul(z, step),
                MT_GLUONPARTICLE
            )
            particle.fuse = 2
        end
    end
    
    for i = 1, strips do
        local strip = P_SpawnMobjFromMobj(
            player.mo,
            muzzle_x + strip_length * i * x,
            muzzle_y + strip_length * i * y,
            player.mo.height / 2 + strip_length * i * z,
            MT_GLUONLASER
        )

        strip.fuse = 2
        strip.angle = yaw
        strip.flags2 = $ | MF2_SPLAT
        strip.renderflags = $ | RF_SLOPESPLAT

        P_CreateFloorSpriteSlope(strip)

        strip.floorspriteslope.xydirection = yaw
        strip.floorspriteslope.zangle = pitch
        strip.floorspriteslope.o = { x = strip.x, y = strip.y, z = strip.z }

        if (i - 1) % 4 == 0 then
            SpawnGluonSpiral(strip, i)
        end
    end
end

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    if player.cmd.buttons & BT_ATTACK and not (player.lastbuttons & BT_ATTACK) then
        weapon.TicsUsed = $ or 1
    
        S_StartSound(player.mo, sfx_egonup)
    end

    if weapon.TicsUsed % 3 == 0 then
        player.HL.Inventory.Ammo[HL.AmmunitionType.Uranium] = $ - 1
    end

    if weapon.TicsUsed % 13 == 0 then
        S_StartSound(player.mo, sfx_egongo)
        HL.SetAnimation(player, HL.AnimationType.Primary)
    end

    HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)

    weapon.TicsUsed = $ + 1

    return true
end, HL.Weapons.GluonGun.Name)

addHook("HL_OnHitscanHit", function(player, projectile, target)
    SpawnGluonRay(player, projectile.x, projectile.y)
end, HL.Weapons.GluonGun.Name)


addHook("HL_OnWeaponLineHit", function(player, projectile, line)
    local x, y = P_ClosestPointOnLine(projectile.x, projectile.y, line)

    SpawnGluonRay(player, x, y)
end, HL.Weapons.GluonGun.Name)

addHook("HL_OnPrimaryStop", function(player, weapon)
    if weapon.TicsUsed then
        S_StopSoundByID(player.mo, sfx_egonup)
        S_StopSoundByID(player.mo, sfx_egongo)
        S_StartSound(player.mo, sfx_egondn)

        weapon.TicsUsed = 0
    end
    
end, HL.Weapons.GluonGun.Name)