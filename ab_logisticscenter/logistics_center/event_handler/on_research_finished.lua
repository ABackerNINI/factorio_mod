require('config')
local TECH = require('logistics_center.technology')

local names = g_names

function on_research_finished(event)
    local research = event.research

    if string.match(research.name, names.tech_lc_capacity_pattern) ~= nil then
        TECH:research_lc_capacity(research)
    elseif string.match(research.name, names.tech_power_consumption_pattern) ~= nil then
        TECH:research_chest_power_consumption(research)
    end
end
