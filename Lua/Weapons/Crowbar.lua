freeslot("MT_HLMELEESENTINEL")

---@class hlweapon_t
HL.Weapons.Crowbar = {
    Name = "Crowbar",
    Class = HL.WeaponClass.Melee,
    PrimaryFire = {
        AmmoType = HL.AmmunitionType.None,

        Fire = {
            Cooldown = 6,
            Automatic = true,
            Damage = FU * 5,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 0
        }
    }
}
