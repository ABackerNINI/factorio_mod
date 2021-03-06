require('config')
require('logistics_center.init_globals')

require('logistics_center.event_handler.check_collector_chest')
-- require('logistics_center.event_handler.check_player_request')
require('logistics_center.event_handler.check_requester_chest')

require('logistics_center.event_handler.on_built')
require('logistics_center.event_handler.on_configuration_changed')
require('logistics_center.event_handler.on_gui_closed')
require('logistics_center.event_handler.on_gui_opened')
require('logistics_center.event_handler.on_load')
require('logistics_center.event_handler.on_destroy')
require('logistics_center.event_handler.on_player_created')
require('logistics_center.event_handler.on_research_finished')
require('logistics_center.event_handler.on_rotated')
require('logistics_center.event_handler.on_runtime_mod_setting_changed')

local check_ccs_on_nth_tick_all = check_ccs_on_nth_tick_all
local check_ccs_on_nth_tick_ores_only = check_ccs_on_nth_tick_ores_only
local check_ccs_on_nth_tick_except_ores = check_ccs_on_nth_tick_except_ores
-- local check_player_request = check_player_request
local check_rcs_on_nth_tick = check_rcs_on_nth_tick

local on_built = on_built
local on_configuration_changed = on_configuration_changed
local on_gui_closed = on_gui_closed
local on_gui_opened = on_gui_opened
local on_load = on_load
local on_destroy = on_destroy
local on_player_created = on_player_created
local on_research_finished = on_research_finished
local on_rotated = on_rotated
local on_runtime_mod_setting_changed = on_runtime_mod_setting_changed

script.on_init(init_globals)

-- will be called on every save and load
script.on_load(on_load)

-- on configuration changed
script.on_configuration_changed(on_configuration_changed)

-- on built
script.on_event(
    {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity
    },
    on_built
)
script.on_event(
    {
        defines.events.script_raised_built,
        defines.events.script_raised_revive
    },
    function(event)
        local transfer_event = {created_entity = event.entity}
        on_built(transfer_event)
    end
)

-- on pre-mined-item/entity-died
script.on_event(
    {
        defines.events.on_pre_player_mined_item, -- on_player_mined_entity
        defines.events.on_robot_pre_mined,
        defines.events.on_entity_died,
        defines.events.script_raised_destroy -- seems duplicated with the above events
    },
    on_destroy
)

-- check all collector chests
if g_startup_settings.item_type_limitation == nil or g_startup_settings.item_type_limitation == 'all' then
    script.on_nth_tick(g_startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_all)
elseif g_startup_settings.item_type_limitation == 'ores only' then
    script.on_nth_tick(g_startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_ores_only)
else
    script.on_nth_tick(g_startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_except_ores)
end

-- check all requester chests
script.on_nth_tick(g_startup_settings.check_rc_on_nth_tick, check_rcs_on_nth_tick)

script.on_event(defines.events.on_player_rotated_entity, on_rotated)

-- on opened the logistics center
script.on_event(defines.events.on_gui_opened, on_gui_opened)

-- on closed the `logistics center` and `logistics center controller`
script.on_event(defines.events.on_gui_closed, on_gui_closed)

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)

-- commands.add_command("abc()",{"update all signals"},function(event)
--     update_all_signals()
-- end)

-- on player created
script.on_event(defines.events.on_player_created, on_player_created)

-- on research finished
script.on_event(defines.events.on_research_finished, on_research_finished)
