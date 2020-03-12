require('config')

local config = g_config
local names = g_names

local function calc_distance_between_two_points(p1, p2)
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end

local function position_to_string(p)
    return p.x .. ',' .. p.y
end

-- find nearest lc
local function find_nearest_lc(entity, type)
    if global.lc_entities.count == 0 then
        return nil
    end

    local eei = nil
    local nearest_distance = 1000000000 -- should big enough
    for k, v in pairs(global.lc_entities.entities) do
        local distance = calc_distance_between_two_points(entity.position, v.lc.position)
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
        if type == 1 then
            ret.power_consumption = nearest_distance * 1000 -- config.cc_power_consumption
        else
            ret.power_consumption = nearest_distance * 100 -- config.rc_power_consumption
        end
        return ret
    else
        game.print("[ab_logisticscenter]:error,didn't find@updates.find_nearest_lc")
        return nil
    end
end

-- recalc distance from cc/rc to the nearest lc
-- call after lc entity being created or destroyed
local function recalc_distance()
    -- recalc cc
    for index, v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity, 1)
        end
    end

    -- recalc rc
    for index, v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity, 2)
        end
    end
end

-- global_data_version: nil -> 16
function update()
    -- if global.global_data_version == nil or global.global_data_version < config.global_data_version then
    --     game.print("")
    -- end
    -- first change,global.global_data_version = nil
    -- code opt.
    if global.global_data_version == nil and global.cc_entities ~= nil and global.cc_entities.index ~= nil then
        game.print({names.locale_print_when_global_data_migrate, 1})
        -- global.cc_entities
        -- OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        -- NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local new_cc_entities = {
            count = 0,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }
        local cc_count = 0
        for k, v in pairs(global.cc_entities.entities) do
            cc_count = cc_count + 1
            new_cc_entities.entities[cc_count] = {entity = v.entity, nearest_lc = v.nearest_lc}
        end
        new_cc_entities.count = cc_count
        global.cc_entities = nil
        global.cc_entities = new_cc_entities

        -- global.rc_entities
        -- OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        -- NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local new_rc_entities = {
            count = 0,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }
        local rc_count = 0
        for k, v in pairs(global.rc_entities.entities) do
            rc_count = rc_count + 1
            new_rc_entities.entities[rc_count] = {entity = v.entity, nearest_lc = v.nearest_lc}
        end
        new_rc_entities.count = rc_count
        global.rc_entities = nil
        global.rc_entities = new_rc_entities

        -- set global_data_version
        global.global_data_version = 2
    end

    -- second change,global.global_data_version = nil
    -- code frame change:classes-version->plain-version
    if global.global_data_version == nil or global.global_data_version < 3 then
        game.print({names.locale_print_when_global_data_migrate, 2})
        -- cc_entities.empty_stack
        -- OLD Stack:new{p,data}
        -- NEW {count,data}
        local new_cc_es_count = 0
        local new_cc_empty_stack = {count = 0, data = {}}
        for k, v in pairs(global.cc_entities.entities) do
            if v == nil then
                new_cc_es_count = new_cc_es_count + 1
                new_cc_empty_stack.data[new_cc_es_count] = k
            end
        end
        new_cc_empty_stack.count = new_cc_es_count
        global.cc_entities.empty_stack = new_cc_empty_stack

        -- rc_entities.empty_stack
        -- OLD Stack:new{p,data}
        -- NEW {count,data}
        local new_rc_es_count = 0
        local new_rc_empty_stack = {count = 0, data = {}}
        for k, v in pairs(global.rc_entities.entities) do
            if v == nil then
                new_rc_es_count = new_rc_es_count + 1
                new_rc_empty_stack.data[new_rc_es_count] = k
            end
        end
        new_rc_empty_stack.count = new_rc_es_count
        global.rc_entities.empty_stack = new_rc_empty_stack

        -- set global_data_version
        global.global_data_version = 3
    end

    -- third change,global.global_data_version = nil
    -- code opt:distance->power_consumption.no need to calc the power_consumption every time
    if global.global_data_version == nil or global.global_data_version < 4 then
        game.print({names.locale_print_when_global_data_migrate, 3})
        -- cc_entities.entities.nearest_lc
        -- OLD {distance,lc_pos_str}
        -- NEW {power_consumption,lc_pos_str}
        for k, v in pairs(global.cc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * 1000 -- config.cc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption, lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end

        -- rc_entities.entities.nearest_lc
        -- OLD {distance,lc_pos_str}
        -- NEW {power_consumption,lc_pos_str}
        for k, v in pairs(global.rc_entities.entities) do
            if v.nearest_lc ~= nil then
                local power_consumption = v.nearest_lc.distance * 100 -- config.rc_power_consumption
                v.nearest_lc = {power_consumption = power_consumption, lc_pos_str = v.nearest_lc.lc_pos_str}
            end
        end

        -- set global_data_version
        global.global_data_version = 4
    end

    -- fourth change,global.global_data_version = 4
    -- code opt:lc_pos_str->eei.no need to get the eei every time
    if global.global_data_version < 5 then
        game.print({names.locale_print_when_global_data_migrate, 4})
        -- cc_entities.entities.nearest_lc
        -- OLD {power_consumption,lc_pos_str}
        -- NEW {power_consumption,eei}
        -- rc_entities.entities.nearest_lc
        -- OLD {power_consumption,lc_pos_str}
        -- NEW {power_consumption,eei}
        recalc_distance()

        -- set global_data_version
        global.global_data_version = 5
    end

    -- fifth change,global.global_data_version = 5
    if global.global_data_version < 6 then
        game.print({names.locale_print_when_global_data_migrate, 5})
        -- cc_entities
        -- OLD {count,empty_stack,entities}
        -- NEW {index,empty_stack,entities}
        local ordered_cc_entities = {}
        local index = 1
        for _, v in pairs(global.cc_entities.entities) do
            ordered_cc_entities[index] = v
            index = index + 1
        end

        local new_cc_entities = {index = index, empty_stack = {count = 0, data = {}}, entities = ordered_cc_entities}
        global.cc_entities = new_cc_entities

        -- rc_entities
        -- OLD {count,empty_stack,entities}
        -- NEW {index,empty_stack,entities}
        local ordered_rc_entities = {}
        index = 1
        for _, v in pairs(global.rc_entities.entities) do
            ordered_rc_entities[index] = v
            index = index + 1
        end

        local new_rc_entities = {index = index, empty_stack = {count = 0, data = {}}, entities = ordered_rc_entities}
        global.rc_entities = new_rc_entities

        -- set global_data_version
        global.global_data_version = 6
    end

    -- sixth change,global.global_data_version = 6
    -- new feature:two technologies
    if global.global_data_version < 7 then
        game.print({names.locale_print_when_global_data_migrate, 6})
        -- global.technologies
        -- OLD nil
        -- NEW {lc_capacity,cc_power_consumption,rc_power_consumption}
        global.technologies = {
            lc_capacity = 10000, -- config.default_lc_capacity,
            cc_power_consumption = 1000, -- config.default_cc_power_consumption,
            rc_power_consumption = 100, -- config.default_rc_power_consumption,
            tech_lc_capacity_real_level = 0,
            tech_power_consumption_real_level = 0
        }

        -- set global_data_version
        global.global_data_version = 7
    end

    -- seventh change,global.global_data_version = 7
    -- bug fix:in case player disables some mods which adds items
    if global.global_data_version < 8 then
        game.print({names.locale_print_when_global_data_migrate, 7})
        -- global.items_stock.items
        -- OLD {["item_name"] = {index,stock}
        -- NEW {["item_name"] = {index,stock,enable}
        for k, v in pairs(global.items_stock.items) do
            if game.item_prototypes[k] ~= nil then
                v.enable = true
            else
                v.enable = false
            end
        end

        -- set global_data_version
        global.global_data_version = 8
    end

    -- eighth change,global.global_data_version = 8
    -- bug fix:multiplayer desyncs.check https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir#Multiplayer_and_desyncs
    if global.global_data_version < 9 then
        game.print({names.locale_print_when_global_data_migrate, 8})
        -- global.runtime_vars
        -- OLD nil
        -- NEW {cc_check_per_round,cc_checked_index,rc_check_per_round,rc_checked_index}
        global.runtime_vars = {
            cc_check_per_round = math.ceil(global.cc_entities.index * 0.015), -- config.check_cc_percentage),
            cc_checked_index = 0,
            rc_check_per_round = math.ceil(global.rc_entities.index * 0.015), -- config.check_rc_percentage),
            rc_checked_index = 0
        }

        -- set global_data_version
        global.global_data_version = 9
    end

    -- ninth change,global.global_data_version = 9
    -- add logistics center controller
    if global.global_data_version < 10 then
        game.print({names.locale_print_when_global_data_migrate, 9})
        -- global.lcc_entity
        -- OLD nil
        -- NEW {entity}
        global.lcc_entity = {
            entity = nil
        }

        -- global.items_stock.items
        -- OLD {["item_name"] = {index,stock,enable}}
        -- NEW {["item_name"] = {index,stock,enable,max_control}}
        for k, v in pairs(global.items_stock.items) do
            v.max_control = global.technologies.lc_capacity
        end

        -- set global_data_version
        global.global_data_version = 10
    end

    -- tenth change,global.global_data_version = 10
    -- bug fix:default max_control [big_number->lc_capacity]@add_item()
    if global.global_data_version < 11 then
        game.print({names.locale_print_when_global_data_migrate, 10})

        for k, v in pairs(global.items_stock.items) do
            if v.max_control == 1000000000 then
                v.max_control = global.technologies.lc_capacity
            end
        end

        -- set global_data_version
        global.global_data_version = 11
    end

    -- eleventh change,global.global_data_version = 11
    -- new feature:multi-lcc support
    if global.global_data_version < 12 then
        game.print({names.locale_print_when_global_data_migrate, 11})

        -- global.lcc_entity
        -- OLD {entity}
        -- NEW {count,parameters,entities={[index] = entity}
        if global.lcc_entity.entity == nil then
            global.lcc_entity.count = 0
            global.lcc_entity.parameters = nil
            global.lcc_entity.entities = {}
        else
            global.lcc_entity.count = 1
            global.lcc_entity.parameters = global.lcc_entity.entity.get_or_create_control_behavior().parameters
            global.lcc_entity.entities = {}
            global.lcc_entity.entities[1] = global.lcc_entity.entity
            global.lcc_entity.entity = nil
        end

        -- set global_data_version
        global.global_data_version = 12
    end

    -- twelfth change,global.global_data_version = 12
    -- bug fix:multi-lcc support,forget to init global.lcc_entity.entities if global.lcc_entity.entity == nil.
    if global.global_data_version < 13 then
        game.print({names.locale_print_when_global_data_migrate, 12})

        if global.lcc_entity.entities == nil then
            global.lcc_entity.entities = {}
        end

        -- set global_data_version
        global.global_data_version = 13
    end

    -- 13-th change,global.global_data_version = 13
    -- add settings Power Consumption
    if global.global_data_version < 14 then
        game.print({names.locale_print_when_global_data_migrate, 13})

        -- add global.technologies.power_consumption_percentage
        global.technologies.power_consumption_percentage = 1

        -- set global_data_version
        global.global_data_version = 14
    end

    -- 14-th change,global.global_data_version = 14
    -- fix multi-surface position string conflict
    if global.global_data_version < 15 then
        game.print({names.locale_print_when_global_data_migrate, 14})

        -- global.lc_entities
        -- OLD {count, entities = {["pos_str"] = {lc, eei}}}
        -- NEW {count, entities = {["surface_and_pos_str"] = {lc, eei}}}
        -- OLD pos_str: p.x .. ',' .. p.y
        -- NEW surface_and_pos_str: surface_index .. ',' .. p.x .. ',' .. p.y
        local new_entities = {}
        for k, v in pairs(global.lc_entities.entities) do
            new_entities[v.lc.surface.index .. ',' .. k] = v
        end
        global.lc_entities.entities = nil
        global.lc_entities.entities = new_entities

        -- set global_data_version
        global.global_data_version = 15
    end

    -- 15-th change,global.global_data_version = 15
    -- add lc energy_bar
    if global.global_data_version < 16 then
        game.print({names.locale_print_when_global_data_migrate, 15})

        -- global.lc_entities
        -- OLD nil
        -- NEW {count, entities = {energy_bar, energy_bar_index, eei}}
        global.energy_bar_entities = {
            count = 0,
            entities = {}
        }

        -- set global_data_version
        global.global_data_version = 16
    end
end
