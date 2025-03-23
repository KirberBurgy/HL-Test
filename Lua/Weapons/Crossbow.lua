freeslot(
    "sfx_xbwsh1",
    "sfx_xbwhe1",
    "sfx_xbwhe2",
    "sfx_xbwhw1",
    "sfx_xbwhw2",
    "sfx_xbowrl"
)

---@class hlweapon_t
HL.Weapons.Crossbow = {
    Name = "Crossbow",
    Class = HL.WeaponClass.Primary,

    PrimaryFire = {
        AmmoType = HL.AmmunitionType.Bolt,

        Reload = {
            ClipSize = 5,
            CurrentClip = 0,
            ReloadDelay = 136
        },
        
        Fire = {
            Cooldown = 90,
            Automatic = true,
            Damage = 50 * FU,
            DamageVariance = 0,
            Spread = 0,
            RequiredAmmo = 1,
            FireSound = sfx_xbwsh1,

            HitEnemySound = {
                sfx_xbwhe1,
                sfx_xbwhe2
            },

            HitWallSound = {
                sfx_xbwhw1,
                sfx_xbwhw2
            }
        }
    }
}

HL.AnimationType.Crossbow = {
    FireEmpty = HL.CreateAnimationType(),
    FireNoDraw = HL.CreateAnimationType(),
    Empty = HL.CreateAnimationType()
}

HL.AnimationMap[HL.AnimationType.Crossbow.FireEmpty] = function() return HL.AnimationType.Idle end
HL.AnimationMap[HL.AnimationType.Crossbow.FireNoDraw] = function() return HL.AnimationType.Crossbow.Empty end
HL.AnimationMap[HL.AnimationType.Crossbow.Empty] = function() return HL.AnimationType.Crossbow.Empty end

HL.Viewmodels[HL.Weapons.Crossbow.Name] = {
    Flags = V_FLIP,
    OffsetX = 352 * FU,
    OffsetY = 0 * FU,

    [HL.AnimationType.Ready] = HL.NewWeaponAnimation("XBOW_READY", 15, { [1] = 1 }),

    [HL.AnimationType.Idle] = {
        HL.NewWeaponAnimation("XBOW_IDLE1-", 90, { [1] = 1 }),
        HL.NewWeaponAnimation("XBOW_IDLE2-", 80, { [1] = 1 })
    },

    [HL.AnimationType.Crossbow.FireEmpty] = HL.NewWeaponAnimation("XBOW_FIREEMPTY", 165, { [1] = 1 }),
    [HL.AnimationType.Crossbow.FireNoDraw] = HL.NewWeaponAnimation("XBOW_FIRENODRAW", 15, { [1] = 1 }),
    [HL.AnimationType.Crossbow.Empty] = HL.NewWeaponAnimation("XBOW_EMPTY", 1, { [1] = 1 }),

    [HL.AnimationType.Primary] = HL.NewWeaponAnimation("XBOW_FIRE", 90, { [1] = 1 }),
    [HL.AnimationType.Reload] = HL.NewWeaponAnimation("XBOW_RELOAD", 110, { [1] = 1 })
}

---@param player player_t
---@param weapon hlweapon_t
addHook("HL_OnPrimaryUse", function(player, weapon)
    HL.FireWeapon(player, weapon, weapon.PrimaryFire)
    HL.PlayFireSound(player.mo, weapon.PrimaryFire.Fire)

    weapon.PrimaryFire.Reload.CurrentClip = $ - 1

    if weapon.PrimaryFire.Reload.CurrentClip == 0 then
        if player.HL.Inventory.Ammo[HL.AmmunitionType.Bolt] == 0 then
            HL.SetAnimation(player, HL.AnimationType.Crossbow.FireNoDraw, false, true)
            player.HL.Cooldown = 15
        else
            HL.SetAnimation(player, HL.AnimationType.Crossbow.FireEmpty, false, true)
            player.HL.Cooldown = 165
            player.HL.Reloading = true
        end
    else
        HL.SetAnimation(player, HL.AnimationType.Primary, false, true)
        player.HL.Cooldown = 90
    end

    return true
end, HL.Weapons.Crossbow.Name)