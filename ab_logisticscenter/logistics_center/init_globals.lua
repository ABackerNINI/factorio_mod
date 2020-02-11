require('config')

local config = g_config
local startup_settings = g_startup_settings

-- INIT FUNCTIONS
-- init globals
-- Call on mod init. should call it only once
function init_globals()
    global.global_data_version = config.global_data_version

    -- {index, items = {["item_name"] = {index, stock, enable, max_control}}}
    global.items_stock =
        global.items_stock or
        {
            index = 1,
            items = {}
        }

    -- {count, entities = {["pos_str"] = {lc, eei}}}
    global.lc_entities =
        global.lc_entities or
        {
            count = 0,
            entities = {}
        }

    -- {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}
    global.cc_entities =
        global.cc_entities or
        {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

    -- {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}
    global.rc_entities =
        global.rc_entities or
        {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

    -- {count, parameters, entities = {[index] = entity}
    global.lcc_entity =
        global.lcc_entity or
        {
            count = 0,
            parameters = nil,
            entities = {}
        }

    global.technologies =
        global.technologies or
        {
            lc_capacity = config.default_lc_capacity,
            cc_power_consumption = startup_settings.default_cc_power_consumption,
            rc_power_consumption = startup_settings.default_rc_power_consumption,
            power_consumption_percentage = 1,
            tech_lc_capacity_real_level = 0,
            tech_power_consumption_real_level = 0
        }

    global.runtime_vars =
        global.runtime_vars or
        {
            cc_check_per_round = 0,
            cc_checked_index = 0,
            rc_check_per_round = 0,
            rc_checked_index = 0
        }
end