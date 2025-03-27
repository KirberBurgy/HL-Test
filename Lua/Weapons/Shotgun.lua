freeslot("sfx_shgsh1", "sfx_shgsh2", "sfx_shgcck", "sfx_shgrld")

---@class hlweapon_t
HL.Weapons.Shotgun = {
    Name = "Shotgun",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {

        AmmoType = HL.AmmunitionType.Shell,

        Reload = {
            ClipSize = 8,
            CurrentClip = 0,
            ReloadDelay = 18,
            OneByOne = true
        },

        Fire = {
            Cooldown = 25,
            Automatic = false,
            Damage = 5 * FU,
            DamageVariance = FU,
            Spread = FU / 2,
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
            Spread = FU / 2,
            RequiredAmmo = 2,
            FireSound = {
                sfx_shgsh2
            }
        }
    }
}

HL.Viewmodels[HL.Weapons.Shotgun.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("SHOTGUN_READY", 12, { [1] = 3 }),
    [HL.AnimationType.Idle] = HL.NewWeaponAnimation("SHOTGUN_IDLE1-", 20, { [1] = 3 }),
    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("SHOTGUN_FIRE", 31, { [1] = 1 }, { [16] = sfx_shgcck }),
    [HL.AnimationType.Secondary] = HL.NewWeaponAnimation("SHOTGUN_SFIRE", 47, { [1] = 1 }, { [31] = sfx_shgcck }),
    [HL.AnimationType.ReloadStart] = HL.NewWeaponAnimation("SHOTGUN_RELOADSTART", 8, { [1] = 3 }),
    [HL.AnimationType.ReloadLoop] = HL.NewWeaponAnimation("SHOTGUN_RELOADLOOP", 9, { [1] = 3 }, { [4] = sfx_shgrld }),
    [HL.AnimationType.ReloadEnd] = HL.NewWeaponAnimation("SHOTGUN_RELOADEND", 19, { [1] = 3 }, { [5] = sfx_shgcck }),
}

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    for _ = 1, 6 do
        -- A shotgun should fire multiple 'shot' rather than a single bullet,
        -- so we call the hitscan fire function six times.

        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    weapon.PrimaryFire.Reload.CurrentClip = $ - 1

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Primary)

    return true
end, HL.Weapons.Shotgun.Name)

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnSecondaryUse", function(player, weapon)
    for _ = 1, 12 do
        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    weapon.PrimaryFire.Reload.CurrentClip = $ - 2

    HL.PlayFireSound(player.mo, weapon.SecondaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Secondary)

    return true
end, HL.Weapons.Shotgun.Name)