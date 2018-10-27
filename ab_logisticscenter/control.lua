require("config")

local config = get_config()
local names = get_names()

local items_stock = nil
local lc_entities = nil
local cc_entities = nil
local rc_entities = nil

local cc_check_per_round = 0
local cc_checked_index = 0
local rc_check_per_round = 0
local rc_checked_index = 0

local math_ceil = math.ceil
local math_floor = math.floor
local crc_item_stack = {name = nil,count = 0}

--INIT FUNCTIONS
--init globals
--call on mod init.should call it only once
local function init_globals()
    global.global_data_version = config.global_data_version

    --{index,items = {["item_name"] = {index,stock}}}
    global.items_stock = global.items_stock or {
        index = 1,
        items = {}
    }

    --multi-lc causes a severe bug on energy consumption
    --{count,entities = {["pos_str"] = {lc,eei}}}
    global.lc_entities = global.lc_entities or {
        count = 0,
        entities = {}
    } 

    --{count,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,lc_pos_str}}}}
    global.cc_entities = global.cc_entities or {
        count = 0,
        empty_stack = {count = 0,data = {}},
        entities = {}
    } 

    --{count,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,lc_pos_str}}}}
    global.rc_entities = global.rc_entities or {
        count = 0,
        empty_stack = {count = 0,data = {}},
        entities = {}
    }
end

--init locals
--call this after init_global()/global_data_migrations(),but before using these local vars
--don't alter global values here
local function init_locals()
    --init local ref of global tables
    items_stock = global.items_stock
    lc_entities = global.lc_entities
    cc_entities = global.cc_entities
    rc_entities = global.rc_entities

    --calc cpr
    if cc_entities.count ~= nil then
        cc_check_per_round = math_ceil(cc_entities.count * config.check_cc_percentage)
        rc_check_per_round = math_ceil(rc_entities.count * config.check_rc_percentage)
    end
end

