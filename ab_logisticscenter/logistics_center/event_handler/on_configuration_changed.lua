require('logistics_center.updates')

local math_ceil = math.ceil
local names = g_names
local startup_settings = g_startup_settings

function on_configuration_changed(config_changed_data)
    global_data_migrations()

    -- in case global tables were altered in global_data_migrations()
    -- and cc/rc counts may change after migrations
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.count * startup_settings.check_cc_percentages)
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.count * startup_settings.check_rc_percentages)

    -- recalc power consumption if configuration changed
    local default_power_consumption_changed = false

    if
        global.technologies.cc_power_consumption ~= math_ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage) or
            global.technologies.rc_power_consumption ~= math_ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)
     then
        default_power_consumption_changed = true
    end

    global.technologies.cc_power_consumption = math_ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage)
    global.technologies.rc_power_consumption = math_ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)

    if default_power_consumption_changed == true then
        game.print(
            {
                names.locale_print_after_power_consumption_configuration_changed,
                global.technologies.cc_power_consumption,
                global.technologies.rc_power_consumption
            }
        )
    end

    -- check if item were removed
    for k, v in pairs(global.items_stock.items) do
        if game.item_prototypes[k] ~= nil then
            v.enable = true
        else
            v.enable = false
        end
    end
end