require('config')
require('updates')
require('logistics_center.init_globals')

require('logistics_center.event_handler.check_collector_chest')
-- require('logistics_center.event_handler.check_player_request')
require('logistics_center.event_handler.check_requester_chest')

require('logistics_center.event_handler.on_built')
require('logistics_center.event_handler.on_configuration_changed')
require('logistics_center.event_handler.on_gui_closed')
require('logistics_center.event_handler.on_gui_opened')
require('logistics_center.event_handler.on_mined_or_died')
require('logistics_center.event_handler.on_player_created')
require('logistics_center.event_handler.on_research_finished')

local config = g_config
local names = g_names
local startup_settings = g_startup_settings

local check_ccs_on_nth_tick_all = check_ccs_on_nth_tick_all
local check_ccs_on_nth_tick_ores_only = check_ccs_on_nth_tick_ores_only
local check_ccs_on_nth_tick_except_ores = check_ccs_on_nth_tick_except_ores
-- local check_player_request = check_player_request
local check_requester_chest = check_requester_chest

local on_built = on_built
local on_configuration_changed = on_configuration_changed
local on_gui_closed = on_gui_closed
local on_gui_opened = on_gui_opened
local on_mined_or_died = on_mined_or_died
local on_player_created = on_player_created
local on_research_finished = on_research_finished

script.on_init(
    function()
        init_globals()
    end
)

-- will be called on every save and load
-- script.on_load(
--     function()
--     end
-- )

-- on configuration changed
script.on_configuration_changed(on_configuartion_changed)

-- on built
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, on_built)

-- on pre-mined-item/entity-died
script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, on_mined_or_died)

-- check all collecter chests
if startup_settings.item_type_limitation == nil or startup_settings.item_type_limitation == 'all' then
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_all)
elseif startup_settings.item_type_limitation == 'ores only' then
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_ores_only)
else
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_except_ores)
end

-- check all requester chests
script.on_nth_tick(startup_settings.check_rc_on_nth_tick, check_rcs_on_nth_tick)

-- on opened the logistics center
script.on_event(defines.events.on_gui_opened, on_gui_opened)

-- on closed the `logistics center` and `logistics center controller`
script.on_event(defines.events.on_gui_closed, on_gui_closed)

-- commands.add_command("abc()",{"update all signals"},function(event)
--     update_all_signals()
-- end)

-- on player created
script.on_event(defines.events.on_player_created, on_player_created)

-- on research finished
script.on_event(defines.events.on_research_finished, on_research_finished)
