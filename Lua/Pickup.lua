local pickups = { }

function HL.RegisterPickup(object_type)
    pickups[object_type] = $ or true
end

addHook("TouchSpecial", function(special, player_mo)
    if not (special and special.valid) then
        return
    end

    if not (player_mo and player_mo.valid and player_mo.player and player_mo.player.HL) then
        return
    end

    ---@class hlplayer_t
    local hl = player_mo.player.HL

    if not pickups[special.type] then
        return
    end

    for _, hook in ipairs(HL.Hooks.OnPickupGained) do
        if not hook.Extra or hook.Extra == special.type then
            hook.Callback(player_mo.player)
        end
    end
end)