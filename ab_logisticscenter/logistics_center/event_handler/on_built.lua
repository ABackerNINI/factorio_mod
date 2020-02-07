require('config')
require('logistics_center.helper')
require('logistics_center.find_nearest_lc')
require('logistics_center.update_lc_controller')

local math_ceil = math.ceil

local names = g_names
local config = g_config
local startup_settings = g_startup_settings

function on_built(event)
    local entity = event.created_entity
    local name = entity.name

    -- if string.match(name,names.collecter_chest_pattern) ~= nil then  --- this is not recommanded
    if name == names.collecter_chest_1_1 then -- or
        -- if string.match(name,names.requester_chest_pattern) ~= nil then  --- this is not recommanded
        -- name == names.collecter_chest_3_6 or
        -- name == names.collecter_chest_6_3
        -- add cc to the watch-list
        local index = global.cc_entities.index
        local empty_stack = global.cc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        global.cc_entities.entities[index] = {entity = entity, nearest_lc = find_nearest_lc(entity)}

        -- show flying text
        if global.cc_entities.entities[index].nearest_lc ~= nil then
            entity.surface.create_entity {
                name = 'flying-text',
                position = {x = entity.position.x, y = entity.position.y - 1},
                color = {r = 228 / 255, g = 236 / 255, b = 0},
                text = {
                    config.locale_flying_text_when_build_chest,
                    string.format('%.1f', calc_distance_between_two_points(entity.position, global.cc_entities.entities[index].nearest_lc.eei.position))
                }
            }
        end

        global.cc_entities.index = global.cc_entities.index + 1

        -- recalc cpr
        global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
    elseif name == names.requester_chest_1_1 then -- or
        -- name == names.requester_chest_3_6 or
        -- name == names.requester_chest_6_3
        -- add rc to the watch-list
        local index = global.rc_entities.index
        local empty_stack = global.rc_entities.empty_stack
        if empty_stack.count > 0 then
            index = empty_stack.data[empty_stack.count]
            empty_stack.count = empty_stack.count - 1
        end
        global.rc_entities.entities[index] = {entity = entity, nearest_lc = find_nearest_lc(entity)}

        -- show flying text
        if global.rc_entities.entities[index].nearest_lc ~= nil then
            entity.surface.create_entity {
                name = 'flying-text',
                position = {x = entity.position.x, y = entity.position.y - 1},
                color = {r = 228 / 255, g = 236 / 255, b = 0},
                text = {
                    config.locale_flying_text_when_build_chest,
                    string.format('%.1f', calc_distance_between_two_points(entity.position, global.rc_entities.entities[index].nearest_lc.eei.position))
                }
            }
        end

        global.rc_entities.index = global.rc_entities.index + 1

        -- recalc cpr
        global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
    elseif name == names.logistics_center then
        -- disable signal output of the lc on default except the very first one
        -- this will cause a problem that signals don't show up immediately after control-behavior enabled
        if global.lc_entities.count > 0 then
            entity.get_or_create_control_behavior().enabled = false
        end

        -- will confilct when entity on diffrent surfaces?
        global.lc_entities.entities[position_to_string(entity.position)] = {
            lc = entity,
            -- create the electric energy interface
            eei = entity.surface.create_entity {
                name = names.electric_energy_interface,
                position = entity.position,
                force = entity.force
            }
            -- ani = entity.surface.create_entity{
            --     name = names.logistics_center_animation,
            --     position = entity.position,
            --     force = entity.force
            -- }
        }

        global.lc_entities.count = global.lc_entities.count + 1

        -- recalc distance
        recalc_distance()
    elseif name == names.logistics_center_controller then
        -- caution:loop with big_number
        for index = 1, config.big_number do
            if global.lcc_entity.entities[index] == nil then -- or global.lcc_entity.entities[index].valid == false
                if global.lcc_entity.parameters ~= nil then
                    -- set parameters
                    local control_behavior = entity.get_or_create_control_behavior()
                    control_behavior.parameters = global.lcc_entity.parameters

                    -- update lc controller
                    if global.lcc_entity.count == 0 then
                        update_lc_controller()
                    end
                end

                global.lcc_entity.entities[index] = entity
                global.lcc_entity.count = global.lcc_entity.count + 1
                break
            end
        end
    end
end
