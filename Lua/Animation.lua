HL.AnimationType = {
    -- This animation is played when
    -- the weapon is first collected,
    -- or when the weapon is re-equipped.
    Ready       = 1,

    -- This animation is played when
    -- no other animation is playing.
    Idle        = 2,

    -- This animation is played when
    -- the primary mode is fired.
    Primary     = 3,

    -- This animation is played when
    -- the secondary mode is fired.
    Secondary   = 4,

    -- This animation is played when
    -- the weapon is reloaded. If your weapon
    -- uses a looped reload, then use
    -- ReloadStart, ReloadLoop, and ReloadEnd
    -- in conjunction.
    Reload      = 5,

    -- This animation is played when a
    -- weapon with a one-by-one reload
    -- begins to reload.
    ReloadStart = 6,

    -- This animation is played when a
    -- weapon with a one-by-one reload
    -- reloads a single bullet.
    ReloadLoop = 7,

    -- This animation is played when a
    -- weapon with a one-by-one reload
    -- finishes reloading.
    ReloadEnd = 8,

    -- Animations with type numbers greater than eight
    -- will never be played by the Half Life mod.
    Custom      = 0,
}

HL.NextAnimationSlot = 9

-- This maps animation numbers
-- to their next state. If you
-- want this mod to automatically
-- cycle animations, define
-- maps to animation here. The
-- map should be laid out as such:
-- ```lua
-- [HL.AnimationType.Key] = function(hlplayer_t) 
--     return HL.AnimationType.Next 
-- end
-- ```
-- . Overrides to non-custom animations are disallowed for safety.
HL.AnimationMap = {}

--- This function is *not* net-safe. 
--- Do not call it outside of file-block code.
--- Creates a new animation type that counts as a 
--- valid animation state.
---@return integer An animation type. It should be stored should store it so it can be used in comparisons.
function HL.CreateAnimationType()
    local free_slot = HL.NextAnimationSlot

    HL.NextAnimationSlot = $ + 1

    return free_slot
end

---@param player player_t
function HL.NextAnimation(player)
    ---@class hlplayer_t
    local hl = player.HL

    if hl.ViewmodelData.State == HL.AnimationType.ReloadStart then
        return HL.AnimationType.ReloadLoop
    end

    if hl.ViewmodelData.State == HL.AnimationType.ReloadLoop
        if hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip == hl.CurrentWeapon.PrimaryFire.Reload.ClipSize
        or hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] == 0 
        then

            return HL.AnimationType.ReloadEnd
        end

        return HL.AnimationType.ReloadLoop
    end

    if hl.ViewmodelData.State > 8 then
        local state = hl.ViewmodelData.State

        return (HL.AnimationMap[state] and HL.AnimationMap[state](player)) or HL.AnimationType.Idle
    end

    return HL.AnimationType.Idle
end

---@param player player_t
---@param animation integer
function HL.SetAnimation(player, animation)
    if not player.HL or not player.HL.ViewmodelData then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    hl.ViewmodelData.State = animation

    hl.ViewmodelData.Progress = 1
    hl.ViewmodelData.Clock = 1
end

---@class hlanimframe_t
---@field FrameLength tic_t The number of tics each frame lasts for.
---@field FrameName string The name of the graphic of the frame.

-- Encapsulates a weapon animation. Weapon animations should be stored
-- in folders with frames ranging from 1-n, where n is the number of frames.
---@class hlweaponanim_t
---@field Sentinel string The name of the first frame. Following frames should come in a succession.
---@field Length integer The number of frames in the animation.
---@field Durations tic_t[] The duration, in tics, of each frame.
---@field Sounds integer[] The sounds played at each frame.

local function KeywiseSort(t) 
    local sorted_keys = {} 
    for key, _ in pairs(t) do
        table.insert(sorted_keys, key)
    end

    table.sort(sorted_keys)
    return sorted_keys
end

---@param sentinel string
---@param frame_count integer
---@param durations tic_t[]
---@param sounds? integer[]|table[]
---@return hlweaponanim_t
function HL.NewWeaponAnimation(sentinel, frame_count, durations, sounds)
    ---@class hlweaponanim_t
    local animation = {
        Sentinel = sentinel,
        Length = frame_count,
        Durations = {},
        Sounds = sounds or {}
    }

    local sorted_keys = KeywiseSort(durations)

    local last_frame = sorted_keys[1] 
    animation.Durations[last_frame] = durations[last_frame]

    for i = 2, #sorted_keys do
        local frame = sorted_keys[i]

        for j = last_frame + 1, frame - 1 do
            animation.Durations[j] = durations[last_frame]
        end

        animation.Durations[frame] = durations[frame]
        last_frame = frame
    end

    for i = last_frame + 1, frame_count do
        animation.Durations[i] = durations[last_frame]
    end

    return animation
end

HL.Viewmodels = {}