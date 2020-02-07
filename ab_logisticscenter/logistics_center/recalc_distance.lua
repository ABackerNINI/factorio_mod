require('find_nearest_lc')
require('chest')

-- recalc distance from cc/rc to the nearest lc
-- call after lc entity being created or destoried
function recalc_distance()
    -- recalc cc
    for index, v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_cc(index)
        end
    end

    -- recalc rc
    for index, v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_rc(index)
        end
    end
end
