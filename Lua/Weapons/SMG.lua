HL.AmmunitionType.Unique.MP5Grenade = 11

---@class hlweapon_t
HL.SMG = {
    Name = "Submachine Gun",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {
        ClipSize = 50,
        CurrentClipSize = 0,
        AmmoType = HL.AmmunitionType.Bullet,
        Fire = {
            Cooldown = 4,
            Automatic = true,
            Damage = 40 * FU,
            DamageVariance = FU * 5,
            Spread = FU * 2,
            RequiredAmmo = 1,
            FireSound = {
                sfx_smgsh1,
                sfx_smgsh2,
                sfx_smgsh3
            }
        }
    },
    SecondaryFire = {
        ClipSize = HL.DoesNotReload,
        AmmoType = HL.AmmunitionType.Unique.MP5Grenade,
        Fire = {
            Cooldown = TICRATE,
            Automatic = false,
            Damage = 80 * FU,
            DamageVariance = FU * 20,
            Spread = 0,
            RequiredAmmo = 1
        }
    }
}