---@class hlweapon_t
HL.Pistol = {
    Name = "9mm Pistol",
    Class = HL.WeaponClass.Handgun,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Bullet,

        Reload = {
            ClipSize = 17,
            CurrentClip = 0,
            ReloadDelay = 66
        },

        Fire = {
            Cooldown = 10,
            Automatic = true,
            Damage = FU * 8,
            DamageVariance = FU * 2,
            Spread = FU / 10,
            RequiredAmmo = 1,
            FireSound = {
                sfx_9mmsh1
            }
        }
    },
    SecondaryFire = {
        AmmoType = HL.UsesPrimaryClip,
        Fire = {
            Cooldown = 8,
            Automatic = true,
            Damage = FU * 8,
            DamageVariance = FU * 3,
            Spread = FU / 3,
            RequiredAmmo = 1,
            FireSound = {
                sfx_9mmsh1
            }
        }
    }
}

HL.Viewmodels[HL.Pistol.Name] = {
    [HL.AnimationType.Ready]        = HL.NewWeaponAnimation("PISTOL_READY", 7, { [1] = 3 }),
    [HL.AnimationType.Idle]         = HL.NewWeaponAnimation("PISTOL_IDLE", 47, {
        [1] = 8,
        [23] = 12,
        [32] = 8,
        [33] = 10
    }),

    [HL.AnimationType.Primary]      = HL.NewWeaponAnimation("PISTOL_FIRE", 9, {
        [1] = 2
    }),

    [HL.AnimationType.Secondary]    = HL.NewWeaponAnimation("PISTOL_SFIRE", 10, {
        [1] = 1,
        [2] = 2
    }),

    [HL.AnimationType.Reload]       = HL.NewWeaponAnimation("PISTOL_RELOAD", 12, {
        [1] = 6
    })
}