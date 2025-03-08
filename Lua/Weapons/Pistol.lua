---@class hlweapon_t
HL.Pistol = {
    Name = "9mm Pistol",
    Class = HL.WeaponClass.Handgun,
    PrimaryFire = {
        ClipSize = 17,
        CurrentClipSize = 0,
        AmmoType = HL.AmmunitionType.Bullet,
        Fire = {
            Cooldown = 9,
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
            Cooldown = 7,
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
    [HL.AnimationType.Ready]        = {},
    [HL.AnimationType.Idle]         = {},
    [HL.AnimationType.Primary]      = {},
    [HL.AnimationType.Secondary]    = {}
}

HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Ready], "PISTOL_READY", 1,  7,  3)

HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Idle], "PISTOL_IDLE1", 1, 20, 8)
HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Idle], "PISTOL_IDLE2", 1, 11,  8)
HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Idle], "PISTOL_IDLE3", 1, 16,  8)

HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Primary], "PISTOL_FIRE", 1, 9, 2)

HL.UnpackFrameSet(HL.Viewmodels[HL.Pistol.Name][HL.AnimationType.Secondary], "PISTOL_SFIRE", 1, 10, 2)