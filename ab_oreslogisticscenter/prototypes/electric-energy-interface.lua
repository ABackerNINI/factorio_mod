local OLC = "__ab_oreslogisticscenter__"

require("config")

local entity_names = get_entity_names()
local config = get_config()

data:extend({
    {
        type = "electric-energy-interface",
        name = entity_names.electric_energy_interface,
        icon = OLC .. "/graphics/icons/greenhouse.png",
        icon_size = 32,
        flags = {"not-on-map"},
        minable = nil,
        max_health = 1,
        selectable_in_game = false,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            input_flow_limit = config.electric_energy_interface_input_flow_limit .."W",
            buffer_capacity = config.electric_energy_interface_buffer_capacity .. "J",
        },
        energy_usage = "1MW",
        energy_production = "0MW",
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        collision_mask = {},
    }
})