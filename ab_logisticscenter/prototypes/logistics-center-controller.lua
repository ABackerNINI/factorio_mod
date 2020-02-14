require('config')

local hsl = 0.5
local hcl = 0.4

local function make_sprite()
    return {
        filename = LC_PATH .. '/graphics/entity/logistics-center-controller.png',
        width = 128,
        height = 128,
        frame_count = 1,
        scale = 0.25,
        shift = {0, 0}
    }
end

data:extend(
    {
        {
            type = 'constant-combinator',
            name = g_names.logistics_center_controller,
            icon = LC_PATH .. '/graphics/icons/logistics-center-controller.png',
            icon_size = 32,
            flags = {'placeable-neutral', 'placeable-player', 'player-creation'},
            minable = {hardness = 1, mining_time = 3, result = g_names.logistics_center_controller},
            selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            max_health = 250,
            corpse = 'small-remnants',
            dying_explosion = 'medium-explosion',
            item_slot_count = g_startup_settings.lc_item_slot_count,
            map_color = {r = 0, g = 1, b = 0},
            sprites = {
                north = make_sprite(),
                east = make_sprite(),
                south = make_sprite(),
                west = make_sprite()
            },
            activity_led_sprites = {
                north = {
                    filename = '__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png',
                    width = 8,
                    height = 6,
                    frame_count = 1,
                    shift = util.by_pixel(9, -12)
                },
                east = {
                    filename = '__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png',
                    width = 8,
                    height = 8,
                    frame_count = 1,
                    shift = util.by_pixel(8, 0)
                },
                south = {
                    filename = '__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png',
                    width = 8,
                    height = 8,
                    frame_count = 1,
                    shift = util.by_pixel(-9, 2)
                },
                west = {
                    filename = '__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png',
                    width = 8,
                    height = 8,
                    frame_count = 1,
                    shift = util.by_pixel(-7, -15)
                }
            },
            activity_led_light = {
                intensity = 0,
                size = 1
            },
            activity_led_light_offsets = {
                {0.296875, -0.40625},
                {0.25, -0.03125},
                {-0.296875, -0.078125},
                {-0.21875, -0.46875}
            },
            circuit_wire_connection_points = {
                {
                    shadow = {
                        red = {0.15625, -0.28125},
                        green = {0.65625, -0.25}
                    },
                    wire = {
                        red = {-0.28125, -0.5625},
                        green = {0.21875, -0.5625}
                    }
                },
                {
                    shadow = {
                        red = {0.75, -0.15625},
                        green = {0.75, 0.25}
                    },
                    wire = {
                        red = {0.46875, -0.5},
                        green = {0.46875, -0.09375}
                    }
                },
                {
                    shadow = {
                        red = {0.75, 0.5625},
                        green = {0.21875, 0.5625}
                    },
                    wire = {
                        red = {0.28125, 0.15625},
                        green = {-0.21875, 0.15625}
                    }
                },
                {
                    shadow = {
                        red = {-0.03125, 0.28125},
                        green = {-0.03125, -0.125}
                    },
                    wire = {
                        red = {-0.46875, 0},
                        green = {-0.46875, -0.40625}
                    }
                }
            },
            circuit_wire_max_distance = 10,
            vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.65}
        }
    }
)

data:extend(
    {
        {
            type = 'recipe',
            name = g_names.logistics_center_controller,
            enabled = true,
            energy_required = 1,
            ingredients = {
                {'constant-combinator', 10},
                {'steel-plate', 10},
                {'iron-plate', 10},
                {'copper-plate', 10},
                {'radar', 5}
            },
            result = g_names.logistics_center_controller
        }
    }
)

data:extend(
    {
        {
            type = 'item',
            name = g_names.logistics_center_controller,
            stack_size = 50,
            icon = LC_PATH .. '/graphics/icons/logistics-center-controller.png',
            icon_size = 32,
            -- flags = {"goes-to-quickbar"},
            subgroup = 'logistics',
            order = 'g[l]',
            place_result = g_names.logistics_center_controller
        }
    }
)
