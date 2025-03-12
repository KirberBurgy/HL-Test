freeslot(
    "MT_HLCLIP", 
    "MT_HLCARTRIDGEBOX", 
    "MT_HLSHELLS", 
    "MT_HLMAGAZINE",
    "MT_HLCROSSBOWBOLT"
    "MT_HLROCKET",
    "MT_HLDEPLETEDURANIUM",
    "MT_HLFRAGGRENADE",
    "MT_HLSATCHELCHARGE",
    "MT_HLSNARKHIVE",

    "MT_HLMEDKIT",
    "MT_HLCELL"
)

freeslot(
    "MT_HLPISTOLDROP",
    "MT_HLMAGNUMDROP",
    "MT_HLSHOTGUNDROP",
    "MT_HLSMGDROP",
    "MT_HLCROSSBOWDROP",
    "MT_HLRPGDROP",
    "MT_HLTAUCANNONDROP",
    "MT_HLGLUONGUNDROP"
)

local pickups = { }

--- Registers a pickup to be recognized by the 
--- HL_OnPickupGained hook. This function is not
--- net safe; it adds hooks and as such 
--- should not be called in network dependent 
--- scenarios.
---@param object_type integer The object type to count as a pickup.
function HL.RegisterPickup(object_type)
    if not pickups[object_type] then

        addHook("TouchSpecial", function(special, player_mo)
            if not (special and special.valid) then
                return
            end
        
            if not (player_mo and player_mo.valid and player_mo.player and player_mo.player.HL) then
                return
            end
        
            ---@class hlplayer_t
            local hl = player_mo.player.HL
        
            for _, hook in ipairs(HL.Hooks.OnPickupGained) do
                if not hook.Extra or hook.Extra == object_type then
                    hook.Callback(player_mo.player)
                end
            end
        end, object_type)

    end

    pickups[object_type] = $ or true
end