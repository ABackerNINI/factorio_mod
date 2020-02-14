require('helper')

local names = g_names
local config = g_config

local math_ceil = math.ceil

-- Find nearest lc
function find_nearest_lc(entity)
    if global.lc_entities.count == 0 then
        return nil
    end

    local surface = entity.surface.index
    local eei = nil
    local nearest_distance = 1000000000 -- should big enough
    for k, v in pairs(global.lc_entities.entities) do
        if surface == v.lc.surface.index then
            local distance = calc_distance_between_two_points(entity.position, v.lc.position)
            if distance < nearest_distance then
                nearest_distance = distance
                eei = v.eei
            end
        end
    end

    if eei ~= nil then
        local ret = {
            power_consumption = 0,
            eei = eei
        }
        -- if string.match(entity.name,names.collecter_chest_pattern) ~= nil then this is not recommanded
        if entity.name == names.collecter_chest_1_1 then -- or
            -- entity.name == names.collecter_chest_3_6 or
            -- entity.name == names.collecter_chest_6_3
            ret.power_consumption = math_ceil(nearest_distance * global.technologies.cc_power_consumption)
        else
            ret.power_consumption = math_ceil(nearest_distance * global.technologies.rc_power_consumption)
        end
        return ret
    else
        -- game.print("[ab_logisticscenter]: error, didn't find@find_nearest_lc")
        return nil
    end
end
