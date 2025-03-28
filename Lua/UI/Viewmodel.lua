---@param player player_t
addHook("HL_FreemanThinker", function(player)
    if not (player.HL and player.HL.CurrentWeapon) then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    hl.ViewmodelData = $ or {
        Progress = 1,
        Clock = 1,
        State = HL.AnimationType.Idle
    }

    ---@class hlviewmodel_t
    local viewmodel = HL.Viewmodels[hl.CurrentWeapon.Name]

    if not viewmodel then
        return
    end

    ---@class hlweaponanim_t
    local animation = hl.ViewmodelData.Animation

    if not animation or not animation.Durations or not animation.Durations[hl.ViewmodelData.Progress] then
        return
    end

    hl.ViewmodelData.Clock = $ + 1
        
    if animation.Sounds[hl.ViewmodelData.Progress] then
        HL.PlayRandomSound(player.mo, animation.Sounds[hl.ViewmodelData.Progress])
    end
    
    if hl.ViewmodelData.Clock >= animation.Durations[hl.ViewmodelData.Progress] then
        hl.ViewmodelData.Progress = $ + 1
        hl.ViewmodelData.Clock = 1
    end

    if hl.ViewmodelData.Progress >= animation.Length then
        hl.ViewmodelData.Progress = 1
        hl.ViewmodelData.Clock = 1

        HL.SetAnimation(player, HL.NextAnimation(player))
    end
end)

---@param player player_t
---@param camera camera_t
addHook("HUD", function(drawer, player, camera)
    if not (player and player.mo and player.HL and not camera.chase) then
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    if not hl.ViewmodelData or not hl.CurrentWeapon then
        return
    end

    local viewmodel = HL.Viewmodels[hl.CurrentWeapon.Name]

    if not viewmodel or not hl.ViewmodelData.Animation then
        return
    end

    local patch = drawer.cachePatch( hl.ViewmodelData.Animation.Sentinel .. hl.ViewmodelData.Progress )
    drawer.drawScaled(viewmodel.OffsetX, viewmodel.OffsetY, FRACUNIT, patch, V_SNAPTOBOTTOM | viewmodel.Flags)
end, "game")