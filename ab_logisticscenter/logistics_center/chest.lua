local math_ceil = math.ceil

local startup_settings = g_startup_settings

function remove_cc(index)
    -- remove invalid chest
    global.cc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.cc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
end

function remove_rc(index)
    -- remove invalid chest
    global.rc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.rc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
end
