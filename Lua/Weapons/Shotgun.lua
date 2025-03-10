freeslot("sfx_shgsh1")

---@class hlweapon_t
HL.Shotgun = {
    Name = "Shotgun",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {

        AmmoType = HL.AmmunitionType.Shell,

        Reload = {
            ClipSize = 8,
            CurrentClip = 0,
            ReloadDelay = 15,
            OneByOne = true
        },

        Fire = {
            Cooldown = 25,
            Automatic = false,
            Damage = 5 * FU,
            DamageVariance = FU,
            Spread = 2 * FU,
            RequiredAmmo = 1,
            FireSound = {
                sfx_shgsh1
            }
        }
    },
    SecondaryFire = {
        AmmoType = HL.UsesPrimaryClip,
        Fire = {
            Cooldown = 45,
            Automatic = false,
            Damage = 5 * FU,
            DamageVariance = FU,
            Spread = 2 * FU,
            RequiredAmmo = 2
        }
    }
}

HL.Viewmodels[HL.Shotgun.Name] = {
    Flags = V_FLIP,
    OffsetX = 160 * FU,
    OffsetY = 106 * FU,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("SHOTGUNREADY", 5, { [1] = 8 }),
    [HL.AnimationType.Idle] = HL.NewWeaponAnimation("SHOTGUNIDLE1-", 10, { [1] = 8 }),
    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("SHOTGUNFIRE", 16, { [1] = 2, [5] = 4 }),
    [HL.AnimationType.Secondary] = HL.NewWeaponAnimation("SHOTGUNAFIRE", 19, {
        [1] = 5,
        [7] = 3,
        [17] = 3,
        [20] = 6,
    }),

    [HL.AnimationType.ReloadStart] = HL.NewWeaponAnimation("SHOTGUNRELOADS", 7, {
        [1] = 5
    }),
    
    [HL.AnimationType.ReloadLoop] = HL.NewWeaponAnimation("SHOTGUNRELOADL", 6, {
        [1] = 5
    }),
    
    [HL.AnimationType.ReloadEnd] = HL.NewWeaponAnimation("SHOTGUNRELOADE", 8, {
        [1] = 5
    }),
}

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    for _ = 1, 6 do
        -- A shotgun should fire multiple 'shot' rather than a single bullet,
        -- so we call the hitscan fire function six times.

        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Primary)

    return true
end, HL.Shotgun.Name)

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnSecondaryUse", function(player, weapon)
    for _ = 1, 12 do
        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)

    HL.SetAnimation(player, HL.AnimationType.Secondary)
    return true
end, HL.Shotgun.Name)