require("config")
local config = get_config()
local names = get_names()

-- function findStations(show, reset)
--     local surface = game.surfaces['nauvis']

--     if show then
--         debugDump("Searching stations..",true)
--     end
--     if reset then
--         for force, _ in pairs(game.forces) do
--         global.station_count[force] = {}
--         end
--     end
--     local count = 0
--     for _, station in pairs(surface.find_entities_filtered{type="train-stop"}) do
--         count = count + 1
--         increaseStationCount(station)
--     end

--     if show then
--         debugDump("Found "..count.." stations", true)
--     end
-- end
  
-- function findTrains(show)
--     local surface = game.surfaces['nauvis']

--     if show then
--         debugDump("Searching trains..",true)
--     end
--     local trains = surface.get_trains()
--     for _, train in pairs(trains) do
--         if not TrainList.get_traininfo(train.carriages[1].force, train) then
--         local trainInfo = TrainList.add_train(train)
--         if train.state == defines.train_state.wait_station then
--             TickTable.insert(game.tick+update_rate,"updateTrains",trainInfo)
--         end
--         end
--     end
--     TrainList.reset_manual()
--     if show then
--         debugDump("Found "..TrainList.count().." trains",true)
--     end
--     findStations(show)
-- end

local function find_trains()

end

--global data migrations
--call only in script.on_configuration_changed()
function global_data_migrations()
    --first change,global.global_data_version = nil
    --
    -- if global.global_data_version < 2 then
    --     game.print({config.locale_print_when_global_data_migrate,1})

    --     --set global_data_version
    --     global.global_data_version = 2
    -- end

    global.global_data_version = config.global_data_version
end