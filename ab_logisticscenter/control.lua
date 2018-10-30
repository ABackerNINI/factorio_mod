require("config")
require("updates")

local config = get_config()
local names = get_names()

local items_stock = nil
local lc_entities = nil
local cc_entities = nil
local rc_entities = nil
local technologies = nil

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

    --{index,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,eei}}}}
    global.cc_entities = global.cc_entities or {
        index = 1,
        empty_stack = {count = 0,data = {}},
        entities = {}
    } 

    --{index,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,eei}}}}
    global.rc_entities = global.rc_entities or {
        index = 1,
        empty_stack = {count = 0,data = {}},
        entities = {}
    }

    global.technologies = global.technologies or {
        lc_capacity = config.default_lc_capacity,
        cc_power_consumption = config.default_cc_power_consumption,
        rc_power_consumption = config.default_rc_power_consumption,
        tech_lc_capacity_real_level = 0,
        tech_power_consumption_real_level = 0
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
    technologies = global.technologies

    --calc cpr??
    if cc_entities.index ~= nil then
        cc_check_per_round = math_ceil(cc_entities.index * config.check_cc_percentage)
        rc_check_per_round = math_ceil(rc_entities.index * config.check_rc_percentage)
    end
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
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end

local function position_to_string(p)
    return p.x .. "," .. p.y
end

local function remove_cc(index)
    --remove invalid chest
    cc_entities.entities[index] = nil

    --push the index to the stack
    local empty_stack = cc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    --recalc cpr
    cc_check_per_round = math_ceil(cc_entities.index * config.check_cc_percentage)
end

local function remove_rc(index)
    --remove invalid chest
    rc_entities.entities[index] = nil

    --push the index to the stack
    local empty_stack = rc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    --recalc cpr
    rc_check_per_round = math_ceil(rc_entities.index * config.check_rc_percentage)
end

--find nearest lc
local function find_nearest_lc(entity)
    if lc_entities.count == 0 then return nil end

    local eei = nil
    local nearest_distance = 1000000000 --should big enough
    for k,v in pairs(lc_entities.entities) do
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
            ret.power_consumption = math_ceil(nearest_distance * technologies.cc_power_consumption)
        else
            ret.power_consumption = math_ceil(nearest_distance * technologies.rc_power_consumption)
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
    for index,v in pairs(cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_cc(index)
        end
    end

    --recalc rc
    for index,v in pairs(rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_rc(index)
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
        --add cc to the watch-list
        local index = cc_entities.index
        local empty_stack = cc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        cc_entities.entities[index] = {entity = entity,nearest_lc = find_nearest_lc(entity)}

        --show flying text
        if cc_entities.entities[index].nearest_lc ~= nil then
            entity.surface.create_entity{
                name = "flying-text",
                position = {x = entity.position.x, y = entity.position.y - 1}, 
                color = {r = 228/255, g = 236/255, b = 0},
                text = {
                    config.locale_flying_text_when_build_chest, 
                    string.format(
                        "%.1f",
                        calc_distance_between_two_points(entity.position,cc_entities.entities[index].nearest_lc.eei.position)
                    )
                }
            }
        end

        cc_entities.index = cc_entities.index + 1

        --recalc cpr
        cc_check_per_round = math_ceil(cc_entities.index * config.check_cc_percentage)
    elseif name == names.requester_chest then
        --add rc to the watch-list
        local index = rc_entities.index
        local empty_stack = rc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        rc_entities.entities[index] = {entity = entity,nearest_lc = find_nearest_lc(entity)}

        --show flying text
        if rc_entities.entities[index].nearest_lc ~= nil then
            entity.surface.create_entity{
                name = "flying-text",
                position = {x = entity.position.x, y = entity.position.y - 1}, 
                color = {r = 228/255, g = 236/255, b = 0},
                text = {
                    config.locale_flying_text_when_build_chest, 
                    string.format(
                        "%.1f",
                        calc_distance_between_two_points(entity.position,rc_entities.entities[index].nearest_lc.eei.position)
                    )
                }
            }
        end
    
        rc_entities.index = rc_entities.index + 1

        --recalc cpr
        rc_check_per_round = math_ceil(rc_entities.index * config.check_rc_percentage)
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
        -- game.print("pre-mined:"..p_str)

        --destroy the electric energy interface
        lc_entities.entities[p_str].eei.destroy()
        lc_entities.entities[p_str] = nil
    
        --recalc distance
        recalc_distance()
    end
end)

--check all collecter chests
script.on_nth_tick(config.check_cc_on_nth_tick, function(nth_tick_event)
    if lc_entities.count < 1 then return end

    local index_begin = cc_checked_index + 1
    local index_end = index_begin + cc_check_per_round

    --check(index_begin,index_end)
    for idx = index_begin,index_end,1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        local index = idx
        if index > cc_entities.index then index = index - cc_entities.index end
        local v = cc_entities.entities[index]
        if v ~= nil then 
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = v.nearest_lc.power_consumption
                    local contents = inventory.get_contents()
                    local eei = v.nearest_lc.eei

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
                        count = math.min(count,technologies.lc_capacity - item.stock)

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
                remove_cc(index)
            end
        end
    end

    --calc checked_index
    if cc_entities.index ~= 0 then
        cc_checked_index = index_end % cc_entities.index
    else
        cc_checked_index = 0
    end
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if lc_entities.count < 1 then return end

    local index_begin = rc_checked_index + 1
    local index_end = index_begin + rc_check_per_round

    --check(index_begin,index_end)
    for idx = index_begin,index_end,1 do
        -- game.print("rc:"..index_begin.." "..index_end)
        local index = idx
        if index > rc_entities.index then index = index - rc_entities.index end
        local v = rc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                local eei = v.nearest_lc.eei
                local power_consumption = v.nearest_lc.power_consumption

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
                remove_rc(index)
            end
        end
    end

    --calc checked_index
    if rc_entities.index ~= 0 then
        rc_checked_index = index_end % rc_entities.index
    else
        rc_checked_index = 0
    end
end)

local function update_all_signals()
    --pack all the signals
    local signals = {}
    local index = 1
    for item_name,_ in pairs(items_stock.items) do
        local signal = nil
        local item = items_stock.items[item_name]
        if item.index < config.lc_item_slot_count then
            if item.stock > 0 then
                signal = {signal = {type = "item",name = item_name},count = item.stock,index = item.index}
            end
        end
        signals[index] = signal
        index = index + 1
    end
   
    --TODO if item.index > config.lc_item_slot_count

    --set the signals to the lc(s) which control_behavior are enabled
    local parameters = {parameters = signals}
    for _,v in pairs(lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.parameters = parameters
        end
    end
end

--on open the lc
script.on_event(defines.events.on_gui_opened,function(event)
    local entity = event.entity

    if entity ~= nil and entity.name == names.logistics_center then
        update_all_signals()
    end
end)

-- commands.add_command("abc()",{"update all signals"},function(event)
--     update_all_signals()
-- end)

local tech_lc_capacity_names = {}
for i = 1,4 do
    tech_lc_capacity_names[i] = names.tech_lc_capacity .. "-" .. (i * 10 - 9)
end

local tech_lc_capacity_increment_sum = {}--config.default_lc_capacity,200000,500000,1000000
tech_lc_capacity_increment_sum[1] = 0
for i = 2,4 do
    tech_lc_capacity_increment_sum[i] = tech_lc_capacity_increment_sum[i-1] + config.tech_lc_capacity_increment[i-1] * 10
end

local tech_power_consumption_names = {}
for i = 1,4 do
    tech_power_consumption_names[i] = names.tech_power_consumption .. "-" .. (i * 10 - 9)
end

local tech_power_consumption_decrement_sum = {}--{0,0.015,0.030,0.045}
tech_power_consumption_decrement_sum[1] = 0
for i = 2,4 do
    tech_power_consumption_decrement_sum[i] = tech_power_consumption_decrement_sum[i-1] + config.tech_power_consumption_decrement[i-1] * 10
end

--on research finished
script.on_event(defines.events.on_research_finished, function(event)
    local research = event.research

    if string.match(research.name,names.tech_lc_capacity_pattern) ~= nil then
        for i = 1,4 do
            if research.name == tech_lc_capacity_names[i] then
                technologies.tech_lc_capacity_real_level =  technologies.tech_lc_capacity_real_level + 1
                technologies.lc_capacity = 
                    config.default_lc_capacity + tech_lc_capacity_increment_sum[i] + 
                    config.tech_lc_capacity_increment[i] * (technologies.tech_lc_capacity_real_level - (i - 1) * 10)

                -- game.print(technologies.tech_lc_capacity_real_level)
                game.print({"ab-logisticscenter-text.print-after-tech-lc-capacity-researched",technologies.lc_capacity})

                break
            end
        end
    elseif string.match(research.name,names.tech_power_consumption_pattern) ~= nil then
        for i = 1,4 do
            if research.name == tech_power_consumption_names[i] then
                technologies.tech_power_consumption_real_level = technologies.tech_power_consumption_real_level + 1
                local power_consumption_percentage = 1 - 
                    (tech_power_consumption_decrement_sum[i] + 
                     config.tech_power_consumption_decrement[i] * (technologies.tech_power_consumption_real_level - (i - 1) * 10))

                technologies.cc_power_consumption = 
                    math_ceil(config.default_cc_power_consumption * power_consumption_percentage)
                technologies.rc_power_consumption = 
                    math_ceil(config.default_rc_power_consumption * power_consumption_percentage)

                game.print(
                    {
                        "ab-logisticscenter-text.print-after-tech-power-consumption-researched",
                        technologies.cc_power_consumption,
                        technologies.rc_power_consumption
                    }
                )

                break
            end
        end

        --recalc distance
        recalc_distance()
    end
end)
