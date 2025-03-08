---@class hlweapon_t
HL.Magnum = {
    Name = ".357 Magnum",
    Class = HL.WeaponClass.Handgun,

    PrimaryFire = {
        ClipSize = 6,
        CurrentClipSize = 0,
        AmmoType = HL.AmmunitionType.Cartridge,
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