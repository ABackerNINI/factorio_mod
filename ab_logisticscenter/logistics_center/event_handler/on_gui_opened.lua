require('config')
require('logistics_center.update_lc_signal')

local names = g_names

function on_gui_opened(event)
    local entity = event.entity

    if entity ~= nil then
        if entity.name == names.logistics_center then -- Logistics Center
            -- update_all_signals()
            local control_behavior = entity.get_or_create_control_behavior()
            if control_behavior.enabled then
                update_lc_signals(entity)
            else
                control_behavior.parameters = nil
            end
        elseif entity.name == names.requester_chest_1_1 then -- Requester Chest
        -- game.players[event.player_index].gui.center.add {type = 'choose-elem-button', name = 'test_picker1', elem_type = 'item'}
        -- game.players[event.player_index].gui.top.add {type = 'choose-elem-button', name = 'test_picker2', elem_type = 'item'}
        -- game.players[event.player_index].gui.left.add {type = 'choose-elem-button', name = 'test_picker3', elem_type = 'item'}
        -- game.players[event.player_index].gui.goal.add {type = 'choose-elem-button', name = 'test_picker4', elem_type = 'item'}
        -- game.players[event.player_index].gui.screen.add {type = 'choose-elem-button', name = 'test_picker5', elem_type = 'item'}
        end
    end
end
