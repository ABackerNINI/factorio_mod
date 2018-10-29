require("config")
local config = get_config()
local names = get_names()

local function calc_distance_between_two_points(p1,p2)
    local dx = math.abs(p1.x-p2.x)
    local dy = math.abs(p1.y-p2.y)
    return math.sqrt(dx*dx+dy*dy)
end

local function position_to_string(p)
    return p.x .. "," .. p.y
end

--find nearest lc
local function find_nearest_lc(entity)
    if global.lc_entities.count == 0 then return nil end

    local eei = nil
    local nearest_distance = 1000000000 --should big enough
    for k,v in pairs(global.lc_entities.entities) do
        local distance = calc_distance_between_two_points(entity.position,v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            eei = v.eei
        end
    end

    if eei ~= nil then 
        local ret = {
            power_consumption = 0,
            eei = eei
        }
        if entity.name == names.collecter_chest then
            ret.power_consumption = nearest_distance * config.cc_power_consumption
        else
            ret.power_consumption = nearest_distance * config.rc_power_consumption
        end
        return ret
    else
        game.print("[ab_logisticscenter]:error,didn't find@find_nearest_lc")
        return nil
    end
end

--recalc distance from cc/rc to the nearest lc
--call after lc entity being created or destoried 
local function recalc_distance()
    --recalc cc
    for index,v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        end
    end

    --recalc rc
    for index,v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        end
    end
end

--global data migrations
--call only in script.on_configuration_changed()
function global_data_migrations()
    --first change,global.global_data_version = nil
    if global.global_data_version == nil and global.cc_entities ~= nil and global.cc_entities.index ~= nil then
        game.print("[ab_logisticscenter]:first global data migrations applied.")
        --global.cc_entities
        --OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        --NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local new_cc_entities = {
            count = 0,
            empty_stack = {count = 0,data = {}},
            entities = {}
        }
        local cc_count = 0
        for k,v in pairs(global.cc_entities.entities) do
            cc_count = cc_count + 1
            new_cc_entities.entities[cc_count] = {entity = v.entity,nearest_lc = v.nearest_lc}
        end
        new_cc_entities.count = cc_count
        global.cc_entities = nil
        global.cc_entities = new_cc_entities

        --global.rc_entities
        --OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        --NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local new_rc_entities = {
            count = 0,
            empty_stack = {count = 0,data = {}},
            entities = {}
        }
        local rc_count = 0
        for k,v in pairs(global.rc_entities.entities) do
            rc_count = rc_count + 1
            new_rc_entities.entities[rc_count] = {entity = v.entity,nearest_lc = v.nearest_lc}
        end
        new_rc_entities.count = rc_count
        global.rc_entities = nil
        global.rc_entities = new_rc_entities

        --set global_data_version
        global.global_data_version = 2
    end

    --secend change,global.global_data_version = nil
    if global.global_data_version == nil or global.global_data_version < 3 then
        game.print("[ab_logisticscenter]:secend global data migrations applied.")
        --cc_entities.empty_stack
        --OLD Stack:new{p,data}
        --NEW {count,data}
        local new_cc_es_count = 0
        local new_cc_empty_stack = {count = 0,data = {}}
        for k,v in pairs(global.cc_entities.entities) do
            if v == nil then
                new_cc_es_count = new_cc_es_count + 1
                new_cc_empty_stack.data[new_cc_es_count] = k
            end
        end
        new_cc_empty_stack.count = new_cc_es_count
        global.cc_entities.empty_stack = new_cc_empty_stack

        --rc_entities.empty_stack
        --OLD Stack:new{p,data}
        --NEW {count,data}
        local new_rc_es_count = 0
        local new_rc_empty_stack = {count = 0,data = {}}
        for k,v in pairs(global.rc_entities.entities) do
            if v == nil then
                new_rc_es_count = new_rc_es_count + 1
                new_rc_empty_stack.data[new_rc_es_count] = k
            end
        end
        new_rc_empty_stack.count = new_rc_es_count
        global.rc_entities.empty_stack = new_rc_empty_stack

        --set global_data_version
        global.global_data_version = 3
    end

    --third change,global.global_data_version = nil
    if global.global_data_version == nil or global.global_data_version < 4 then
        game.print("[ab_logisticscenter]:third global data migrations applied.")
        --cc_entities.entities.nearest_lc
        --OLD {distance,lc_pos_str}
        --NEW {power_consumption,lc_pos_str}
        for k,v in pairs(global.cc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * config.cc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption,lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end

        --rc_entities.entities.nearest_lc
        --OLD {distance,lc_pos_str}
        --NEW {power_consumption,lc_pos_str}
        for k,v in pairs(global.rc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * config.rc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption,lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end
    
        --set global_data_version
        global.global_data_version = 4
    end

    --fourth change,global.global_data_version = 4
    if global.global_data_version < 5 then
        game.print("[ab_logisticscenter]:fourth global data migrations applied.")
        --cc_entities.entities.nearest_lc
        --OLD {power_consumption,lc_pos_str}
        --NEW {power_consumption,eei}

        --rc_entities.entities.nearest_lc
        --OLD {power_consumption,lc_pos_str}
        --NEW {power_consumption,eei}

        recalc_distance()

        --set global_data_version
        global.global_data_version = 5
    end

    --fifth change,global.global_data_version = 5
    if global.global_data_version < 6 then
        game.print("[ab_logisticscenter]:fifth global data migrations applied.")
        --cc_entities
        --OLD {count,empty_stack,entities}
        --NEW {index,empty_stack,entities}
        local ordered_cc_entities = {}
        local index = 1
        for _,v in pairs(global.cc_entities.entities) do
            ordered_cc_entities[index] = v
            index = index + 1
        end

        local new_cc_entities = {index = index,empty_stack={count = 0,data = {}},entities=ordered_cc_entities}
        global.cc_entities = new_cc_entities

        --rc_entities
        --OLD {count,empty_stack,entities}
        --NEW {index,empty_stack,entities}
        local ordered_rc_entities = {}
        index = 1
        for _,v in pairs(global.rc_entities.entities) do
            ordered_rc_entities[index] = v
            index = index + 1
        end

        local new_rc_entities = {index = index,empty_stack={count = 0,data = {}},entities=ordered_rc_entities}
        global.rc_entities = new_rc_entities

        --set global_data_version
        global.global_data_version = 6
    end

    global.global_data_version = config.global_data_version
end