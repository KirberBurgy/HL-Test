---@param projectile mobj_t
local function ProjectileThinker(projectile)
    if not projectile.valid or not projectile.HL then
        return
    end

    if projectile.HL.IsHitscan then
        while not P_RailThinker(projectile) do end

        return
    end

    for _, hook in ipairs(HL.Hooks.ProjectileThinker) do
        if not hook.Extra or hook.Extra == projectile.type then
            hook.Callback(projectile.target.player, projectile)
        end
    end
end

---@param projectile mobj_t
---@param hit mobj_t
local function OnWeaponHit(projectile, hit)
    if projectile.z > hit.z + hit.height 
    or (projectile.z + projectile.health) < hit.z then
        return
    end

    if not projectile.valid or not projectile.HL then
        return
    end

    if hit == projectile.HL.Player.mo then
        return false
    end

    if not (hit.flags & (MF_ENEMY | MF_BOSS)) then
        return
    end

    local correct_hook = projectile.HL.IsHitscan and HL.Hooks.OnHitscanHit or HL.Hooks.OnProjectileHit

    HL.PlayHitEnemySound(projectile, projectile.HL.SourceFire.Fire)

    for _, hook in ipairs(HL.Hooks.OnWeaponHit) do
        if not hook.Extra or hook.Extra == projectile.HL.SourceWeapon.Name then
            hook.Callback(projectile.target.player, projectile, hit)
        end
    end

    for _, hook in ipairs(correct_hook) do
        if not hook.Extra or hook.Extra == projectile.HL.SourceWeapon.Name then
            hook.Callback(projectile.target.player, projectile, hit)
        end
    end
end

---@param mo mobj_t
---@param line line_t
local function OnWeaponLineHit(mo, _, line)
    if not mo or not mo.valid or not line or not line.valid then
        return
    end

    if not mo.HL then
        return
    end

    HL.PlayHitWallSound(mo, mo.HL.SourceFire.Fire)

    for _, hook in ipairs(HL.Hooks.OnWeaponLineHit) do
        if not hook.Extra or hook.Extra == mo.HL.SourceWeapon.Name then
            hook.Callback(mo.HL.Player, mo, line)
        end
    end
end

---@param player player_t
---@param hl hlplayer_t
---@param use_hook table
---@return boolean
local function RunFireHooks(player, hl, use_hook)
    local override = false

    for _, hook in ipairs(HL.Hooks.OnFire) do
        if hook.Extra and hook.Extra ~= hl.CurrentWeapon.Name then
            continue
        end

        override = hook.Callback(player, hl.CurrentWeapon) or $
    end

    for _, hook in ipairs(use_hook) do
        if hook.Extra and hook.Extra ~= hl.CurrentWeapon.Name then
            continue
        end

        override = hook.Callback(player, hl.CurrentWeapon) or $
    end

    return override
end

---@param hl hlplayer_t
local function PlayerHasEnoughPrimaryAmmo(hl)
    if hl.CurrentWeapon.PrimaryFire.AmmoType == HL.AmmunitionType.None then
        return true
    end

    if hl.CurrentWeapon.PrimaryFire.Reload then
        return hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip >= hl.CurrentWeapon.PrimaryFire.Fire.RequiredAmmo
    end

    return hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] >= hl.CurrentWeapon.PrimaryFire.Fire.RequiredAmmo
end

---@param hl hlplayer_t
local function PlayerHasEnoughSecondaryAmmo(hl)
    if hl.CurrentWeapon.SecondaryFire.AmmoType == HL.AmmunitionType.None then
        return true
    end

    if hl.CurrentWeapon.SecondaryFire.AmmoType == HL.UsesPrimaryClip then
        return hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip >= hl.CurrentWeapon.SecondaryFire.Fire.RequiredAmmo
    end

    if hl.CurrentWeapon.SecondaryFire.Reload then
        return hl.CurrentWeapon.SecondaryFire.Reload.CurrentClip >= hl.CurrentWeapon.SecondaryFire.Fire.RequiredAmmo
    else
        return (hl.Inventory.Ammo[hl.CurrentWeapon.SecondaryFire.AmmoType] and hl.Inventory.Ammo[hl.CurrentWeapon.SecondaryFire.AmmoType] >= hl.CurrentWeapon.SecondaryFire.Fire.RequiredAmmo)
    end
end

---@param hl hlplayer_t
---@param fire_mode hlweaponfire_t
local function DeductPlayerAmmo(hl, fire_mode)
    if fire_mode.AmmoType == HL.AmmunitionType.None then
        return
    end

    if fire_mode.AmmoType == HL.UsesPrimaryClip then
        hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip = $ - fire_mode.Fire.RequiredAmmo
        
        return
    end

    if not fire_mode.Reload then
        hl.Inventory.Ammo[fire_mode.AmmoType] = $ - fire_mode.Fire.RequiredAmmo
        
        return
    end

    fire_mode.Reload.CurrentClip = $ - fire_mode.Fire.RequiredAmmo
end

