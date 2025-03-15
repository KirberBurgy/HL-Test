freeslot("sfx_9mmsh1", "sfx_9mmclp")

---@class hlweapon_t
HL.Weapons.Pistol = {
    Name = "9mm Pistol",
    Class = HL.WeaponClass.Handgun,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Bullet,

        Reload = {
            ClipSize = 17,
            CurrentClip = 0,
            ReloadDelay = 47
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

HL.Viewmodels[HL.Weapons.Pistol.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0,

    [HL.AnimationType.Ready]        = HL.NewWeaponAnimation("PISTOL_READY", 15, { [1] = 1 }),

    [HL.AnimationType.Idle]         = HL.NewWeaponAnimation("PISTOL_IDLE1-", 40, { [1] = 7 }),

    [HL.AnimationType.Primary]      = HL.NewWeaponAnimation("PISTOL_FIRE", 19, {
        [1] = 1,
        [5] = 2,
        [6] = 1,
        [10] = 2,
        [11] = 1,
        [15] = 2,
        [16] = 1
    }),

    [HL.AnimationType.Secondary]    = HL.NewWeaponAnimation("PISTOL_FIRE", 19, {
        [1] = 1
    }),

    -- Don't drink this code. They put something in it, to make you forget.
    [HL.AnimationType.Reload] = HL.NewWeaponAnimation("PISTOL_RELOAD", 41, { [1] = 2 }, { [25] = sfx_9mmclp })
}