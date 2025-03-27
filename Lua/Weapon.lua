freeslot("MT_HLBULLET")

mobjinfo[MT_HLBULLET] = {
    spawnstate = S_INVISIBLE,
    spawnhealth = 1,
    flags = MF_MISSILE | MF_NOGRAVITY,
    height = FU / 3,
    radius = FU / 3
}

HL.RegisterProjectile(MT_HLBULLET)

HL.WeaponClass = {
    -- Crowbar
    Melee           = 1,

    -- 9mm Pistol
    -- .357 Magnum
    Handgun         = 2,

    -- SMG (MP5, M4)
    -- SPAS-12
    -- Crossbow
    Primary         = 3,

    -- RPG
    -- Tau Cannon
    -- Gluon Gun
    -- Hive Hand
    Experimental    = 4,

    -- Frag. Grenade
    -- Satchel Charge
    -- Trip Mine (C4)
    -- Snark
    Throwing        = 5,

    -- ...
    Other           = 6
}

-- Use this on the ClipSize field to signify that reloading
-- is unnecessary and that ammo is drawn from the inventory.
HL.DoesNotReload = 0

-- Use this on the AmmoType field of the secondary fire
-- to signify that it takes ammunition from the primary fire's clip.
HL.UsesPrimaryClip = -1


---@class hlreload_t
---@field ClipSize integer The maximum size of the clip.
---@field CurrentClip integer The number of bullets remaining in the clip.
---@field ReloadDelay tic_t The time, in tics, required to reload this weapon.
---@field OneByOne boolean Whether or not the weapon reloads one bullet at a time.

---@class hlweaponfire_t
---@field Fire hlfire_t The data of the mode of fire.
---@field Reload hlreload_t? The reload data of this mode of fire.
---@field AmmoType integer The ammunition type used by this mode of fire. If this is equal to HL.UsesPrimaryClip, it will use the same ammunition type as the primary fire.

---@class hlweapon_t
---@field Name string The name of the weapon, so that it can be filtered in hooks. This is also the name of the corresponding viewmodel.
---@field Class integer Where the weapon appears in the UI.
---@field HUDPriority integer? The priority of the weapon in the HUD (higher priorities will be displayed first).
---@field PrimaryFire hlweaponfire_t The primary mode of fire.
---@field SecondaryFire hlweaponfire_t? The secondary mode of fire.

--- Fires a hitscan weapon.
---@param player player_t
---@param weapon hlweapon_t
---@param fire_mode hlweaponfire_t
function HL.FireHitscanWeapon(player, weapon, fire_mode)
    local bullet = P_SpawnMobjFromMobj(player.mo, 0, 0, player.mo.height / 2, MT_HLBULLET)

    bullet.target = player.mo
    bullet.HL = {
        IsHitscan = true,
        Player = player,
        SourceWeapon = weapon,
        SourceFire = fire_mode,
        Damage = fire_mode.Fire.Damage + FixedMul( ( P_RandomFixed() - FU / 2 ), fire_mode.Fire.DamageVariance )
    }

    local yaw = player.mo.angle
    local pitch = player.aiming

    bullet.momx = FixedMul(FixedMul(cos( yaw ), cos(pitch)), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))
    bullet.momy = FixedMul(FixedMul(sin( yaw ), cos(pitch)), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))
    bullet.momz = FixedMul(sin(pitch), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))

    return bullet
end

--- Fires a projectile weapon.
---@param player player_t
---@param weapon hlweapon_t
---@param fire_mode hlweaponfire_t
function HL.FireProjectileWeapon(player, weapon, fire_mode)

    local bullet = P_SpawnMobjFromMobj(player.mo, 0, 0, player.mo.height / 2, fire_mode.Fire.Projectile.Object)

    bullet.target = player.mo

    bullet.flags = $ | (not fire_mode.Fire.Projectile.Gravity and MF_NOGRAVITY or 0)
    bullet.angle = player.mo.angle
    bullet.rollangle = player.aiming
    bullet.fuse = (fire_mode.Fire.Projectile.Fuse or INT32_MAX)

    bullet.HL = {
        IsHitscan = false,
        Player = player,
        SourceWeapon = weapon,
        SourceFire = fire_mode,
        Damage = fire_mode.Fire.Damage + FixedMul( ( P_RandomFixed() - FU / 2 ), fire_mode.Fire.DamageVariance )
    }

    local yaw = player.mo.angle
    local pitch = player.aiming

    bullet.momx = FixedMul(FixedMul( FixedMul(cos( yaw ), cos(pitch)), fire_mode.Fire.Projectile.Speed ), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))
    bullet.momy = FixedMul(FixedMul( FixedMul(sin( yaw ), cos(pitch)), fire_mode.Fire.Projectile.Speed ), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))
    bullet.momz = FixedMul(FixedMul( sin(pitch), fire_mode.Fire.Projectile.Speed ), FU - FixedMul( P_RandomFixed() - FU / 2, fire_mode.Fire.Spread ))

    return bullet
end

--- Fires a weapon.
---@param player player_t
---@param weapon hlweapon_t
---@param fire_mode hlweaponfire_t
function HL.FireWeapon(player, weapon, fire_mode)
    if fire_mode.Fire.Projectile then
        return HL.FireProjectileWeapon(player, weapon, fire_mode)
    end

    return HL.FireHitscanWeapon(player, weapon, fire_mode)
end

local RecursiveClone

--- Performs a deep copy of the input table. Does not account for table keys.
---@param t table
RecursiveClone = function(t)
    local out = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            out[k] = RecursiveClone(v)
        else
            out[k] = v
        end
    end

    return out
end

rawset(_G, "RecursiveClone", RecursiveClone)