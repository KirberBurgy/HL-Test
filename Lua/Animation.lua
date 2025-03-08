HL.AnimationType = {
    -- This animation will never be
    -- played by the Half Life mod.
    Custom      = 0,

    -- This animation is played when
    -- the weapon is first collected,
    -- or when the weapon is re-equipped.
    Ready       = 1,

    -- This animation is played when
    -- no other animation is playing.
    Idle        = 2,

    -- This animation is played when
    -- the secondary mode is fired.
    Secondary   = 3,

    -- This animation is played when
    -- the primary mode is fired.
    Primary     = 4,

    -- This animation is played when
    -- the weapon is reloaded. This animation
    -- will be repeated if the weapon
    -- reloads one-by-one.
    Reload      = 5,
}

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
---@class hlweaponanim_t hlanimframe_t[]

--- Returns the raw data of frames
--- with similar properties in sequence.
---@param path string
---@param start_frame integer
---@param frame_steps integer
---@param duration tic_t
function HL.UnpackFrameSet(target_table, path, start_frame, frame_steps, duration)
    for i = 0, frame_steps - 1 do
        table.insert(target_table,
            {
                FrameLength = duration,
                FrameName = path .. start_frame + i
            })
    end
end

HL.Viewmodels = {}