require('logistics_center.update_lc_signal')

local names = g_names

function on_gui_opened(event)
    local entity = event.entity

    if entity ~= nil and entity.name == names.logistics_center then
        -- update_all_signals()
        local control_behavior = entity.get_or_create_control_behavior()
        if control_behavior.enabled then
            update_lc_signals(entity)
        else
            control_behavior.parameters = nil
        end
    end
end
