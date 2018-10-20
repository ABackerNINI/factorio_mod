require("config")

local config = get_config()
local entity_names = get_entity_names()

local function init_globals()
    global.eei_entity = eei_entity or nil
    global.lc_entity = lc_entity or nil
    global.ores = ores or {}
    global.ores_stock = ores_stock or {}
    global.collecter_chests = collecter_chests or {}
    global.requester_chests = requester_chests or {}
    global.collecter_chests_index = collecter_chests_index or 1
    global.requester_chests_index = requester_chests_index or 1
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

--its not the real distance,for reducing computation
local function calc_distance_between_two_points(p1,p2)
    local dx = math.abs(p1.x-p2.x)
    local dy = math.abs(p1.y-p2.y)
    return math.max(math.max(dx,dy),(dx+dy)/2) --return math.sqrt(dx*dx+dy*dy)
end

script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity

    if entity.name == entity_names.ores_collecter_chest then
        global.collecter_chests[global.collecter_chests_index] = entity
        --collecter_chests[collecter_chests_index] = {entity=entity,distance = calc_distance_between_two_points()}
        global.collecter_chests_index = global.collecter_chests_index + 1
    elseif entity.name == entity_names.ores_requester_chest then
        global.requester_chests[global.requester_chests_index] = entity
        global.requester_chests_index = global.requester_chests_index + 1
    elseif entity.name == entity_names.ores_logistics_center then
        global.lc_entity = entity

        if global.eei_entity ~= nil then 
            global.eei_entity.destroy()
            global.eei_entity = nil
        end

        global.eei_entity = entity.surface.create_entity{
            name = entity_names.electric_energy_interface,
            position = entity.position,
            force = entity.force
        }
    end
end)

--destroy the electric energy interface
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died},function(event)
    local entity = event.entity

    if entity.name == entity_names.ores_logistics_center then
        global.eei_entity.destroy()
        global.eei_entity = nil
    end
end)

--update signals of logistics center
local function update_lc_signals(lc_entity)
    local control_behavior = lc_entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        local i = 1
        for nm,stock in pairs(global.ores_stock) do
            if stock > 0 then
                local signal = {}
                signal.signal= {type = "item",name = nm}
                signal.count = stock

                control_behavior.set_signal(i,signal)
            else
                control_behavior.set_signal(i,nil)
            end

            i = i + 1
        end
    end
end

--check all collecter chests
script.on_nth_tick(config.check_cc_on_nth_tick, function(nth_tick_event)
    if global.eei_entity == nil then return end
    for i,cc in pairs(global.collecter_chests) do
        if cc.valid then
            local inventory = cc.get_output_inventory()
            if not inventory.is_empty() then
                local distance = calc_distance_between_two_points(global.lc_entity.position,cc.position)
                local power_consumption = config.cc_power_consumption * distance
                local contents = inventory.get_contents()

                for nm,cnt in pairs(contents) do
                    for _,ore in ipairs(global.ores) do--?
                        if nm == ore then
                            --enough energy?
                            cnt = math.min(cnt,math.floor(global.eei_entity.energy/power_consumption))
                            --enough capacity?
                            cnt = math.min(cnt,config.lc_capacity - global.ores_stock[nm])

                            if cnt > 0 then
                                inventory.remove({name = nm,count = cnt})
                                global.ores_stock[nm] = global.ores_stock[nm] + cnt
                                global.eei_entity.energy = global.eei_entity.energy - cnt * power_consumption
                            end
                        end
                    end
                end
            end
        else
            --remove invalid collecter chest
            global.collecter_chests[i] = nil
            table.remove(global.collecter_chests,i)
        end
    end

    update_lc_signals(global.lc_entity)
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if global.eei_entity == nil then return end
    for i,rc in pairs(global.requester_chests) do
        if rc.valid then
            local inventory = rc.get_output_inventory()

            for i = 1,config.rc_logistic_slots_count do
                local request_slot = rc.get_request_slot(i)
                if request_slot ~= nil and global.ores_stock[request_slot.name] ~= nil then
                    local distance = calc_distance_between_two_points(global.lc_entity.position,rc.position)
                    local power_consumption = config.rc_power_consumption * distance

                    --calc shortage
                    request_slot.count = request_slot.count - inventory.get_item_count(request_slot.name)
                    --enough stock?
                    request_slot.count = math.min(request_slot.count,global.ores_stock[request_slot.name])
                    --enough energy?
                    request_slot.count = math.min(request_slot.count,math.floor(global.eei_entity.energy/power_consumption))

                    if request_slot.count > 0 then
                        --in case the inventory is full
                        local inserted_count = inventory.insert(request_slot)
                        global.ores_stock[request_slot.name] = global.ores_stock[request_slot.name] - inserted_count
                        global.eei_entity.energy = global.eei_entity.energy - inserted_count * power_consumption
                    end
                end
            end
        else
            --remove invalid requester chest
            global.requester_chests[i] = nil
            table.remove(global.requester_chests,i)
        end
    end

    update_lc_signals(global.lc_entity)
end)