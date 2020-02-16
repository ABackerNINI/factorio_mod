require('config')

data:extend(
    {
        {
            type = 'logistic-container',
            name = g_names.requester_chest_1_1,
            logistic_mode = 'requester',
            logistic_slots_count = g_startup_settings.rc_logistic_slots_count,
            render_not_in_network_icon = false,
            icon = LC_PATH .. '/graphics/icons/requester-chest.png',
            icon_size = 32,
            inventory_size = 48,
            max_health = 350,
            flags = {'placeable-neutral', 'placeable-player', 'player-creation'},
            minable = {hardness = 0.5, mining_time = 1, result = g_names.requester_chest_1_1},
            fast_replaceable_group = 'container',
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            open_sound = {filename = '__base__/sound/metallic-chest-open.ogg'},
            close_sound = {filename = '__base__/sound/metallic-chest-close.ogg'},
            vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.5},
            picture = {
                filename = LC_PATH .. '/graphics/entity/requester-chest.png',
                priority = 'extra-high',
                width = 48,
                height = 34,
                shift = {0.1875, 0}
            },
            circuit_wire_connection_point = {
                shadow = {
                    red = {0.734375, 0.453125},
                    green = {0.609375, 0.515625}
                },
                wire = {
                    red = {0.40625, 0.21875},
                    green = {0.40625, 0.375}
                }
            },
            circuit_wire_max_distance = 9,
            localised_description = {'item-description.ab-lc-requester-chest'}
        }
    }
)

data:extend(
    {
        {
            type = 'recipe',
            name = g_names.requester_chest_1_1,
            enabled = true,
            energy_required = 1,
            ingredients = {
                {'steel-plate', 10},
                {'copper-plate', 20}
            },
            result = g_names.requester_chest_1_1
        }
    }
)

data:extend(
    {
        {
            type = 'item',
            name = g_names.requester_chest_1_1,
            stack_size = 50,
            icon = LC_PATH .. '/graphics/icons/requester-chest.png',
            icon_size = 32,
            -- flags = {"goes-to-quickbar"},
            subgroup = 'logistics',
            order = 'l[a]',
            place_result = g_names.requester_chest_1_1
        }
    }
)
