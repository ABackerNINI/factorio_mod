local OLC = "__ab_logisticscenter__"

require("config")

local entity_names = get_entity_names()
local config = get_config()

data:extend({
    {
        type = "logistic-container",
        name = entity_names.requester_chest,

        logistic_mode = "requester",
        logistic_slots_count = config.rc_logistic_slots_count,
        render_not_in_network_icon = false,

        icon = OLC .. "/graphics/icons/requester-chest.png",
        icon_size = 32,
        inventory_size = 48,
        max_health = 350,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {hardness = 0.5, mining_time = 1, result = entity_names.requester_chest},
        fast_replaceable_group = "container",
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg" },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg" },
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5 },
        picture = 
        {
			filename = OLC .. "/graphics/entity/requester-chest.png",
			priority = "extra-high",
			width = 48,
			height = 34,
			shift = {0.1875, 0}
        },
        circuit_wire_connection_point =
        {
            shadow =
            {
                red = {0.734375, 0.453125},
                green = {0.609375, 0.515625},
            },
            wire =
            {
                red = {0.40625, 0.21875},
                green = {0.40625, 0.375},
            }
        },
        circuit_wire_max_distance = 9
    }
})

data:extend({
    {
        type = "recipe",
        name = entity_names.requester_chest,
        enabled = true,
        energy_required = 1,
        ingredients = {},
        result = entity_names.requester_chest
    }
})

data:extend({
    {
        type = "item",
        name = entity_names.requester_chest,
        stack_size = 50,
        icon = OLC .. "/graphics/icons/requester-chest.png",
        icon_size = 32,
        flags = {"goes-to-quickbar"},
        subgroup = "logistics",
        order = "l[a]",
        place_result = entity_names.requester_chest,
    }
})
    