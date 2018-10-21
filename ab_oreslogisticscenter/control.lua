require("config")

local config = get_config()
local entity_names = get_entity_names()

local function init_globals()
    global.items_stock = global.items_stock or {index = 1,items = {}} -- {index,items = ["item_name"] = {index,stock}}

    global.lc_entities = global.lc_entities or {count = 0,entities = {}} -- {count,entities = {["pos_str"] = {lc,eei,cc_rc_s={1={},2={}}}}}
    global.cc_entities = global.cc_entities or {index = 1,entities = {}} -- {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
    global.rc_entities = global.rc_entities or {index = 1,entities = {}} -- {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
end

local function add_new_item(item_name)
    global.items_stock.items[item_name] = {index = global.items_stock.index,stock = 0}
    global.items_stock.index = global.items_stock.index + 1
end

script.on_init(function()
    init_globals()
end)

script.on_configuration_changed(function(config_changed_data)
    init_globals()
end)

local function calc_distance_between_two_points(p1,p2)
    local dx = math.abs(p1.x-p2.x)
    local dy = math.abs(p1.y-p2.y)
    return math.sqrt(dx*dx+dy*dy) --return math.max(math.max(dx,dy),(dx+dy)/2)
end

local function position_to_string(p)
    return p.x .. "," .. p.y
end

local function find_nearest_lc(entity,cc_or_rc,index)
    local nearest_lc = nil
    local nearest_distance = 1000000000 --should big enough
    for _,v in pairs(global.lc_entities.entities) do
        local distance = calc_distance_between_two_points(entity.position,v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            nearest_lc = v
        end
    end

    if nearest_lc ~= nil then 
        table.insert(nearest_lc.cc_rc_s[cc_or_rc],index)
        return {
            distance = nearest_distance,
            lc_pos_str = position_to_string(nearest_lc.lc.position)
        }
    else
        return nil
    end
end

local function remove_cc(index)
    global.cc_entities.entities[tostring(index)] = nil
end

local function remove_rc(index)
    global.rc_entities.entities[tostring(index)] = nil
end

--on built
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity

    if entity.name == entity_names.ores_collecter_chest then
        global.cc_entities.entities[tostring(global.cc_entities.index)] = {index = global.cc_entities.index,entity = entity,nearest_lc = find_nearest_lc(entity,1,global.cc_entities.index)}
        global.cc_entities.index = global.cc_entities.index + 1
    elseif entity.name == entity_names.ores_requester_chest then
        global.rc_entities.entities[tostring(global.rc_entities.index)] = {index = global.rc_entities.index,entity = entity,nearest_lc = find_nearest_lc(entity,2,global.rc_entities.index)}
        global.rc_entities.index = global.rc_entities.index + 1
    elseif entity.name == entity_names.ores_logistics_center then
        --disable signal output on default
        entity.get_or_create_control_behavior().enabled = false

        --will confilct when entity on diffrent surfaces?
        global.lc_entities.entities[position_to_string(entity.position)] = { 
            lc = entity,
            eei = entity.surface.create_entity{
                name = entity_names.electric_energy_interface,
                position = entity.position,
                force = entity.force
            },
            cc_rc_s = {[1]={},[2]={}}
        }
        global.lc_entities.count = global.lc_entities.count + 1
        
        --re-calc distance
        if global.lc_entities.count == 1 then 
            for _,v in pairs(global.cc_entities.entities) do
                if v.entity.valid then
                    v.nearest_lc = find_nearest_lc(v.entity,1,v.index)
                else
                    remove_cc(v.index)
                end
            end
            for _,v in pairs(global.rc_entities.entities) do
                if v.entity.valid then
                    v.nearest_lc = find_nearest_lc(v.entity,2,v.index)
                else
                    remove_rc(v.index)
                end
            end
        end
    end
end)

--on pre-mined-item
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
    local entity = event.entity

    --TODO erase refrences in global.lc_entities.entities[].cc_rc_s when pre-mined cc or rc
    -- if entity.name == entity_names.ores_ores_collecter_chest then
    --     global.lc_entities.entities[].cc_rc_s
    -- elseif entity.name == entity_names.ores_ores_collecter_chest then 

    -- else
    if entity.name == entity_names.ores_logistics_center then
        local p_str = position_to_string(entity.position)

        global.lc_entities.count = global.lc_entities.count - 1

        --destroy the electric energy interface
        global.lc_entities.entities[p_str].eei.destroy()

        --re-calc distance
        -- if global.lc_entities.count > 0 then
        --     for _,index in ipairs(global.lc_entities.entities[p_str].cc_rc_s[1]) do
        --         local pack = global.cc_entities.entities[tostring(index)]
        --         if pack.entity.valid then
        --             global.cc_entities.entities[tostring(index)].nearest_lc = find_nearest_lc(pack.entity,1,index)
        --         else
        --             remove_cc(pack.index)
        --         end
        --     end
        --     for _,index in ipairs(global.lc_entities.entities[p_str].cc_rc_s[2]) do
        --         local pack = global.rc_entities.entities[tostring(index)]
        --         if pack.entity.valid then
        --             global.rc_entities.entities[tostring(index)].nearest_lc = find_nearest_lc(pack.entity,2,index)
        --         else
        --             remove_cc(pack.index)
        --         end
        --     end
        -- end
        
        global.lc_entities.entities[p_str].cc_rc_s = nil --?
        global.lc_entities.entities[p_str] = nil
    end
end)

--update signals of logistics center
local function update_lc_signals(item_name)
    for _,v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            local item = global.items_stock.items[item_name]
            
            if item.index < config.lc_item_slot_count then
                if item.stock > 0 then
                    local signal = {signal = {type = "item",name = item_name},count = item.stock}
                    control_behavior.set_signal(item.index,signal)
                else
                    control_behavior.set_signal(item.index,nil)
                end
            end
        end
    end
end

--check all collecter chests
script.on_nth_tick(config.check_cc_on_nth_tick, function(nth_tick_event)
    if global.lc_entities.count < 1 then return end

    for _,cc in pairs(global.cc_entities.entities) do
        if cc.entity.valid then
            local inventory = cc.entity.get_output_inventory()
            if not inventory.is_empty() then
                local power_consumption = config.cc_power_consumption * cc.nearest_lc.distance
                local contents = inventory.get_contents()

                for name,count in pairs(contents) do
                    local item = global.items_stock.items[name]
                    if item == nil then
                        add_new_item(name)
                        item = global.items_stock.items[name]
                    end
                    local energy = global.lc_entities.entities[cc.nearest_lc.lc_pos_str].eei.energy
                    --enough energy?
                    count = math.min(count,math.floor(energy/power_consumption))
                    --enough capacity?
                    count = math.min(count,config.lc_capacity - item.stock)

                    if count > 0 then
                        inventory.remove({name = name,count = count})
                        global.items_stock.items[name].stock = item.stock + count
                        global.lc_entities.entities[cc.nearest_lc.lc_pos_str].eei.energy = energy - count * power_consumption
                        update_lc_signals(name)
                    end
                end
            end
        else
            --remove invalid collecter chest
            global.cc_entities.entities[cc.index] = nil --?
            table.remove(global.cc_entities.entities,cc.index)
        end
    end

    -- update_lc_signals(global.lc_entity)
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if global.lc_entities.count < 1 then return end

    for _,rc in pairs(global.rc_entities.entities) do
        if rc.entity.valid then
            local inventory = rc.entity.get_output_inventory()

            for i = 1,config.rc_logistic_slots_count do
                local request_slot = rc.entity.get_request_slot(i)
                if request_slot ~= nil then
                    local energy = global.lc_entities.entities[rc.nearest_lc.lc_pos_str].eei.energy
                    local power_consumption = config.rc_power_consumption * rc.nearest_lc.distance
                    local name = request_slot.name
                    local count = request_slot.count
                    local item = global.items_stock.items[name]
                    if item == nil then
                        add_new_item(name)
                        item = global.items_stock.items[name]
                    end
                    --calc shortage
                    count = count - inventory.get_item_count(name)
                    --enough stock?
                    count = math.min(count,item.stock)
                    --enough energy?
                    count = math.min(count,math.floor(energy/power_consumption))

                    if count > 0 then
                        --in case the inventory is full
                        local inserted_count = inventory.insert({name = name,count = count})
                        global.items_stock.items[name].stock = item.stock - inserted_count
                        global.lc_entities.entities[rc.nearest_lc.lc_pos_str].eei.energy = energy - inserted_count * power_consumption
                        update_lc_signals(name)
                    end
                end
            end
        else
            --remove invalid requester chest
            global.rc_entities.entities[rc.index] = nil --?
            table.remove(global.rc_entities.entities,rc.index)
        end
    end

    -- update_lc_signals(global.lc_entity)
end)