--global data migrations
--call only in script.on_configuration_changed()
local function global_data_migrations()
    --first change,global.global_data_version = nil
    if global.cc_entities ~= nil and global.cc_entities.index ~= nil then
        game.print("first migrations applied.")
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
        game.print("secend migrations applied.")
        --cc_entities.empty_stack
        --OLD Stack:new{p,data}
        --NEW {count,data}
        local new_cc_es_count = 0
        local new_cc_empty_stack = {count = 0,data = {}}
        for k,v in ipairs(global.cc_entities.entities) do
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
        for k,v in ipairs(global.rc_entities.entities) do
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
        game.print("third migrations applied.")
        --cc_entities.entities.nearest_lc
        --OLD {distance,lc_pos_str}
        --NEW {power_consumption,lc_pos_str}
        for k,v in ipairs(global.cc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * config.cc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption,lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end

        --rc_entities.entities.nearest_lc
        --OLD {distance,lc_pos_str}
        --NEW {power_consumption,lc_pos_str}
        for k,v in ipairs(global.rc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * config.rc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption,lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end
    
        --set global_data_version
        global.global_data_version = 4
    end

    -- if global.global_data_version < 5 then
    --     --TODO migrations
    --     --set global_data_version
    --     global.global_data_version = 5
    -- end

    global.global_data_version = config.global_data_version
end

script.on_init(function()
    init_globals()

    init_locals()
end)

--will be called on every save and load
script.on_load(function()
    init_locals()
end)

script.on_configuration_changed(function(config_changed_data)
    global_data_migrations()

    --in case global tables were altered in global_data_migrations()
    --and cc/rc counts may change after migrations
    init_locals()
end)

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
    local nearest_lc_pack = nil
    local nearest_distance = 1000000000 --should big enough
    for _,v in pairs(lc_entities.entities) do
        local distance = calc_distance_between_two_points(entity.position,v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            nearest_lc_pack = v
        end
    end

    if nearest_lc_pack ~= nil then 
        local ret = {
            power_consumption = 0,
            lc_pos_str = position_to_string(nearest_lc_pack.lc.position)
        }
        if entity.name == names.collecter_chest then
            ret.power_consumption = nearest_distance * config.cc_power_consumption
        else
            ret.power_consumption = nearest_distance * config.rc_power_consumption
        end
        return ret
    else
        return nil
    end
end

--recalc distance from cc/rc to the nearest lc
--call after lc entity being created or destoried 
local function recalc_distance()
    --recalc cc
    for index,v in ipairs(cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            --remove invalid chest
            cc_entities.count = cc_entities.count - 1
            cc_entities.entities[index] = nil

            --push the index to the stack
            local empty_stack = cc_entities.empty_stack
            empty_stack.count = empty_stack.count + 1
            empty_stack.data[empty_stack.count] = index
        
            --recalc cpr
            cc_check_per_round = math_ceil(cc_entities.count * config.check_cc_percentage)
        end
    end

    --recalc rc
    for index,v in ipairs(rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            --remove invalid chest
            rc_entities.count = rc_entities.count - 1
            rc_entities.entities[index] = nil

            --push the index to the stack
            local empty_stack = rc_entities.empty_stack
            empty_stack.count = empty_stack.count + 1
            empty_stack.data[empty_stack.count] = index
        
            --recalc cpr
            rc_check_per_round = math_ceil(rc_entities.count * config.check_rc_percentage)
        end
    end
end

local function update_signals(item_name)
    --pack the signal
    local signal = nil
    local item = items_stock.items[item_name]
    if item.index < config.lc_item_slot_count then
        if item.stock > 0 then
            signal = {signal = {type = "item",name = item_name},count = item.stock}
        end
    end

    --TODO if item.index > config.lc_item_slot_count

    --set the signal to the lc(s) which control_behavior are enabled
    for _,v in pairs(lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.set_signal(item.index,signal)
        end
    end
end

--on built
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity
    local name = entity.name

    if name == names.collecter_chest then
        cc_entities.count = cc_entities.count + 1

        --add cc to the watch-list
        local index = cc_entities.count
        local empty_stack = cc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        cc_entities.entities[index] = {entity = entity,nearest_lc = find_nearest_lc(entity)}
    
        --recalc cpr
        cc_check_per_round = math_ceil(cc_entities.count * config.check_cc_percentage)
    elseif name == names.requester_chest then
        rc_entities.count = rc_entities.count + 1

        --add rc to the watch-list
        local index = rc_entities.count
        local empty_stack = rc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        rc_entities.entities[index] = {entity = entity,nearest_lc = find_nearest_lc(entity)}
    
        --recalc cpr
        rc_check_per_round = math_ceil(rc_entities.count * config.check_rc_percentage)
    elseif name == names.logistics_center then
        --disable signal output of the lc on default except the very first one
        --this will cause a problem that signals don't show up immediately after control-behavior enabled
        if lc_entities.count > 0 then 
            entity.get_or_create_control_behavior().enabled = false
        end

        --will confilct when entity on diffrent surfaces?
        lc_entities.entities[position_to_string(entity.position)] = { 
            lc = entity,
            --create the electric energy interface
            eei = entity.surface.create_entity{
                name = names.electric_energy_interface,
                position = entity.position,
                force = entity.force
            }
        }
        lc_entities.count = lc_entities.count + 1
        
        --recalc distance
        recalc_distance()
    end
end)

--on pre-mined-item/entity-died
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
    local entity = event.entity

    --can't get index by entity except using 'for'
    --no need to remove chest here,
    --but should check valid before using entities stored in the watch-list

    -- if entity.name == names.collecter_chest then
    -- elseif entity.name == names.requester_chest then
    -- else
    if entity.name == names.logistics_center then
        lc_entities.count = lc_entities.count - 1
    
        local p_str = position_to_string(entity.position)

        --destroy the electric energy interface
        lc_entities.entities[p_str].eei.destroy()
        lc_entities.entities[p_str] = nil
    
        --recalc distance
        recalc_distance()
    end
end)

--check all collecter chests
script.on_nth_tick(config.check_cc_on_nth_tick, function(nth_tick_event)
    if global.lc_entities.count < 1 then return end

    local index_begin = cc_checked_index + 1
    local index_end = index_begin + cc_check_per_round

    --check(index_begin,index_end)
    for idx = index_begin,index_end,1 do
        -- game.print("cc"..index_begin.." "..index_end)
        local index = idx
        if index > cc_entities.count then index = index - cc_entities.count end
        local v = cc_entities.entities[index]
        if v ~= nil then 
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = v.nearest_lc.power_consumption--config.cc_power_consumption * v.nearest_lc.distance
                    local contents = inventory.get_contents()
                    local eei = lc_entities.entities[v.nearest_lc.lc_pos_str].eei

                    for name,count in pairs(contents) do
                        --stock.get_item(name)
                        local item = items_stock.items[name]
                        if item == nil then
                            item = {index = items_stock.index,stock = 0}
                            items_stock.items[name] = item
                            items_stock.index = items_stock.index + 1
                        end
                        
                        --enough energy?
                        count = math.min(count,math_floor(eei.energy/power_consumption))
                        --enough capacity?
                        count = math.min(count,config.lc_capacity - item.stock)

                        if count > 0 then
                            crc_item_stack.name = name
                            crc_item_stack.count = count
                            inventory.remove(crc_item_stack)
                            item.stock = item.stock + count
                            eei.energy = eei.energy - count * power_consumption
                            update_signals(name)
                        end
                    end
                end
            else
                --remove invalid collecter chest
                cc_entities.count = cc_entities.count - 1
                cc_entities.entities[index] = nil

                --stack.push(index)
                local empty_stack = cc_entities.empty_stack
                empty_stack.count = empty_stack.count + 1
                empty_stack.data[empty_stack.count] = index
            
                --recalc cpr
                cc_check_per_round = math_ceil(cc_entities.count * config.check_cc_percentage)
            end
        end
    end

    if cc_entities.count ~= 0 then
        cc_checked_index = index_end % cc_entities.count
    else
        cc_checked_index = 0
    end
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if global.lc_entities.count < 1 then return end

    local index_begin = rc_checked_index + 1
    local index_end = index_begin + rc_check_per_round

    --check(index_begin,index_end)
    for idx = index_begin,index_end,1 do
        -- game.print("rc"..index_begin.." "..index_end)
        local index = idx
        if index > rc_entities.count then index = index - rc_entities.count end
        local v = rc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                local eei = lc_entities.entities[v.nearest_lc.lc_pos_str].eei
                local power_consumption = v.nearest_lc.power_consumption--config.rc_power_consumption * v.nearest_lc.distance

                for i = 1,config.rc_logistic_slots_count do
                    local request_slot = v.entity.get_request_slot(i)
                    if request_slot ~= nil then
                        local name = request_slot.name
                        local count = request_slot.count

                        --stock.get_item(name)
                        local item = items_stock.items[name]
                        if item == nil then
                            item = {index = items_stock.index,stock = 0}
                            items_stock.items[name] = item
                            items_stock.index = items_stock.index + 1
                        end

                        --calc shortage
                        count = count - inventory.get_item_count(name)
                        --enough stock?
                        count = math.min(count,item.stock)
                        --enough energy?
                        count = math.min(count,math_floor(eei.energy/power_consumption))

                        if count > 0 then
                            crc_item_stack.name = name
                            crc_item_stack.count = count
                            --in case the inventory is full
                            local inserted_count = inventory.insert(crc_item_stack)
                            item.stock = item.stock - inserted_count
                            eei.energy = eei.energy - inserted_count * power_consumption
                            update_signals(name)
                        end
                    end
                end
            else
                --remove invalid requester chest
                rc_entities.count = rc_entities.count - 1
                rc_entities.entities[index] = nil
    
                --stack.push(index)
                local empty_stack = rc_entities.empty_stack
                empty_stack.count = empty_stack.count + 1
                empty_stack.data[empty_stack.count] = index
            
                --recalc cpr
                rc_check_per_round = math_ceil(rc_entities.count * config.check_rc_percentage)
            end
        end
    end

    if rc_entities.count ~= 0 then
        rc_checked_index = index_end % rc_entities.count
    else
        rc_checked_index = 0
    end
end)

local function update_all_signals()
    for k,_ in pairs(item_stock.items) do
        update_signals(k)
    end
end

commands.add_command("ab_logistics_center_update_all_signals",{"update all signals"},function(event)
    update_all_signals()
end)

-- script.on_nth_tick(config.update_all_signals_on_nth_tick,function(nth_tick_event)
--     --?
--     update_all_signals()
-- end)

-- script.on_event(defines.events.on_research_finished, function(event)
    -- local research = event.research
    -- if research.name == names.tech_lc_capacity then
    --     game.print(research.level)
    -- end
-- end)
