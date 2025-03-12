local _addHook = addHook

rawset(_G, "HL", {})

---@class hookargs_t
---@field Callback function
---@field Extra integer

---@class hlhooks_t
---@field FreemanThinker    hookargs_t[]
---@field OnReload          hookargs_t[]
---@field ProjectileThinker hookargs_t[]
---@field OnFire            hookargs_t[]
---@field OnPrimaryUse      hookargs_t[]
---@field OnSecondaryUse    hookargs_t[]
---@field OnWeaponLineHit   hookargs_t[]
---@field OnWeaponHit       hookargs_t[]
---@field OnHitscanHit      hookargs_t[]
---@field OnProjectileHit   hookargs_t[]
HL.Hooks = {
    -- Called every frame on every
    -- player that is a Gordon Freeman.
    -- Hook signature:
    -- `addHook("HL_FreemanThinker", function(player_t freeman))
    FreemanThinker      = {},

    -- Called on the frame that a weapon 
    -- is first equipped.
    -- Hook signature:
    -- `addHook("HL_OnEquip", function(player_t player, weapon_t weapon), [string weapon_name])
    OnEquip             = {},

    -- Called on the first frame a
    -- weapon is reloaded.
    OnReload            = {},

    -- Called every frame a projectile
    -- is alive.
    -- Hook signature:
    -- `addHook("HL_ProjectileThinker", function(player_t source, mobj_t projectile), [MT_* for_type])`
    ProjectileThinker   = {},

    -- Called whenever a weapon is fired,
    -- either primary or secondary.
    -- Hook signature:
    -- `addHook("HL_OnFire", function(player_t player, weapon_t weapon), [string weapon_name]) 
    -- If the function returns true, the weapon's projectile is not fired.
    OnFire              = {},

    -- Called whenever a weapon is fired 
    -- with the primary mode.
    -- Hook signature:
    -- `addHook("HL_OnPrimaryUse", function(player_t player, weapon_t weapon), [string weapon_name])`
    -- If the function returns true, the weapon's primary projectile is not fired.
    OnPrimaryUse        = {},

    -- Called whenever a weapon is fired 
    -- with the secondary mode. This will never run
    -- if the weapon does not have a secondary fire.
    -- Hook signature:
    -- `addHook("HL_OnSecondaryUse", function(player_t player, weapon_t weapon), [string weapon_name])` 
    -- If the function returns true, the weapon's secondary projectile is not fired.
    OnSecondaryUse      = {},
    
    -- Called whenever a weapon hits a line.
    -- Hook signature:
    -- `addHook("HL_OnWeaponLineHit", function(player_t player, mobj_t weapon_projectile, line_t hit_line), [string weapon_name])` 
    OnWeaponLineHit     = {},

    -- Called whenever a weapon hits 
    -- an object.
    -- Hook signature:
    -- `addHook("HL_OnWeaponHit", function(player_t player, mobj_t weapon_projectile, mobj_t target), [string weapon_name])` 
    OnWeaponHit         = {},

    -- Called whenever a hitscan weapon
    -- hits an object.
    -- Hook signature:
    -- `addHook("HL_OnHitscanHit", function(player_t player, mobj_t weapon_projectile, mobj_t target), [string weapon_name])` 
    OnHitscanHit        = {},
    
    -- Called whenever a projectile weapon
    -- hits an object.
    -- Hook signature:
    -- `addHook("HL_OnProjectileHit", function(player_t player, mobj_t weapon_projectile, mobj_t target), [string weapon_name])` 
    OnProjectileHit     = {},

    -- Called whenever a pickup is touched.
    -- Hook signature:
    -- `addHook("HL_OnPickupGained", function(player_t player), [MT_* object_type])
    OnPickupGained      = {}
}

HL.Weapons = {}

---@alias hlhooktype hooktype 
---| "AddonLoaded"
---| "HL_FreemanThinker"
---| "HL_OnEquip"
---| "HL_OnReload"
---| "HL_ProjectileThinker"
---| "HL_OnFire"
---| "HL_OnPrimaryUse"
---| "HL_OnSecondaryUse"
---| "HL_OnWeaponLineHit"
---| "HL_OnWeaponHit"
---| "HL_OnHitscanHit"
---| "HL_OnProjectileHit"
---| "HL_OnPickupGained"

---@param hook hlhooktype
---@param func function
---@param ext? any
rawset(_G, "addHook", function(hook, func, ext)
    if hook:sub(1, 3) == "HL_" then
        table.insert(HL.Hooks[ hook:sub(4, #hook) ], {
            Callback = func,
            Extra = ext or nil
        })
        
        return
    end

    _addHook(hook, func, ext)
end)

---@param mo mobj_t
---@return boolean
rawset(_G, "P_ObjectIsValid", function(mo)
    return mo and mo.valid
end)

---@param p player_t
---@return boolean
rawset(_G, "P_PlayerIsValid", function(p)
    return p and p.playerstate ~= PST_DEAD
end)

---@param mo mobj_t
---@return boolean
rawset(_G, "P_ObjectIsPlayer", function(mo)
    return P_ObjectIsValid(mo) and P_PlayerIsValid(mo.player)
end)

dofile("Ammo.lua")
dofile("Weapon.lua")
dofile("Animation.lua")

dofile("Weapons/Pistol.lua")
dofile("Weapons/Magnum.lua")
dofile("Weapons/Shotgun.lua")
dofile("Weapons/SMG.lua")
dofile("Weapons/Tau Cannon.lua")
dofile("Weapons/Crowbar.lua")

dofile("Inventory.lua")
dofile("Hooks.lua")
dofile("Pickup.lua")

dofile("UI/Viewmodel.lua")
dofile("UI/HUD.lua")

HL.RegisterPickup(MT_RING)

HL.RegisterPickup(MT_INFINITYRING)

HL.RegisterPickup(MT_RAILRING)
HL.RegisterPickup(MT_RAILPICKUP)

HL.RegisterPickup(MT_SCATTERRING)
HL.RegisterPickup(MT_SCATTERPICKUP)

addHook("HL_OnPickupGained", function(player)
    HL.AddAmmo(player.HL, HL.AmmunitionType.Bullet, 17 * 3)
    HL.GiveWeapon(player, HL.Weapons.Pistol)
end, MT_INFINITYRING)

addHook("HL_OnPickupGained", function(player)
    HL.AddAmmo(player.HL, HL.AmmunitionType.Cartridge, 6)
end, MT_RAILRING)

addHook("HL_OnPickupGained", function(player)
    HL.AddAmmo(player.HL, HL.AmmunitionType.Cartridge, 12)

    HL.GiveWeapon(player, HL.Magnum)
end, MT_RAILPICKUP)

addHook("HL_OnPickupGained", function(player)
    HL.AddAmmo(player.HL, HL.AmmunitionType.Shell, 8)
end, MT_SCATTERRING)

addHook("HL_OnPickupGained", function(player)
    HL.AddAmmo(player.HL, HL.AmmunitionType.Shell, 16)

    HL.GiveWeapon(player, HL.Weapons.Shotgun)
end, MT_SCATTERPICKUP)