---@param player player_t
---@param hl hlplayer_t
local function HandlePrimaryFire(player, hl)
    if not (player.cmd.buttons & BT_ATTACK) or hl.WeaponPalette.Open then
        return
    end

    if hl.Cooldown > 0 then
        return
    end

    if hl.CurrentWeapon.PrimaryFire.Fire.Automatic
    or not (player.lastbuttons & BT_ATTACK) then

        if not PlayerHasEnoughPrimaryAmmo(hl) then
            return
        end

        hl.Cooldown = hl.CurrentWeapon.PrimaryFire.Fire.Cooldown
        if RunFireHooks(player, hl, HL.Hooks.OnPrimaryUse) then
            return 
        end

        HL.FireWeapon(player, hl.CurrentWeapon, hl.CurrentWeapon.PrimaryFire)
        HL.PlayFireSound(player.mo, hl.CurrentWeapon.PrimaryFire.Fire)
        HL.SetAnimation(player, HL.AnimationType.Primary)
        DeductPlayerAmmo(hl, hl.CurrentWeapon.PrimaryFire)
    end
end


---@param player player_t
---@param hl hlplayer_t
local function HandleSecondaryFire(player, hl)
    if not (hl.CurrentWeapon.SecondaryFire) then
        return
    end

    if not (player.cmd.buttons & BT_FIRENORMAL) then
        return
    end

    if hl.Cooldown > 0 then
        return
    end

    if hl.CurrentWeapon.SecondaryFire.Fire.Automatic
    or not (player.lastbuttons & BT_FIRENORMAL) then

        if not PlayerHasEnoughSecondaryAmmo(hl) then
            return
        end

        hl.Cooldown = hl.CurrentWeapon.SecondaryFire.Fire.Cooldown

        if RunFireHooks(player, hl, HL.Hooks.OnSecondaryUse) then
            return 
        end

        HL.FireWeapon(player, hl.CurrentWeapon, hl.CurrentWeapon.SecondaryFire)
        HL.PlayFireSound(player.mo, hl.CurrentWeapon.SecondaryFire.Fire)
        HL.SetAnimation(player, HL.AnimationType.Secondary)
        DeductPlayerAmmo(hl, hl.CurrentWeapon.SecondaryFire)
    end
end

---@param player player_t
addHook("PlayerThink", function(player)
    if not P_PlayerIsValid(player) -- [[ or player.mo.skin ~= ]] then
        return
    end

    for _, hook in ipairs(HL.Hooks.FreemanThinker) do
        hook.Callback(player)
    end
end)


---@param player player_t
addHook("HL_FreemanThinker", function(player)
    if not player.HL then 
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    if not hl.CurrentWeapon then
        return
    end

    hl.Cooldown = $ or 0

    HandlePrimaryFire(player, hl)
    HandleSecondaryFire(player, hl)

    if hl.Cooldown > 0 then

        hl.Cooldown = $ - 1

        if hl.CurrentWeapon.PrimaryFire.Reload
        and hl.Reloading
        and hl.CurrentWeapon.PrimaryFire.Reload.OneByOne
        and hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip > 1
        and player.cmd.buttons & BT_ATTACK then
            hl.Reloading = false
            hl.Cooldown = hl.CurrentWeapon.PrimaryFire.Reload.ReloadDelay
            HL.SetAnimation(player, HL.AnimationType.ReloadEnd)
        end
    end

    if hl.Reloading and hl.Cooldown == 0 then
        if hl.CurrentWeapon.PrimaryFire.Reload.OneByOne then 
            hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip = $ + 1
            hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] = $ - 1

            hl.Cooldown = hl.CurrentWeapon.PrimaryFire.Reload.ReloadDelay

            hl.Reloading = 
                hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip ~= hl.CurrentWeapon.PrimaryFire.Reload.ClipSize
                and hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] ~= 0
        else
            local to_add = min(
            hl.CurrentWeapon.PrimaryFire.Reload.ClipSize - hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip, 
            hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType])

            hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip = $ + to_add
            hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] = $ - to_add

            hl.Reloading = false
        end
    end

    if hl.CurrentWeapon.PrimaryFire.Reload 
    and hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip == 0 
    and hl.Cooldown == 0
    and not hl.Reloading
    and hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] > 0 then
        hl.Cooldown = hl.CurrentWeapon.PrimaryFire.Reload.ReloadDelay
        hl.Reloading = true

        HL.SetAnimation(player, 
            hl.CurrentWeapon.PrimaryFire.Reload.OneByOne and HL.AnimationType.ReloadStart or HL.AnimationType.Reload)
    end
end)

-- garbanzo code
local mobj_number = #mobjinfo - 1

for i = 0, #mobjinfo - 1 do
    if not ( mobjinfo[i].flags & MF_MISSILE ) then
        continue
    end

    addHook("MobjThinker", ProjectileThinker, i)
    addHook("MobjMoveBlocked", OnWeaponLineHit, i)
    addHook("MobjMoveCollide", OnWeaponHit, i)
end

addHook("AddonLoaded", function()
    for i = mobj_number, #mobjinfo - 1 do
        if not ( mobjinfo[i].flags & MF_MISSILE ) then
            continue
        end
    
        addHook("MobjThinker", ProjectileThinker, i)
        addHook("MobjMoveBlocked", OnWeaponLineHit, i)
        addHook("MobjMoveCollide", OnWeaponHit, i)
    end

    mobj_number = #mobjinfo - 1
end)