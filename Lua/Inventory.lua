---@class hlinventory_t
---@field Ammo table
---@field Weapons hlweapon_t[]

---@class hlplayer_t
---@field Inventory hlinventory_t 
---@field CurrentWeapon? hlweapon_t

---@class hlobject_t
---@field Player player_t
---@field SourceWeapon hlweapon_t

HL.AmmoInfo = {
    [HL.AmmunitionType.Bullet] = {
        Maximum = 250
    },

    [HL.AmmunitionType.Cartridge] = {
        Maximum = 36
    },

    [HL.AmmunitionType.Shell] = {
        Maximum = 125
    },

    [HL.AmmunitionType.Bolt] = {
        Maximum = 50
    },

    [HL.AmmunitionType.Rocket] = {
        Maximum = 5
    },

    [HL.AmmunitionType.Uranium] = {
        Maximum = 100
    },

    [HL.AmmunitionType.Unique.FragGrenade] = {
        Maximum = 10
    },

    [HL.AmmunitionType.Unique.SatchelCharge] = {
        Maximum = 5
    },

    [HL.AmmunitionType.Unique.TripMine] = {
        Maximum = 5
    },

    [HL.AmmunitionType.Unique.Snark] = {
        Maximum = 15
    },

    [HL.AmmunitionType.Unique.MP5Grenade] = {
        Maximum = 8
    }
}

local function NewPlayerAmmo()
    return {
        [HL.AmmunitionType.Bullet] = 34,
        [HL.AmmunitionType.Cartridge] = 0,
        [HL.AmmunitionType.Shell] = 0,
        [HL.AmmunitionType.Bolt] = 0,
        [HL.AmmunitionType.Rocket] = 0,
        [HL.AmmunitionType.Uranium] = 0,
        [HL.AmmunitionType.Unique.FragGrenade] = 0,
        [HL.AmmunitionType.Unique.SatchelCharge] = 0,
        [HL.AmmunitionType.Unique.TripMine] = 0,
        [HL.AmmunitionType.Unique.MP5Grenade] = 0
    }
end

local function NewPlayerWeapons()
    return {
        [HL.WeaponClass.Melee]   = { 
            [1] = RecursiveClone(HL.Crowbar) 
        },
        [HL.WeaponClass.Handgun] = { 
            [1] = RecursiveClone(HL.Pistol),
            [2] = RecursiveClone(HL.Magnum) 
        },
        [HL.WeaponClass.Primary] = {
            [1] = RecursiveClone(HL.Shotgun),
            [2] = RecursiveClone(HL.SMG)
        },
        [HL.WeaponClass.Experimental] = {
        }
    }
end

addHook("HL_FreemanThinker", function(player)
    if not player.HL then
        
        ---@class hlplayer_t
        player.HL = {
            Inventory = {
                Ammo = NewPlayerAmmo(),
                Weapons = NewPlayerWeapons()
            },

            CurrentWeapon = nil
        }

        player.HL.CurrentWeapon = player.HL.Inventory.Weapons[2][1]

    end
end)