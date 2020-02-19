require('config')

local hsl = 1.5
local hcl = 1.4

data:extend(
    {
        {
            type = 'electric-energy-interface',
            name = g_names.electric_energy_interface,
            icon = LC_PATH .. '/graphics/icons/logistics-center.png',
            icon_size = 32,
            flags = {'not-on-map'},
            -- render_layer = 'higher-object-under', ---'entity-info-icon',
            selectable_in_game = false,
            selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            energy_source = {
                type = 'electric',
                usage_priority = 'secondary-input',
                input_flow_limit = g_startup_settings.lc_input_flow_limit + (g_startup_settings.lc_power_consumption / 1000) .. 'MW',
                buffer_capacity = g_startup_settings.lc_buffer_capacity .. 'MJ'
            },
            energy_usage = g_startup_settings.lc_power_consumption .. 'KW',
            energy_production = '0MW'
            -- animation = {
            --     filename = LC_PATH .. '/graphics/entity/logistics-center.png',
            --     priority = 'high',
            --     width = 113,
            --     height = 91,
            --     frame_count = 33,
            --     line_length = 11,
            --     animation_speed = 1 / 5,
            --     shift = {0.2, 0.15}
            -- },
            -- continuous_animation = true
        }
    }
)
