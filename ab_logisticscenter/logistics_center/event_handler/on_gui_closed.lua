require('logistics_center.update_lc_signal')
require('logistics_center.update_lc_controller')

local names = g_names

function on_gui_closed(event)
    local entity = event.entity

    if entity ~= nil then
        if entity ~= nil and entity.name == names.logistics_center then -- Logistics Center
            -- update_all_signals()
            local control_behavior = entity.get_or_create_control_behavior()
            if control_behavior.enabled then
                update_lc_signals(entity)
            else
                control_behavior.parameters = nil
            end
        elseif entity.name == names.logistics_center_controller then -- Logistics Center Controller
            local parameters = entity.get_or_create_control_behavior().parameters

            -- update all other lccs
            for _, v in pairs(global.lcc_entity.entities) do
                local control_behavior = v.get_or_create_control_behavior()
                if control_behavior.enabled == true then
                    control_behavior.parameters = parameters
                else
                    control_behavior.parameters = nil
                end
            end

            -- update global parameters
            global.lcc_entity.parameters = parameters

            -- update lc controller
            update_lc_controller()
            update_all_lc_signals()
        elseif entity.name == names.requester_chest_1_1 then -- Requester Chest
            -- game.players[event.player_index].gui.center.clear()
            -- game.players[event.player_index].gui.top.clear()
            -- game.players[event.player_index].gui.left.clear()
            -- game.players[event.player_index].gui.goal.clear()
            -- game.players[event.player_index].gui.screen.clear()
        end
    end
end
