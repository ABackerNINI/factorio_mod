require("config")

local function check_peaceful_mode()
    --peaceful mode
    -- game.print("peaceful mode")
    local peaceful_mode = settings.global["ab-mapsettings-peaceful-mode"].value
    if peaceful_mode == "true" then
        if game.surfaces[1].peaceful_mode == false then
            game.surfaces[1].peaceful_mode = true
            game.print("set peaceful_mode to true")
        end
    elseif peaceful_mode == "false" then
        if game.surfaces[1].peaceful_mode == true then
            game.surfaces[1].peaceful_mode = false
            game.print("set peaceful_mode to false")
        end
    end
end

local function check_player_color()
    --player color
    -- game.print("player color")
    local r,g,b
    for k,player in pairs(game.players) do
        local ps = settings.get_player_settings(player)
        local using_user_define_color = ps["ab-mapsettings-player-color-using-user-defined-color"].value
        local player_color
        if using_user_define_color == true then
            player_color = "user-defined color"
            r = ps["ab-mapsettings-player-color-user-defined-color-r"].value
            g = ps["ab-mapsettings-player-color-user-defined-color-g"].value
            b = ps["ab-mapsettings-player-color-user-defined-color-b"].value
            a = ps["ab-mapsettings-player-color-user-defined-color-a"].value

            player.color = {r=r/255,g=g/255,b=b/255,a=a}
            player.print("set player (".. player.name ..") color to " .. player_color .. "(r=" .. r .. ",g=" .. g .. ",b=" .. b .. ",a=" .. a .. ")")
        else
            player_color = ps["ab-mapsettings-player-color-colors"].value
            if player_color ~= "none" then
                local pc = player_colors[player_color]
                r = pc.r
                g = pc.g
                b = pc.b
                a = pc.a

                player.color = {r=r/255,g=g/255,b=b/255,a=a}
                player.print("set player (".. player.name ..") color to " .. player_color .. "(r=" .. r .. ",g=" .. g .. ",b=" .. b .. ",a=" .. a .. ")")
            end
        end
    end
end

--on player created
script.on_event(defines.events.on_player_created, function(event)
    check_peaceful_mode()
    check_player_color()
end)

--on player joined game
script.on_event(defines.events.on_player_joined_game, function(event)
    check_player_color()
end)

--runtime mod setting changed
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    check_peaceful_mode()
    check_player_color()
end)
