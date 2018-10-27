require("config")
require("utilities")

local config = get_config()
local names = get_names()

script.on_init(function()
    init_globals()

    init_utilities()
end)

--call on ever save and load
script.on_load(function()
    init_utilities()
end)

script.on_configuration_changed(function(config_changed_data)
    -- init_utilities()

    migrations_during_alpha()
end)

--on built
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity

    if entity.name == names.collecter_chest then
        Cc:on_built(entity)
    elseif entity.name == names.requester_chest then
        Rc:on_built(entity)
    elseif entity.name == names.logistics_center then
        Lc:on_built(entity)
    end
end)

--on pre-mined-item/entity-died
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
    local entity = event.entity

    if entity.name == names.collecter_chest then
        Cc:on_destroyed(entity)
    elseif entity.name == names.requester_chest then
        Rc:on_destroyed(entity)
    elseif entity.name == names.logistics_center then
        Lc:on_destroyed(entity)
    end
end)

--check all collecter chests
script.on_nth_tick(config.check_cc_on_nth_tick, function(nth_tick_event)
    Cc:check()
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    Rc:check()
end)

-- script.on_nth_tick(config.update_all_signals_on_nth_tick,function(nth_tick_event)
--     --?
--     Stock:update_all_signals()
-- end)

script.on_event(defines.events.on_research_finished, function(event)
    local research = event.research
    if research.name == names.tech_lc_capacity then
        game.print(research.level)
    end
end)