require('config')

-- energy bar
EB = {}

local names = g_names
local config = g_config

-- Check energy bars on every nth tick
local function energy_bar_check_on_nth_tick(tick)
    local bar_max = 13.0
    local g_ebs = global.energy_bar_entities.entities
    for k, v in pairs(g_ebs) do
        local bar_index = math.ceil(bar_max * v.eei.energy / config.eei_buffer_capacity)
        if v.bar_index ~= bar_index then
            v.energy_bar.destroy()
            v.energy_bar =
                v.eei.surface.create_entity {
                name = names.energy_bar .. bar_index,
                position = {x = v.eei.position.x, y = v.eei.position.y + 0.9}
            }
            v.bar_index = bar_index
        end
    end
end

-- Create energy bar for the logistics center
function EB:add(g_lc)
    local bar_max = 13.0
    local bar_index = math.ceil(bar_max * g_lc.eei.energy / config.eei_buffer_capacity)
    local eb =
        g_lc.eei.surface.create_entity {
        name = names.energy_bar .. bar_index,
        position = {x = g_lc.eei.position.x, y = g_lc.eei.position.y + 0.9}
    }

    -- caution: loop with big number
    local g_energy_bar = global.energy_bar_entities
    local g_energy_bar_entities = g_energy_bar.entities
    for index = 1, 1000000000 do
        if g_energy_bar_entities[index] == nil then
            g_lc.energy_bar_index = index
            g_energy_bar_entities[index] = {
                energy_bar = eb,
                bar_index = bar_index,
                eei = g_lc.eei
            }

            g_energy_bar.count = g_energy_bar.count + 1
            if g_energy_bar.count == 1 then
                -- game.print('check')
                script.on_nth_tick(20, energy_bar_check_on_nth_tick)
            end
            break
        end
    end
end

-- Destory energy bar for the logistics center
function EB:remove(g_lc)
    if g_lc.energy_bar_index ~= nil then
        local g_ebs = global.energy_bar_entities.entities
        g_ebs[g_lc.energy_bar_index].energy_bar.destroy()
        g_ebs[g_lc.energy_bar_index] = nil
        g_lc.energy_bar_index = nil

        local g_energy_bar = global.energy_bar_entities
        g_energy_bar.count = g_energy_bar.count - 1
        if g_energy_bar.count == 0 then
            script.on_nth_tick(20, nil)
        end
    end
end

return EB
