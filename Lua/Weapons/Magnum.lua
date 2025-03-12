freeslot("sfx_357sh1")
freeslot("sfx_357sh2")

---@class hlweapon_t
HL.Weapons.Magnum = {
    Name = ".357 Magnum",
    Class = HL.WeaponClass.Handgun,

    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Cartridge,

        Reload = {
            ClipSize = 6,
            CurrentClip = 0,
            ReloadDelay = 98
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

HL.Viewmodels[HL.Weapons.Magnum.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0 * FU,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("MAGNUM_READY", 15, { [1] = 1 }),

    [HL.AnimationType.Idle] = {
        HL.NewWeaponAnimation("MAGNUM_IDLE1-", 70, { [1] = 1 }),
        HL.NewWeaponAnimation("MAGNUM_IDLE2-", 170, { [1] = 1 }),
        HL.NewWeaponAnimation("MAGNUM_IDLE3-", 70, { [1] = 1 }),
        HL.NewWeaponAnimation("MAGNUM_IDLE4-", 88, { [1] = 1 })
    },

    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("MAGNUM_FIRE", 30, { [1] = 1 }),
    [HL.AnimationType.Reload] = HL.NewWeaponAnimation("MAGNUM_RELOAD", 110, { [1] = 1 })
}