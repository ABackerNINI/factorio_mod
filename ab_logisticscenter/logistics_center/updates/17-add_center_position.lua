require('config')

local function calc_distance_between_two_points(p1, p2)
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end

local function calc_distance_between_two_points2(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return math.sqrt(dx * dx + dy * dy)
end

local function calc_power_consumption(distance, eei, chest_type)
    if eei ~= nil then
        local ret = {
            power_consumption = 0,
            eei = eei
        }

        -- calc multiplier
        local dis = calc_distance_between_two_points2(eei.position.x, eei.position.y, global.lc_entities.center_pos_x, global.lc_entities.center_pos_y)
        local multiplier
        if dis < 100 then
            multiplier = 1
        else
            -- game.print('multiplier: ' .. multiplier)
            multiplier = 1 + (dis / 100 * 0.1)
        end

        if chest_type == 1 then
            ret.power_consumption = math.ceil(distance * global.technologies.cc_power_consumption * multiplier)
        else
            ret.power_consumption = math.ceil(distance * global.technologies.rc_power_consumption * multiplier)
        end

        return ret
    else
        return nil
    end
end

-- global_data_version: 16 -> 17
function add_center_position()
    -- 16-th change,global.global_data_version = 16
    -- add center position
    if global.global_data_version < 17 then
        game.print({g_names.locale_print_when_global_data_migrate, 16})

        -- global.lc_entities
        -- OLD {count, entities = {["surface_and_pos_str"] = {lc, eei, energy_bar_index}}}
        -- NEW {count, center_pos_x, center_pos_y, entities = {["surface_and_pos_str"] = {lc, eei, energy_bar_index}}}
        local lcs = global.lc_entities
        lcs.center_pos_x = 0
        lcs.center_pos_y = 0
        local i = 1
        local dx = 0
        local dy = 0
        for k, v in pairs(lcs.entities) do
            if i == 1 then
                lcs.center_pos_x = v.lc.position.x
                lcs.center_pos_y = v.lc.position.y
            else
                dx = v.lc.position.x - lcs.center_pos_x
                dy = v.lc.position.y - lcs.center_pos_y

                lcs.center_pos_x = lcs.center_pos_x + dx * (1 / i)
                lcs.center_pos_y = lcs.center_pos_y + dy * (1 / i)
            end
            i = i + 1
        end
        game.print('center pos: ' .. lcs.center_pos_x .. ',' .. lcs.center_pos_y)

        -- recalc cc
        for index, v in pairs(global.cc_entities.entities) do
            if v.entity.valid then
                v.nearest_lc = calc_power_consumption(calc_distance_between_two_points(v.entity.position, v.nearest_lc.eei.position), v.nearest_lc.eei, 1)
            end
        end

        -- recalc rc
        for index, v in pairs(global.rc_entities.entities) do
            if v.entity.valid then
                v.nearest_lc = calc_power_consumption(calc_distance_between_two_points(v.entity.position, v.nearest_lc.eei.position), v.nearest_lc.eei, 2)
            end
        end

        -- set global_data_version
        global.global_data_version = 17
    end
end
