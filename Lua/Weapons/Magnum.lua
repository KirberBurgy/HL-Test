freeslot("sfx_357sh1")
freeslot("sfx_357sh2")

---@class hlweapon_t
HL.Magnum = {
    Name = ".357 Magnum",
    Class = HL.WeaponClass.Handgun,

    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Cartridge,

        Reload = {
            ClipSize = 6,
            CurrentClip = 0,
            ReloadDelay = 85
        },
        
        Fire = {
            Cooldown = 27,
            Automatic = true,
            Damage = 40 * FU,
            DamageVariance = FU * 5,
            Spread = 0,
            RequiredAmmo = 1,
            FireSound = {
                sfx_357sh1,
                sfx_357sh2
            }
        }
    }
}

HL.Viewmodels[HL.Magnum.Name] = {
    Flags = V_FLIP,
    OffsetX = 160 * FU,
    OffsetY = 106 * FU,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("357READY", 7, { [1] = 3 }),

    [HL.AnimationType.Idle] = HL.NewWeaponAnimation("357IDLE1-", 20, {
        [1] = 6,
        [2] = 5,
        [19] = 5,
    }),

    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("357FIRE", 8, { 
        [1] = 2,
        [2] = 3
    }),

    [HL.AnimationType.Reload] = HL.NewWeaponAnimation("357RELOAD", 28, {
        [1] = 6,
        [2] = 4,
        [5] = 3,
        [26] = 8
    })
}