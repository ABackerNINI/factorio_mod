require("config")

local config = get_config()
local entity_names = get_entity_names()

local function init_globals()
    global.ores = global.ores or {}
    global.ores_stock = global.ores_stock or {}

    global.lc_entities = global.lc_entities or {count = 0,entities = {}} -- {count,entities = {["pos_str"] = {lc,eei,cc_rc_s={1={},2={}}}}}
    global.cc_entities = global.cc_entities or {index = 1,entities = {}} -- {index,entities = {entity,nearest_lc={distance,lc_pos_str}}}
    global.rc_entities = global.rc_entities or {index = 1,entities = {}} -- {index,entities = {entity,nearest_lc={distance,lc_pos_str}}}
end

script.on_init(function()
    init_globals()

    for _,entity in pairs(game.entity_prototypes) do
        if entity.type == "resource" and game.item_prototypes[entity.name] ~= nil then
            table.insert(global.ores,entity.name)
            global.ores_stock[entity.name] = 0
        end
    end
end)

script.on_configuration_changed(function(config_changed_data)
    init_globals()

    for _,entity in pairs(game.entity_prototypes) do
        if entity.type == "resource" and game.item_prototypes[entity.name] ~= nil then
            table.insert(global.ores,entity.name)
            global.ores_stock[entity.name] = 0
        end
    end
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

script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity

    if entity.name == entity_names.ores_collecter_chest then
        global.cc_entities.entities[global.cc_entities.index] = {entity = entity,nearest_lc = find_nearest_lc(entity,1,global.cc_entities.index)}
        global.cc_entities.index = global.cc_entities.index + 1
    elseif entity.name == entity_names.ores_requester_chest then
        global.rc_entities.entities[global.rc_entities.index] = {entity = entity,nearest_lc = find_nearest_lc(entity,2,global.rc_entities.index)}
        global.rc_entities.index = global.rc_entities.index + 1
    elseif entity.name == entity_names.ores_logistics_center then
        --re-calc distance
        if global.lc_entities.count == 0 then 
            for index,v in pairs(global.cc_entities.entities) do
                v.nearest_lc = find_nearest_lc(v.entity,1,global.index)
            end
            for index,v in pairs(global.rc_entities.entities) do
                v.nearest_lc = find_nearest_lc(v.entity,2,global.index)
            end
        end

        --will confilct when entity on diffrent surfaces?
        global.lc_entities.entities[position_to_string(entity.position)] = { 
            lc = entity,
            eei = entity.surface.create_entity{
                name = entity_names.electric_energy_interface,
                position = entity.position,
                force = entity.force
            },
            cc_rc_s = {}
        }
        global.lc_entities.count = global.lc_entities.count + 1
    end
end)

--destroy the electric energy interface
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
    local entity = event.entity
    local p_str = position_to_string(entity.position)

    if entity.name == entity_names.ores_logistics_center then
        --re-calc distance
        if global.lc_entities.count > 0 then
            for _,index in ipairs(global.lc_entities.entities[p_str].cc_rc_s[1]) do
                global.cc_entities.entities[index].nearest_lc = find_nearest_lc(global.cc_entities.entities[index].entity,1,index)
            end
            for _,index in ipairs(global.lc_entities.entities[p_str].rc_rc_s[2]) do
                global.rc_entities.entities[index].nearest_lc = find_nearest_lc(global.cc_entities.entities[index].entity,2,index)
            end
        end

        global.lc_entities.entities[p_str].eei.destroy()
        global.lc_entities.entities[p_str].cc_rc_s = nil --?
        global.lc_entities.entities[p_str] = nil
        global.lc_entities.count = global.lc_entities.count - 1
    end

    --TODO erase refrences in global.lc_entities.entities[].cc_rc_s when pre-mined cc or rc
end)

--update signals of logistics center
local function update_lc_signals(item)
    -- local control_behavior = lc_entity.get_or_create_control_behavior()
    -- if control_behavior.enabled then
    --     local i = 1
    --     for nm,stock in pairs(global.ores_stock) do
    --         if stock > 0 then
    --             local signal = {}
    --             signal.signal= {type = "item",name = nm}
    --             signal.count = stock

    --             control_behavior.set_signal(i,signal)
    --         else
    --             control_behavior.set_signal(i,nil)
    --         end

    --         i = i + 1
    --     end
    -- end
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

                for nm,cnt in pairs(contents) do
                    for _,ore in ipairs(global.ores) do--?
                        if nm == ore then
                            --enough energy?
                            cnt = math.min(cnt,math.floor(global.lc_entities.entities[cc.nearest_lc.lc_pos_str].eei.energy/power_consumption))
                            --enough capacity?
                            cnt = math.min(cnt,config.lc_capacity - global.ores_stock[nm])

                            if cnt > 0 then
                                inventory.remove({name = nm,count = cnt})
                                global.ores_stock[nm] = global.ores_stock[nm] + cnt
                                global.lc_entities.entities[cc.nearest_lc.lc_pos_str].eei.energy = 
                                    global.lc_entities.entities[cc.nearest_lc.lc_pos_str].eei.energy - cnt * power_consumption
                            end
                        end
                    end
                end
            end
        else
            --remove invalid collecter chest
            global.cc_entities.entities[i] = nil --?
            table.remove(global.cc_entities.entities,i)
        end
    end

    update_lc_signals(global.lc_entity)
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if global.lc_entities.count < 1 then return end

    for _,rc in pairs(global.rc_entities.entities) do
        if rc.entity.valid then
            local inventory = rc.entity.get_output_inventory()

            for i = 1,config.rc_logistic_slots_count do
                local request_slot = rc.entity.get_request_slot(i)
                if request_slot ~= nil and global.ores_stock[request_slot.name] ~= nil then
                    local power_consumption = config.rc_power_consumption * rc.nearest_lc.distance

                    --calc shortage
                    request_slot.count = request_slot.count - inventory.get_item_count(request_slot.name)
                    --enough stock?
                    request_slot.count = math.min(request_slot.count,global.ores_stock[request_slot.name])
                    --enough energy?
                    request_slot.count = math.min(request_slot.count,math.floor(global.lc_entities.entities[rc.nearest_lc.lc_pos_str].eei.energy/power_consumption))

                    if request_slot.count > 0 then
                        --in case the inventory is full
                        local inserted_count = inventory.insert(request_slot)
                        global.ores_stock[request_slot.name] = global.ores_stock[request_slot.name] - inserted_count
                        global.lc_entities.entities[rc.nearest_lc.lc_pos_str].eei.energy = 
                            global.lc_entities.entities[rc.nearest_lc.lc_pos_str].eei.energy - inserted_count * power_consumption
                    end
                end
            end
        else
            --remove invalid requester chest
            global.rc_entities.entities[i] = nil
            table.remove(global.rc_entities.entities,i)
        end
    end

    update_lc_signals(global.lc_entity)
end)