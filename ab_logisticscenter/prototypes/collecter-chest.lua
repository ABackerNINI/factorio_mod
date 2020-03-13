require('config')

local function make_prototype(name, icon, inventory_size, max_health, width, height, picture, ingredients)
    local h_width = width / 2
    local h_height = height / 2
    data:extend(
        {
            {
                type = 'container',
                name = name,
                icon = icon,
                icon_size = 32,
                inventory_size = inventory_size,
                max_health = max_health,
                flags = {'placeable-neutral', 'placeable-player', 'player-creation'},
                minable = {hardness = 0.5, mining_time = 1, result = name},
                fast_replaceable_group = 'container',
                selection_box = {{-h_width, -h_height}, {h_width, h_height}},
                collision_box = {{-h_width + 0.1, -h_height + 0.1}, {h_width - 0.1, h_height - 0.1}},
                open_sound = {filename = '__base__/sound/metallic-chest-open.ogg'},
                close_sound = {filename = '__base__/sound/metallic-chest-close.ogg'},
                vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.5},
                picture = picture,
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
                localised_description = {'item-description.ab-lc-collecter-chest'}
            }
        }
    )

    data:extend(
        {
            {
                type = 'recipe',
                name = name,
                enabled = true,
                energy_required = 1,
                ingredients = ingredients,
                result = name
            }
        }
    )

    data:extend(
        {
            {
                type = 'item',
                name = name,
                stack_size = 50,
                icon = icon,
                icon_size = 32,
                -- flags = {"goes-to-quickbar"},
                subgroup = 'logistics',
                order = 'l[a]',
                place_result = name
            }
        }
    )
end

-----------------------------------------------------------------------------------------------------------------

local icon_1_1 = LC_PATH .. '/graphics/icons/collecter-chest.png'
local picture_1_1 = {
    filename = LC_PATH .. '/graphics/entity/collecter-chest.png',
    priority = 'extra-high',
    width = 48,
    height = 34,
    shift = {0.1875, 0}
}
local ingredients_1_1 = {
    {'steel-plate', 10},
    {'copper-plate', 20}
}

-- name,icon,inventory_size,max_health,width,height,picture,ingredients
make_prototype(g_names.collecter_chest_1_1, icon_1_1, 48, 250, 1, 1, picture_1_1, ingredients_1_1)
