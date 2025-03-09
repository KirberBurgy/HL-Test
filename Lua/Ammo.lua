COM_AddCommand("addammo", function(player, arg1, arg2)
    if not player or not player.mo or not player.HL then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    if not arg1 then
        CONS_Printf(player, "Types of ammo:")
        CONS_Printf(player, "\t9mm, SMG:                1")
        CONS_Printf(player, "\t.357:                    2")
        CONS_Printf(player, "\tShotgun:                 3")
        CONS_Printf(player, "\tCrossbow:                4")
        CONS_Printf(player, "\tRPG:                     5")
        CONS_Printf(player, "\tTau Cannon, Gluon Gun:   6")
        CONS_Printf(player, "\tFrag Grenade:            7")
        CONS_Printf(player, "\tSatchel Charge:          8")
        CONS_Printf(player, "\tTrip Mine:               9")
        CONS_Printf(player, "\tSnark:                   10")
        CONS_Printf(player, "\tSMG Grenade:             11")

        return
    end

    local ammo_type = tonumber(arg1)
    local ammo_count = tonumber(arg2)

    if not ammo_type or ammo_type < 1 or ammo_type > 11 or not ammo_type then
        return
    end

    hl.Inventory.Ammo[ammo_type] = max( min(HL.AmmoInfo[ammo_type].Maximum, ammo_count), 0 )
end)

HL.AmmunitionType = {
    --- Crowbar, Hive Hand
    None        = 0,

    -- 9mm - Pistol, MP5 (M4)
    Bullet      = 1,

    -- .357 Magnum
    Cartridge   = 2,

    -- Shotgun
    Shell       = 3,

    -- Crossbow
    Bolt        = 4,

    -- RPG
    Rocket      = 5,

    -- Tau Cannon, Gluon Gun
    Uranium     = 6,
    
    -- Throwable - Frag. Grenade, Satchel Charge, Trip Mine, Snark
    Unique      = {
        FragGrenade     = 7,
        SatchelCharge   = 8,
        TripMine        = 9,
        Snark           = 10,
        MP5Grenade      = 11
    }
}

---@class hlproj_t
---@field Speed fixed_t The speed of the projectile.
---@field Object integer The object number of the projectile. The associated object should have the MF_MISSILE flag.
---@field Gravity boolean Whether the projectile is affected by gravity.
---@field Homing boolean Whether the projectile has tracking capabilities.

---@class hlfire_t
---@field Cooldown tic_t The delay between shots, in tics.
---@field Automatic boolean Whether or not this mode of fire can be sustained by holding the trigger.
---@field Damage fixed_t The damage done by one shot.
---@field DamageVariance fixed_t The variance of damage of this mode of fire, where Actual Damage = Damage +- Random(0, DamageVariance) / 2.
---@field Spread fixed_t The spread of the weapon in both dimensions.
---@field RequiredAmmo integer The amount of ammunition required to use this mode of fire.
---@field FireSound table? The sound (or a random sound from this list) played when this weapon is fired.
---@field HitWallSound table? The sound (or a random sound from this list) played when this weapon hits a wall.
---@field HitEnemySound table? The sound (or a random sound from this list) played when this weapon hits an enemy.
---@field Projectile hlproj_t? The projectile fired by the weapon. If nil, then the weapon is a hitscan weapon.

---@param player_mo mobj_t
local function HL_PlayRandomSound(player_mo, sound_table)
    if not sound_table then
        return
    end

    if #sound_table == 1 then
        S_StartSound(player_mo, sound_table[1])

        return
    end

    S_StartSound(player_mo, sound_table[ P_RandomRange(1, #sound_table) ] )
end

---@param player_mo mobj_t
---@param fire hlfire_t
function HL.PlayFireSound(player_mo, fire)
    HL_PlayRandomSound(player_mo, fire.FireSound)
end

---@param player_mo mobj_t
---@param fire hlfire_t
function HL.PlayHitWallSound(player_mo, fire)
    HL_PlayRandomSound(player_mo, fire.HitWallSound)
end

---@param player_mo mobj_t
---@param fire hlfire_t
function HL.PlayHitEnemySound(player_mo, fire)
    HL_PlayRandomSound(player_mo, fire.HitEnemySound)
end