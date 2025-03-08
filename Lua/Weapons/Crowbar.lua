---@class hlweapon_t
HL.Crowbar = {
    Name = "Crowbar",
    Class = HL.WeaponClass.Handgun,
    PrimaryFire = {
        ClipSize = HL.DoesNotReload,
        AmmoType = HL.AmmunitionType.None,
        Fire = {
            Cooldown = TICRATE / 8,
            Automatic = true,
            Damage = FU * 5,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 0
        }
    }
}
