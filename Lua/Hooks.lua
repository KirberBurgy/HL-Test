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

    local correct_hook = projectile.HL.IsHitscan and HL.Hooks.OnHitscanHit or HL.Hooks.OnProjectileHit

    for _, hook in ipairs(HL.Hooks.OnWeaponHit) do
        if not hook.Extra or hook.Extra == projectile.HL.SourceWeapon.Name then
            hook.Callback(projectile.target.player, projectile, hit )
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
        return
    end

    if hl.CurrentWeapon.PrimaryFire.ClipSize ~= HL.DoesNotReload 
        return hl.CurrentWeapon.PrimaryFire.CurrentClipSize >= hl.CurrentWeapon.PrimaryFire.Fire.RequiredAmmo
    end

    return hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] >= hl.CurrentWeapon.PrimaryFire.Fire.RequiredAmmo
end

---@param hl hlplayer_t
local function PlayerHasEnoughSecondaryAmmo(hl)
    if hl.CurrentWeapon.SecondaryFire.AmmoType == HL.AmmunitionType.None then
        return
    end
    
    if hl.CurrentWeapon.SecondaryFire.ClipSize ~= HL.DoesNotReload then
        if hl.CurrentWeapon.SecondaryFire.AmmoType ~= HL.UsesPrimaryClip then
            return hl.CurrentWeapon.SecondaryFire.CurrentClipSize >= hl.CurrentWeapon.SecondaryFire.Fire.RequiredAmmo
        end
            
        return hl.CurrentWeapon.PrimaryFire.CurrentClipSize >= hl.CurrentWeapon.SecondaryFire.Fire.RequiredAmmo
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

    if fire_mode.ClipSize == HL.DoesNotReload then
        hl.Inventory.Ammo[fire_mode.AmmoType] = $ - fire_mode.Fire.RequiredAmmo
        
        return
    end

    if fire_mode.AmmoType == HL.UsesPrimaryClip then
        hl.CurrentWeapon.PrimaryFire.CurrentClipSize = $ - fire_mode.Fire.RequiredAmmo
        
        return
    end

    fire_mode.CurrentClipSize = $ - fire_mode.Fire.RequiredAmmo
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
        DeductPlayerAmmo(hl, hl.CurrentWeapon.PrimaryFire)

        if RunFireHooks(player, hl, HL.Hooks.OnPrimaryUse) then
            return 
        end

        HL.FireWeapon(player, hl.CurrentWeapon, hl.CurrentWeapon.PrimaryFire)
        HL.PlayFireSound(player.mo, hl.CurrentWeapon.PrimaryFire.Fire)
        HL.SetAnimation(player, HL.AnimationType.Primary)
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
        DeductPlayerAmmo(hl, hl.CurrentWeapon.SecondaryFire)

        if RunFireHooks(player, hl, HL.Hooks.OnSecondaryUse) then
            return 
        end

        HL.FireWeapon(player, hl.CurrentWeapon, hl.CurrentWeapon.SecondaryFire)
        HL.PlayFireSound(player.mo, hl.CurrentWeapon.SecondaryFire.Fire)
        HL.SetAnimation(player, HL.AnimationType.Secondary)
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
    end

    if hl.CurrentWeapon.PrimaryFire.CurrentClipSize == 0 and hl.CurrentWeapon.PrimaryFire.ClipSize ~= HL.DoesNotReload then
        local to_add = min(
            hl.CurrentWeapon.PrimaryFire.ClipSize - hl.CurrentWeapon.PrimaryFire.CurrentClipSize, 
            hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType])

        hl.CurrentWeapon.PrimaryFire.CurrentClipSize = $ + to_add
        hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] = $ - to_add
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