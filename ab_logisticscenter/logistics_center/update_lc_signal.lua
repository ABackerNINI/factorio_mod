local startup_settings = g_startup_settings

-- update single lc signal
function update_lc_signal(item, item_name)
    -- pack the signal
    local signal = nil
    -- local item = global.items_stock.items[item_name]
    if item.index < startup_settings.lc_item_slot_count then
        signal = {signal = {type = 'item', name = item_name}, count = item.stock}
    end

    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signal to the lc(s) which control_behavior are enabled
    for _, v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.set_signal(item.index, signal)
        end
    end
end

-- update lc signals
function update_lc_signals(entity)
    local control_behavior = entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        -- pack all the signals
        local signals = {}
        local i = 1
        for item_name, item in pairs(global.items_stock.items) do
            local signal = nil
            if item.enable == true then
                -- game.print(item_name)
                if item.index < startup_settings.lc_item_slot_count then
                    signal = {signal = {type = 'item', name = item_name}, count = item.stock, index = item.index}
                end
            end
            signals[i] = signal
            i = i + 1
        end
        local parameters = {parameters = signals}
        control_behavior.parameters = parameters
    else
        control_behavior.parameters = nil
    end
end

-- update all lc signals
function update_all_lc_signals()
    -- pack all the signals
    local signals = {}
    local i = 1
    for item_name, item in pairs(global.items_stock.items) do
        local signal = nil
        if item.enable == true then
            -- game.print(item_name)
            if item.index < startup_settings.lc_item_slot_count then
                signal = {signal = {type = 'item', name = item_name}, count = item.stock, index = item.index}
            end
        end
        signals[i] = signal
        i = i + 1
    end

    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signals to the lc(s) which control_behavior are enabled
    local parameters = {parameters = signals}
    for _, v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.parameters = parameters
        else
            control_behavior.parameters = nil
        end
    end
end
