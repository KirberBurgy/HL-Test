freeslot("sfx_smgsh1", "sfx_smgsh2", "sfx_smgsh3")
freeslot("sfx_smggr1", "sfx_smggr2")

HL.AmmunitionType.Unique.MP5Grenade = 11

---@class hlweapon_t
HL.Weapons.SMG = {
    Name = "Submachine Gun",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Bullet,

        Reload = {
            ClipSize = 50,
            CurrentClip = 0,
            ReloadDelay = 70
        },

        Fire = {
            Cooldown = 4,
            Automatic = true,
            Damage = 5 * FU,
            DamageVariance = FU / 2,
            Spread = FU,
            RequiredAmmo = 1,
            FireSound = {
                sfx_smgsh1,
                sfx_smgsh2,
                sfx_smgsh3
            }
        }
    },
    SecondaryFire = {
        AmmoType = HL.AmmunitionType.Unique.MP5Grenade,

        Fire = {
            Cooldown = TICRATE,
            Automatic = false,
            Damage = 100 * FU,
            DamageVariance = FU * 20,
            Spread = 0,
            RequiredAmmo = 1,
            FireSound = {
                sfx_smggr1,
                sfx_smggr2
            }
        }
    }
}

HL.Viewmodels[HL.Weapons.SMG.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("SMG_READY", 11, { [1] = 1 }),
    [HL.AnimationType.Idle] = HL.NewWeaponAnimation("SMG_IDLE", 40, { [1] = 3 }),
    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("SMG_FIRE", 6, { [1] = 1 }),
    [HL.AnimationType.Secondary] = HL.NewWeaponAnimation("SMG_SFIRE", 33, { [1] = 1 }),
    [HL.AnimationType.Reload] = HL.NewWeaponAnimation("SMG_RELOAD", 46, { [1] = 1 })
}