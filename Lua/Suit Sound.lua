freeslot(
    "sfx_hev5",
    "sfx_hev15",
    "sfx_hev10",
    "sfx_hev20",
    "sfx_hev30",
    "sfx_hev40",
    "sfx_hev50",
    "sfx_hev60",
    "sfx_hev70",
    "sfx_hev80",
    "sfx_hev90",
    "sfx_hev100",
    "sfx_hevper",
    "sfx_hevpli"
)
-- This shit is stupid as hell. TODO: Fix it all.


--- Queues a sound to be played by the suit.
---@param player player_t
function HL.QueueSuitSound(player, sound)
    ---@type hlplayer_t
    local hl = player.HL

    hl.SuitSoundQueue = $ or { [1] = sfx_None }
    hl.SuitSoundIndex = $ or 1

    table.insert(hl.SuitSoundQueue, sound)
end

addHook("HL_FreemanThinker", function(player)
    ---@type hlplayer_t
    local hl = player.HL

    if not (hl.SuitSoundQueue and hl.SuitSoundIndex) then
        return
    end

    if not S_SoundPlaying(player.mo, hl.SuitSoundQueue[hl.SuitSoundIndex]) and hl.SuitSoundQueue[hl.SuitSoundIndex + 1] then
        hl.SuitSoundIndex = $ + 1
        S_StartSound(player.mo, hl.SuitSoundQueue[hl.SuitSoundIndex], player)

        print(sfxinfo[hl.SuitSoundQueue[hl.SuitSoundIndex]].name)
    end 
end)

--[[

    if not (p and p.mo and p.mo.valid and p.HL) then
        return
    end
    
    arg1 = tonumber(arg1)

    HL.QueueSuitSound(p, sfx_hevpli)

    local ten = min(arg1 / 10, 10)
    local say_five = ( (arg1 / 5) % 2 == 1 )

    if ten > 0 then
        if ten == 1 and say_five then
            HL.QueueSuitSound(p, sfx_hev15)
        else
            HL.QueueSuitSound(p, sfx_hev10 + ten - 1)
        end
    end

    if ten ~= 1 and say_five then
        HL.QueueSuitSound(p, sfx_hev5)
    end

    HL.QueueSuitSound(p, sfx_hevper)

]]