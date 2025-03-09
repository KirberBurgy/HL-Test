---@param player player_t
---@param camera camera_t
addHook("HUD", function(drawer, player, camera)
    if not (player and player.mo and player.HL and not camera.chase) then
        hud.enable("score")
        hud.enable("time")
        hud.enable("rings")
        return
    end

    hud.disable("score")
    hud.disable("time")
    hud.disable("rings")
    ---@class hlplayer_t
    local hl = player.HL
    local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_40TRANS

    if hl.CurrentWeapon then
        drawer.drawString(100, 100, hl.CurrentWeapon.Name, flags)

        if hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType] ~= nil then
            drawer.drawString(200, 160, "Ammo: " .. hl.Inventory.Ammo[hl.CurrentWeapon.PrimaryFire.AmmoType], V_SNAPTOBOTTOM | V_SNAPTORIGHT)
        end

        if hl.CurrentWeapon.PrimaryFire.Reload then
            drawer.drawString(200, 180, "Clip: " .. hl.CurrentWeapon.PrimaryFire.Reload.CurrentClip, V_SNAPTOBOTTOM | V_SNAPTORIGHT)
        end
    end

    if not hl.WeaponPalette then
        return
    end

    if not hl.WeaponPalette.Open then
        return
    end


    -- Draw boxes from 1-n detailing weapon classes
    for i = 1, #hl.Inventory.Weapons do
        local x_offset = (i - 1) * 22 + 2
        local y_offset = 2

        local color = 56 

        if i > hl.WeaponPalette.Class then
            x_offset = $ + 66
        end

        drawer.drawFill(x_offset, y_offset, 20, 20, color | flags)
        drawer.drawString(x_offset, y_offset, tostring(i), flags)

        for j = 1, #hl.Inventory.Weapons[i] do
            local y2_offset = y_offset + j * 22

            drawer.drawFill(x_offset, y2_offset, i == hl.WeaponPalette.Class and 86 or 20, 20, color | flags)

            if i == hl.WeaponPalette.Class then
                drawer.drawString(x_offset, y2_offset + 2, hl.Inventory.Weapons[i][j].Name, (j ~= hl.WeaponPalette.Item and flags or V_SNAPTOLEFT | V_SNAPTOTOP))
            end
        end
    end

end, "game")

---@param player player_t
addHook("HL_FreemanThinker", function(player)
    if not player.HL then 
        return
    end

    ---@class hlplayer_t
    local hl = player.HL

    hl.WeaponPalette = $ or {
        Open = false,
        Item = 1,
        Class = 1,
        CloseTimer = 0
    }

    if (player.cmd.buttons & BT_WEAPONNEXT) then
        if not hl.WeaponPalette.Open then
            hl.WeaponPalette.Open = true
        else

            if hl.WeaponPalette.Item == #hl.Inventory.Weapons[hl.WeaponPalette.Class] then
                repeat
                    hl.WeaponPalette.Class = $ % #hl.Inventory.Weapons + 1

                -- Skip empty weapon classes
                until hl.Inventory.Weapons[hl.WeaponPalette.Class] and #hl.Inventory.Weapons[hl.WeaponPalette.Class] > 0

                hl.WeaponPalette.Item = 1
            else 
                hl.WeaponPalette.Item = $ + 1
            end
        end

        hl.WeaponPalette.CloseTimer = 3 * TICRATE
    end

    if (player.cmd.buttons & BT_ATTACK and hl.WeaponPalette.Open) then
        local weapon = hl.Inventory.Weapons[hl.WeaponPalette.Class][hl.WeaponPalette.Item]

        hl.WeaponPalette.Open = false
        hl.WeaponPalette.Item = 1
        hl.WeaponPalette.Class = 1
        hl.WeaponPalette.CloseTimer = 0

        if weapon == hl.CurrentWeapon then
            return
        end

        hl.CurrentWeapon = weapon

        for _, hook in ipairs(HL.Hooks.OnEquip) do
            if not hook.Extra or hook.Extra == hl.CurrentWeapon.Name then
                hook.Callback(player, hl.CurrentWeapon)
            end
        end
    end

    if hl.WeaponPalette.CloseTimer > 0 then
        hl.WeaponPalette.CloseTimer = $ - 1
    end

    if hl.WeaponPalette.Open and hl.WeaponPalette.CloseTimer == 0 then
        hl.WeaponPalette.Open = false
        hl.WeaponPalette.Item = 1
        hl.WeaponPalette.Class = 1
        hl.WeaponPalette.CloseTimer = 0
    end
end)