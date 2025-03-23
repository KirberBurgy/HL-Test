
---@class hlobjectdef_t
---@field Health fixed_t The health of the object. For reference, a regular pistol shot does 5FU damage.
---@field Damage fixed_t The damage of the object done to a player. For reference, a Gold Buzz does 10FU damage.
---@field Pickups { Object: integer, Probability: fixed_t }[] The pickups an object can drop.

local object_defs = {}

---@return hlobjectdef_t
function HL.GetObjectTraits(object_type)
    return object_defs[object_type]
end

--- This function assigns an object type a preset
--- health, damage value, pickups, and various other
--- unchanging traits (see the `hlobjectdef_t` type).
--- This function adds hooks and as such 
--- should be called at file scope in 
--- order to ensure network synchronization.
---@param object_type integer The type of the object (typically suppled in an MT_* constant.)
---@param traits hlobjectdef_t The traits of the object, including health, damage, and pickup drops.
function HL.Register(object_type, traits)
    object_defs[object_type] = traits

    if traits.Health or traits.Damage then
        traits.Health = $ or -1
        traits.Damage = $ or 0

        addHook("MobjSpawn", function(object)
            object.HLHealth = traits.Health or -1
            object.HLDamage = traits.Damage or 0 
        end, object_type)
    end

    if traits.Pickups then
        addHook("MobjDeath", function(object)
            for _, pickup in pairs(traits.Pickups) do
                if not P_RandomChance(pickup.Probability) then
                    continue
                end
                
                P_SpawnMobjFromMobj(
                    object,
                    P_RandomFixed() * 20,
                    P_RandomFixed() * 20,
                    0,
                    pickup.Object
                )
            end
        end)
    end
end


--#region Enemies

-- Greenflower Zone

HL.Register(MT_BLUECRAWLA, {
    Health = 20 * FU,
    Damage = 10 * FU,
    Pickups = { { Object = MT_HLCLIP, Probability = FRACUNIT / 4 }}
})

HL.Register(MT_REDCRAWLA, {
    Health = 30 * FU,
    Damage = 10 * FU,
    Pickups = { { Object = MT_HLCLIP, Probability = FRACUNIT } }
})

-- Fucking dumbass shit bitch Stupid Dumb Unnamed RoboFish
HL.Register(MT_GFZFISH, {
    Health = 20 * FU,
    Damage = 10 * FU,
    -- Make it drop uranium cause funny lmao
    Pickups = { { Object = MT_HLDEPLETEDURANIUM, Probability = FRACUNIT / 1000 }}
})

-- Techno Hill Zone

HL.Register(MT_GOLDBUZZ, {
    Health = 10 * FU,
    Damage = 10 * FU,
    Pickups = { { Object = MT_HLCLIP, Probability = FRACUNIT / 4 } }
})

HL.Register(MT_REDBUZZ, {
    Health = 20 * FU,
    Damage = 15 * FU,
    Pickups = { 
        { Object = MT_HLSHELLS, Probability = FRACUNIT / 2 }, 
        { Object = MT_HLMAGAZINE, Probability = FRACUNIT / 2 }, 
        { Object = MT_HLCLIP, Probability = FRACUNIT } 
    }
})
 
HL.Register(MT_SPRINGSHELL, {
    Health = 50 * FU,
    Damage = 15 * FU / 2,
    Pickups = { { Object = MT_HLCELL, Probability = FRACUNIT / 3 } }
})

HL.Register(MT_YELLOWSHELL, {
    Health = 50 * FU,
    Damage = 15 * FU / 2,
    Pickups = { 
        { Object = MT_HLCELL, Probability = FRACUNIT / 3 }, 
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT }
    }
})

HL.Register(MT_DETON, {
    Damage = 50 * FU,
    Pickups = {
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT },
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT },
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT }
    }
})

-- Deep Sea Zone

HL.Register(MT_CRUSHSTACEAN, {
    Health = 30 * FU,
    Damage = 10 * FU,
    Pickups = {
        { Object = MT_HLCARTRIDGEBOX, Probability = FRACUNIT / 2 }
    }
})

HL.Register(MT_CRUSHCLAW, {
    Damage = 35 * FU
})

HL.Register(MT_SKIM, {
    Health = 20 * FU,
    Damage = 15 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT },
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT / 2 }
    }
})

HL.Register(MT_MINE, {
    Damage = 22 * FU
})

HL.Register(MT_JETJAW, {
    Health = 25 * FU,
    Damage = 27 * FU,
    Pickups = {
        { Object = MT_HLCLIP, Probability = FRACUNIT / 2 },
        { Object = MT_HLSHELLS, Probability = FRACUNIT / 3 }
    }
})

-- Castle Eggman Zone

HL.Register(MT_EGGGUARD, {
    Health = 40 * FU,
    Damage = 30 * FU,
    Pickups = {
        { Object = MT_HLCLIP, Probability = FRACUNIT / 2 },
        { Object = MT_HLSHELLS, Probability = FRACUNIT / 4 },
        { Object = MT_HLMAGAZINE, Probability = FRACUNIT / 4 },
        { Object = MT_HLCARTRIDGEBOX, Probability = FRACUNIT / 4 }
    }
})

HL.Register(MT_EGGSHIELD, {
    Pickups = { { Object = MT_HLSNARKHIVE, Probability = FRACUNIT / 2 } }
})

