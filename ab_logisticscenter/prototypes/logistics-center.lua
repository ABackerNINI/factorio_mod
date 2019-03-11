local LC = "__ab_logisticscenter__"

require("config")

local names = get_names()
local startup_settings = get_startup_settings()

local hsl = 1.5
local hcl = 1.4

local width = 113
local height = 91

local function make_sprite()
    return {
		filename = LC .. "/graphics/entity/logistics-center.png",
		-- filename = LC .. "/graphics/nothing.png",
		width = width,
		height = height,
		frame_count = 1,
		shift = {0.2, 0.15}
	}
end

data:extend({
    {
        type = "constant-combinator",
        name = names.logistics_center,
        icon = LC .. "/graphics/icons/logistics-center.png",
		icon_size = 32,
		-- tint = {r=0.5,g=0.5,b=1,a=0},
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {hardness = 1, mining_time = 10, result = names.logistics_center},
        selection_box = {{-hsl, -hsl}, {hsl, hsl}},
        collision_box = {{-hcl, -hcl}, {hcl, hcl}},
        max_health = 250,
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        item_slot_count = startup_settings.lc_item_slot_count,
        map_color = {r = 0, g = 1, b = 0},
        sprites = {
			north = make_sprite(),
			east = make_sprite(),
			south = make_sprite(),
			west = make_sprite()
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
        --flags = {"goes-to-quickbar"},
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
    