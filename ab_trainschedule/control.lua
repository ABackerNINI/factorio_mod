require("config")
require("updates")

local config = get_config()
local names = get_names()

local math_ceil = math.ceil
local math_floor = math.floor
local math_min = math.min
local math_max = math.max

--INIT FUNCTIONS
--init globals
--call on mod init.should call it only once
local function init_globals()
    global.global_data_version = config.global_data_version

    global.trains = global.trains or {
        count = 0,
        entities = {}
    }

    global.stations = global.stations or {
        count = 0,
        entities = {}
    }
end

local function push_back()

end

local function pop_front()

end

script.on_init(function()
    init_globals()
end)

--will be called on every save and load
script.on_load(function()
end)

script.on_configuration_changed(function(config_changed_data)
    global_data_migrations()
end)

--on built
-- script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
--     local entity = event.created_entity
--     local name = entity.name

--     if name == names.

--     elseif name == names.

--     elseif name == names. then
 
--     elseif name == names. then

--     end
-- end)

--on pre-mined-item/entity-died
-- script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
--     local entity = event.entity

--     if entity.name == names. then
     
--     elseif entity.name == names. then
     
--     end
-- end)

local function match_stop_station(station_name)
    
end

local function match_next_station(station_name)

end

--on train changed state
script.on_event(defines.events.on_train_changed_state,function(event)
    -- defines.train_state.arrive_station	Braking before a station.
    -- defines.train_state.wait_station	Waiting at a station.
    local train = event.train
    if train.state == defines.train_state.wait_station then
        local schedule = train.schedule
        local count = #schedule.records
        local record_current = schedule.records[schedule.current]
        local record_next = schedule.records[(schedule.current % count) + 1]
        if record_next.station == "fe" then
            game.print("fff")
        end
    end
end)

--on gui opened
-- script.on_event(defines.events.on_gui_opened,function(event)
--     local entity = event.entity
-- end)

--on gui closed
-- script.on_event(defines.events.on_gui_closed,function(event)
--     local entity = event.entity
-- end)

--on research finished
-- script.on_event(defines.events.on_research_finished, function(event)
--     local research = event.research
-- end)

--on player created
-- script.on_event(defines.events.on_player_created, function(event)
--     local player = game.players[event.player_index]
--     local setting = settings.startup["ab-logistics-center-quick-start"].value
-- end)