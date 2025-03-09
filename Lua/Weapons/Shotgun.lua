---@class hlweapon_t
HL.Shotgun = {
    Name = "Shotgun",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {
        ClipSize = 8,
        CurrentClipSize = 0,
        AmmoType = HL.AmmunitionType.Shell,
        Fire = {
            Cooldown = 25,
            Automatic = false,
            Damage = 5 * FU,
            DamageVariance = FU,
            Spread = 2 * FU,
            RequiredAmmo = 1,
            FireSound = {
                sfx_shgsh1
            }
        }
    },
    SecondaryFire = {
        AmmoType = HL.UsesPrimaryClip,
        Fire = {
            Cooldown = 50,
            Automatic = false,
            Damage = 5 * FU,
            DamageVariance = FU,
            Spread = 2 * FU,
            RequiredAmmo = 2
        }
    }
}

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    for _ = 1, 6 do
        -- A shotgun should fire multiple 'shot' rather than a single bullet,
        -- so we call the hitscan fire function six times.

        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.SetAnimation(player, HL.AnimationType.Secondary)
    
    return true
end, HL.Shotgun.Name)

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnSecondaryUse", function(player, weapon)
    for _ = 1, 12 do
        HL.FireHitscanWeapon(player, weapon, weapon.PrimaryFire)
    end

    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)
    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)

    HL.SetAnimation(player, HL.AnimationType.Secondary)
    return true
end, HL.Shotgun.Name)