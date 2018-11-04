local LC = "__ab_logisticscenter__"

require("config")

local names = get_names()
local config = get_config()

local half_selection_length = 1.5
local half_collision_len = 1.4
local width = 113
local height = 91

data:extend({
    {
        type = "constant-combinator",
        name = names.logistics_center,
        icon = LC .. "/graphics/icons/logistics-center.png",
        icon_size = 32,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {hardness = 1, mining_time = 10, result = names.logistics_center},
        collision_box = {{-half_collision_len, -half_collision_len}, {half_collision_len, half_collision_len}},
        selection_box = {{-half_selection_length, -half_selection_length}, {half_selection_length, half_selection_length}},
        max_health = 250,
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        item_slot_count = config.lc_item_slot_count,
        sprites = {
			north = {
                filename = LC .. "/graphics/entity/logistics-center.png",
				width = width,
				height = height,
				frame_count = 1,
				shift = {0.2, 0.15}
			},
			east = {
                filename = LC .. "/graphics/entity/logistics-center.png",
				width = width,
				height = height,
				frame_count = 1,
				shift = {0.2, 0.15}
			},
			south = {
                filename = LC .. "/graphics/entity/logistics-center.png",
				width = width,
				height = height,
				frame_count = 1,
				shift = {0.2, 0.15}
			},
			west = {
                filename = LC .. "/graphics/entity/logistics-center.png",
				width = width,
				height = height,
				frame_count = 1,
				shift = {0.2, 0.15}
			}
		},

		activity_led_sprites = {
			north = {
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
				width = 8,
				height = 6,
				frame_count = 1,
				shift = util.by_pixel(9, -12)
			},
			east = {
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = util.by_pixel(8, 0)
			},
			south = {
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = util.by_pixel(-9, 2)
			},
			west = {
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = util.by_pixel(-7, -15)
			}
		},

		activity_led_light = {
			intensity = 0,
			size = 1,
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
					green = {0.21875, -0.5625},
				}
			},
			{
				shadow = {
					red = {0.75, -0.15625},
					green = {0.75, 0.25},
				},
				wire = {
					red = {0.46875, -0.5},
					green = {0.46875, -0.09375},
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
					green = {-0.03125, -0.125},
				},
				wire = {
					red = {-0.46875, 0},
					green = {-0.46875, -0.40625},
				}
			}
		},
        circuit_wire_max_distance = 10,
        map_color = {r = 0, g = 1, b = 0},
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
    }
})

data:extend({
    {
        type = "recipe",
        name = names.logistics_center,
        enabled = true,
        energy_required = 1,
        ingredients = {
			{"flying-robot-frame",200},
			{"accumulator",20},
			{"advanced-circuit",100},
			{"constant-combinator",20},
			{"steel-plate",100},
			{"iron-plate",100},
			{"copper-plate",100},
			{"radar",10},
		},
        result = names.logistics_center
    }
})

data:extend({
    {
        type = "item",
        name = names.logistics_center,
        stack_size = 5,
        icon = LC .. "/graphics/icons/logistics-center.png",
        icon_size = 32,
        flags = {"goes-to-quickbar"},
        subgroup = "logistics",
        order = "g[l]",
        place_result = names.logistics_center,
    }
})

data:extend(
    {
      {
        type = "recipe-category",
        name = "logistics"
      },
      {
        type = "item-subgroup",
        name = "logistics",
        group = "logistics",
        order = "e-f"
      }
    }
)
    