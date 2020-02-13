local LC = '__ab_logisticscenter__'

require('config')

local config = g_config
local names = g_names
local startup_settings = g_startup_settings

local hsl = 1.5
local hcl = 1.4

data:extend(
    {
        {
            type = 'electric-energy-interface',
            name = names.electric_energy_interface,
            icon = LC .. '/graphics/icons/logistics-center.png',
            icon_size = 32,
            flags = {'not-on-map'},
            selectable_in_game = false,
            selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            energy_source = {
                type = 'electric',
                usage_priority = 'secondary-input',
                input_flow_limit = config.eei_input_flow_limit .. 'W',
                buffer_capacity = config.eei_buffer_capacity .. 'J'
            },
            energy_usage = startup_settings.lc_power_consumption .. 'KW',
            energy_production = '0MW'
        }
    }
)