HL.Register(MT_ROBOHOOD, {
    Health = 30 * FU,
    Damage = 15 * FU,
    Pickups = {
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT },
    }
})

HL.Register(MT_ARROW, {
    Damage = 35 * FU
})

HL.Register(MT_FACESTABBER, {
    Health = 100 * FU,
    Damage = 40 * FU,
    Pickups = {
        { Object = MT_HLDEPLETEDURANIUM, Probability = FRACUNIT },
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT / 2 },
        { Object = MT_HLROCKET, Probability = FRACUNIT / 2 }
    }
})

-- Arid Canyon Zone

HL.Register(MT_VULTURE, {
    Health = 30 * FU,
    Damage = 25 * FU,
    Pickups = {
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT / 2 },
        { Object = MT_HLROCKET, Probability = FRACUNIT / 2 }
    }
})

HL.Register(MT_CANARIVORE, {
    Health = 10 * FU,
    Damage = 5 * FU,
    Pickups = {
        { Object = MT_HLSNARKHIVE, Probability = FRACUNIT / 3 }
    }
})

HL.Register(MT_MINUS, {
    Health = 25 * FU,
    Damage = 34 * FU,
    Pickups = {
        { Object = MT_HLMAGAZINE, Probability = FRACUNIT },
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT / 4 }
    }
})

HL.Register(MT_GSNAPPER, {
    Health = 60 * FU,
    Damage = 10 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT / 3 },
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT / 3 }
    }
})

HL.Register(MT_SNAPPER_LEG, {
    Damage = 38 * FU
})

-- Red Volcano Zone

HL.Register(MT_UNIDUS, {
    Health = 62 * FU,
    Damage = 5 * FU,
    Pickups = {
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT }
    }
})

HL.Register(MT_UNIBALL, {
    Damage = 29 * FU
})

HL.Register(MT_PYREFLY, {
    Health = 45 * FU,
    Damage = 18 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT },
        { Object = MT_HLSATCHELCHARGE, Probability = 2 * FRACUNIT / 3 }
    }
})

HL.Register(MT_PYREFLY_FIRE, {
    Damage = 30 * FU
})

HL.Register(MT_DRAGONBOMBER, {
    Health = 100 * FU,
    Damage = 20 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT / 2 },
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT / 4 },
        { Object = MT_HLROCKET, Probability = FRACUNIT / 4 }
    }
})

HL.Register(MT_DRAGONTAIL, {
    Damage = 20 * FU
})

HL.Register(MT_DRAGONMINE, {
    Damage = 39 * FU
})

HL.Register(MT_PTERABYTE, {
    Health = 40 * FU
})

-- Egg Rock Zone

HL.Register(MT_SNAILER, {
    Health = 58 * FU,
    Damage = 7 * FU,
    Pickups = {
        { Object = MT_HLDEPLETEDURANIUM, Probability = FRACUNIT }
    }
})

HL.Register(MT_ROCKET, {
    Damage = 39 * FU
})

HL.Register(MT_POINTY, {
    Health = 90 * FU,
    Damage = 37 * FU,
    Pickups = {
        { Object = MT_HLCROSSBOWBOLT, Probability = FRACUNIT }
    }
})

HL.Register(MT_POPUPTURRET, {
    Health = 100 * FU,
    Damage = 8 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT },
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT }
    }
})

HL.Register(MT_JETTGUNNER, {
    Health = 70 * FU,
    Damage = 12 * FU,
    Pickups = {
        { Object = MT_HLMAGAZINE, Probability = FRACUNIT },
        { Object = MT_HLSHELLS, Probability = FRACUNIT },
        { Object = MT_HLCARTRIDGEBOX, Probability = FRACUNIT / 2 },
    }
})

HL.Register(MT_JETTBULLET, {
    Damage = 39 * FU
})

HL.Register(MT_JETTBOMBER, {
    Health = 78 * FU,
    Damage = 12 * FU,
    Pickups = {
        { Object = MT_HLFRAGGRENADE, Probability = FRACUNIT },
        { Object = MT_HLSATCHELCHARGE, Probability = FRACUNIT }
    }
})

--#endregion

--#region Bosses

HL.Register(MT_EGGMOBILE, {
    Health = 30 * FU,
    Damage = 10 * FU,
    Pickups = {
        { Object = MT_HLSHOTGUNDROP, Probability = FRACUNIT },
        { Object = MT_HLSMGDROP, Probability = FRACUNIT }
    }
})

--#endregion

---@param player player_t
---@param projectile mobj_t
---@param target mobj_t
---@return boolean?
addHook("HL_OnWeaponHit", function(player, projectile, target)
    if not (target and target.HLHealth and target.HLHealth ~= -1) then
        return
    end

    projectile.HL.Hit = $ or {}

    if projectile.HL.Hit[target] then
        return
    end

    local target_last_health = target.HLHealth
    target.HLHealth = $ - projectile.HL.Damage

    if target.HLHealth <= 0 then
        local health_lost = 1 + ( target_last_health - target.HLHealth ) / object_defs[target.type].Health

        P_DamageMobj(target, projectile, player.mo, health_lost)
        P_DamageMobj(projectile, 1)

        target.HLHealth = object_defs[target.type].Health + ($ % object_defs[target.type].Health)
    end

    projectile.HL.Hit[target] = true

    return false
end)