require("config")

local config = get_config()
local entity_names = get_entity_names()

local eei_entity = nil
local lc_entity = nil

local ores = {}
local ores_stock = {}

local collecter_chests = {}
local requester_chests = {}
local collecter_chests_index = 1
local requester_chests_index = 1

-- local function get_icon(name) 
--     return "item/" .. name
-- end

script.on_init(function()
    for _,entity in pairs(game.entity_prototypes) do
        if entity.type == "resource" and game.item_prototypes[entity.name] ~= nil then
            table.insert(ores,entity.name)
            ores_stock[entity.name] = 0
        end
    end
end)

script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity

    if entity.name == entity_names.ores_collecter_chest then
        -- table.insert(collecter_chests,entity)
        collecter_chests[collecter_chests_index] = entity
        collecter_chests_index = collecter_chests_index + 1
    elseif entity.name == entity_names.ores_requester_chest then
        requester_chests[requester_chests_index] = entity
        requester_chests_index = requester_chests_index + 1
    elseif entity.name == entity_names.ores_logistics_center then
        lc_entity = entity

        if eei_entity ~= nil then 
            eei_entity.destroy()
            eei_entity = nil
        end

        eei_entity = entity.surface.create_entity{
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
        eei_entity.destroy()
        eei_entity = nil
    end
end)

--its not the real distance,for reducing computation
local function calc_distance_between_two_points(p1,p2)
    local dx = math.abs(p1.x-p2.x)
    local dy = math.abs(p1.y-p2.y)
    return math.max(math.max(dx,dy),(dx+dy)/2) --return math.sqrt(dx*dx+dy*dy)
end

--update signals of logistics center
local function update_lc_signals(lc_entity)
    local control_behavior = lc_entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        local i = 1
        for nm,stock in pairs(ores_stock) do
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
    if eei_entity == nil then return end
    for i,cc in pairs(collecter_chests) do
        if cc.valid then
            local inventory = cc.get_output_inventory()
            if not inventory.is_empty() then
                local distance = calc_distance_between_two_points(lc_entity.position,cc.position)
                local power_consumption = config.cc_power_consumption * distance
                local contents = inventory.get_contents()

                for nm,cnt in pairs(contents) do
                    for _,ore in ipairs(ores) do
                        if nm == ore then
                            --enough energy?
                            cnt = math.min(cnt,math.floor(eei_entity.energy/power_consumption))
                            --enough capacity?
                            cnt = math.min(cnt,config.lc_capacity - ores_stock[nm])

                            if cnt > 0 then
                                inventory.remove({name = nm,count = cnt})
                                ores_stock[nm] = ores_stock[nm] + cnt
                                eei_entity.energy = eei_entity.energy - cnt * power_consumption
                            end
                        end
                    end
                end
            end
        else
            --remove invalid collecter chest
            collecter_chests[i] = nil
            table.remove(collecter_chests,i)
        end
    end

    update_lc_signals(lc_entity)
end)

--check all requester chests
script.on_nth_tick(config.check_rc_on_nth_tick,function(nth_tick_event)
    if eei_entity == nil then return end
    for i,rc in pairs(requester_chests) do
        if rc.valid then
            local inventory = rc.get_output_inventory()

            for i = 1,config.rc_logistic_slots_count do
                local request_slot = rc.get_request_slot(i)
                if request_slot ~= nil and ores_stock[request_slot.name] ~= nil then
                    local distance = calc_distance_between_two_points(lc_entity.position,rc.position)
                    local power_consumption = config.rc_power_consumption * distance

                    --calc shortage
                    request_slot.count = request_slot.count - inventory.get_item_count(request_slot.name)
                    --enough stock?
                    request_slot.count = math.min(request_slot.count,ores_stock[request_slot.name])
                    --enough energy?
                    request_slot.count = math.min(request_slot.count,math.floor(eei_entity.energy/power_consumption))

                    if request_slot.count > 0 then
                        --in case the inventory is full
                        local inserted_count = inventory.insert(request_slot)
                        ores_stock[request_slot.name] = ores_stock[request_slot.name] - inserted_count
                        eei_entity.energy = eei_entity.energy - inserted_count * power_consumption
                    end
                end
            end
        else
            --remove invalid requester chest
            requester_chests[i] = nil
            table.remove(requester_chests,i)
        end
    end

    update_lc_signals(lc_entity)
end)