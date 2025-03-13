freeslot("MT_GLUONLASER")

freeslot("S_GLUON_LASER")

freeslot("SPR_GLST")

freeslot("sfx_egonup", "sfx_egongo", "sfx_egondn")

states[S_GLUON_LASER] = {
    sprite = SPR_GLST,
    frame = FF_ADD | FF_PAPERSPRITE | FF_TRANS30,
    tics = -1
}

mobjinfo[MT_GLUONLASER] = {
    spawnhealth = 1,
    spawnstate = S_GLUON_LASER,
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
            Damage = FU * 14,
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

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("EGON_READY", 16, { [1] = 1 }),
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
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    weapon.TicsUsed = $ or 0

    if player.cmd.buttons & BT_ATTACK and not (player.lastbuttons & BT_ATTACK) then
        S_StartSound(player.mo, sfx_egonup)
    end

    if weapon.TicsUsed % 3 == 0 then
        player.HL.Inventory.Ammo[HL.AmmunitionType.Uranium] = $ - 1
    end

    if weapon.TicsUsed % 13 == 0 then
        S_StartSound(player.mo, sfx_egongo)
        HL.SetAnimation(player, HL.AnimationType.Primary)
    end

    weapon.TicsUsed = $ + 1

    return true
end, HL.Weapons.GluonGun.Name)