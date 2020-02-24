require('config')

-- energy bar
EB = {}

local names = g_names
local config = g_config
local startup_settings = g_startup_settings

local math_ceil = math.ceil

local check_on_nth_tick = config.check_energy_bar_on_nth_tick
if check_on_nth_tick == g_startup_settings.check_cc_on_nth_tick then
    check_on_nth_tick = check_on_nth_tick + 1
end
if check_on_nth_tick == g_startup_settings.check_rc_on_nth_tick then
    check_on_nth_tick = check_on_nth_tick + 1
end

-- Check energy bars on every nth tick
local function energy_bar_check_on_nth_tick(tick)
    local bar_max = 13.0
    local g_ebs = global.energy_bar_entities.entities
    for k, v in pairs(g_ebs) do
        local bar_index = math_ceil(bar_max * v.eei.energy / (startup_settings.lc_buffer_capacity * 1000000))
        if bar_index > bar_max then
            bar_index = bar_max
        end
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

function EB:re_register_handler()
    -- Re-register conditional handler
    if global.energy_bar_entities ~= nil and global.energy_bar_entities.count >= 1 then
        script.on_nth_tick(check_on_nth_tick, energy_bar_check_on_nth_tick)
    end
end

-- Create energy bar for the logistics center
function EB:add(lc_pack)
    local bar_max = 13.0
    local bar_index = math_ceil(bar_max * lc_pack.eei.energy / (startup_settings.lc_buffer_capacity * 1000000))
    if bar_index > bar_max then
        bar_index = bar_max
    end
    local eb =
        lc_pack.eei.surface.create_entity {
        name = names.energy_bar .. bar_index,
        position = {x = lc_pack.eei.position.x, y = lc_pack.eei.position.y + 0.9}
    }

    -- caution: loop with big number
    local g_energy_bar = global.energy_bar_entities
    local g_energy_bar_entities = g_energy_bar.entities
    for index = 1, 1000000000 do
        if g_energy_bar_entities[index] == nil then
            lc_pack.energy_bar_index = index
            g_energy_bar_entities[index] = {
                energy_bar = eb,
                bar_index = bar_index,
                eei = lc_pack.eei
            }

            g_energy_bar.count = g_energy_bar.count + 1
            if g_energy_bar.count == 1 then
                -- game.print('check')
                script.on_nth_tick(check_on_nth_tick, energy_bar_check_on_nth_tick)
            end
            break
        end
    end
end

-- Destroy energy bar for the logistics center
function EB:remove(lc_pack)
    if lc_pack.energy_bar_index ~= nil then
        local g_ebs = global.energy_bar_entities.entities
        g_ebs[lc_pack.energy_bar_index].energy_bar.destroy()
        g_ebs[lc_pack.energy_bar_index] = nil
        lc_pack.energy_bar_index = nil

        local g_energy_bar = global.energy_bar_entities
        g_energy_bar.count = g_energy_bar.count - 1
        if g_energy_bar.count == 0 then
            script.on_nth_tick(check_on_nth_tick, nil)
        end
    end
end

return EB
