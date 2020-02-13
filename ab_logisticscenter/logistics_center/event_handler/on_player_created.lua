local names = g_names
local config = g_config
local startup_settings = g_startup_settings

function on_player_created(event)
    local player = game.players[event.player_index]
    local quick_start = startup_settings.quick_start

    player.print{config.locale_print_when_first_init}

    if quick_start == nil then
        quick_start = 1
    end

    if quick_start > 0 then
        local items = {
            {names.logistics_center, quick_start},
            {names.collecter_chest_1_1, 50},
            {names.requester_chest_1_1, 50}
        }

        local inventory = player.get_main_inventory() -- get_inventory(defines.inventory.character_main)
        if inventory ~= nil then
            for k, v in pairs(items) do
                inventory.insert({name = v[1], count = v[2]})
            end
        end
    end
end
