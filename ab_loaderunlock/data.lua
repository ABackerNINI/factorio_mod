--loader recipe unlock

if data.raw.recipe["loader"] ~= nil then
    data.raw.recipe["loader"].enabled = true
end

if data.raw.recipe["fast-loader"] ~= nil then
    data.raw.recipe["fast-loader"].enabled = true
end

if data.raw.recipe["express-loader"] ~= nil then
    data.raw.recipe["express-loader"].enabled = true
end

--loader flags clear
--it has a flag "hidden",clear it or you can't use auto-upgrade

if data.raw.item["loader"] ~= nil then
    data.raw.item["loader"].flags = {}
end

if data.raw.item["fast-loader"] ~= nil then
    data.raw.item["fast-loader"].flags = {}
end

if data.raw.item["express-loader"] ~= nil then
    data.raw.item["express-loader"].flags = {}
end