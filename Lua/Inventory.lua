---@class hlinventory_t
---@field Ammo table
---@field Weapons hlweapon_t[]

---@class hlplayer_t
---@field Inventory hlinventory_t 
---@field CurrentWeapon? hlweapon_t

---@class hlobject_t
---@field Player player_t
---@field SourceWeapon hlweapon_t

COM_AddCommand("addammo", function(player, arg1, arg2)
    if not player or not player.mo or not player.HL then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    if not arg1 then
        CONS_Printf(player, "Types of ammo:")
        CONS_Printf(player, "\t9mm, SMG:                1")
        CONS_Printf(player, "\t.357:                    2")
        CONS_Printf(player, "\tShotgun:                 3")
        CONS_Printf(player, "\tCrossbow:                4")
        CONS_Printf(player, "\tRPG:                     5")
        CONS_Printf(player, "\tTau Cannon, Gluon Gun:   6")
        CONS_Printf(player, "\tFrag Grenade:            7")
        CONS_Printf(player, "\tSatchel Charge:          8")
        CONS_Printf(player, "\tTrip Mine:               9")
        CONS_Printf(player, "\tSnark:                   10")
        CONS_Printf(player, "\tSMG Grenade:             11")

        return
    end

    local ammo_type = tonumber(arg1)
    local ammo_count = tonumber(arg2)

    if not ammo_type or ammo_type < 1 or ammo_type > 11 or not ammo_type then
        return
    end

    HL.AddAmmo(hl, ammo_type, ammo_count)
end)

COM_AddCommand("giveweapon", function(player, arg1)
    if not player or not player.mo or not player.HL then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    if not arg1 then
        CONS_Printf(player, "Weapons (CASE SENSITIVE): ")
    end

    local valid_name = false

    for name, _ in pairs(HL.Weapons) do
        if not arg1 then
            CONS_Printf(player, "\t" .. name)
            
            continue
        end

        valid_name = $ or arg1 == name
    end

    if not arg1 then
        return
    end

    if not valid_name then
        CONS_Printf(player, "Invalid weapon name provided.")

        return
    end

    HL.GiveWeapon(player, HL.Weapons[arg1])
end)

local function NewPlayerAmmo()
    return {
        [HL.AmmunitionType.Bullet] = 250,
        [HL.AmmunitionType.Cartridge] = 0,
        [HL.AmmunitionType.Shell] = 125,
        [HL.AmmunitionType.Bolt] = 0,
        [HL.AmmunitionType.Rocket] = 0,
        [HL.AmmunitionType.Uranium] = 100,
        [HL.AmmunitionType.Unique.FragGrenade] = 0,
        [HL.AmmunitionType.Unique.SatchelCharge] = 0,
        [HL.AmmunitionType.Unique.TripMine] = 0,
        [HL.AmmunitionType.Unique.MP5Grenade] = 0
    }
end

local function NewPlayerWeapons()
    return {
        [HL.WeaponClass.Melee]   = { 
            RecursiveClone(HL.Weapons.Crowbar)
        },
        [HL.WeaponClass.Handgun] = { 
            RecursiveClone(HL.Weapons.Pistol)
        }
    }
end

---@param player player_t
---@param weapon_prototype hlweapon_t
function HL.GiveWeapon(player, weapon_prototype)
    local hl = player.HL

    hl.Inventory.Weapons[weapon_prototype.Class] = $ or {}

    for _, weapon in pairs(hl.Inventory.Weapons[weapon_prototype.Class]) do
        if weapon.Name == weapon_prototype.Name then
            return
        end
    end

    ---@class hlweapon_t
    local weapon = RecursiveClone(weapon_prototype)

    table.insert( hl.Inventory.Weapons[weapon_prototype.Class], weapon )

    hl.CurrentWeapon = weapon
    
    HL.SetAnimation(player, HL.AnimationType.Ready)

    table.sort(hl.Inventory.Weapons[weapon_prototype.Class], function (a, b)
        if not a.HUDPriority or not b.HUDPriority then
            return true
        end

        return a.HUDPriority < b.HUDPriority
    end)
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

        player.HL.CurrentWeapon = player.HL.Inventory.Weapons[HL.WeaponClass.Melee][1]
        HL.SetAnimation(player, HL.AnimationType.Ready)
    end
    
    player.weapondelay = INT32_MAX
end)