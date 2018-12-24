--loader unlock
-- loader
if data.raw.recipe["loader"] ~= nil then
    data.raw.recipe["loader"].enabled = true
end
if data.raw.item["loader"] ~= nil then
    data.raw.item["loader"].flags = {"goes-to-quickbar"}
end

-- fast-loader
if data.raw.recipe["fast-loader"] ~= nil then
    data.raw.recipe["fast-loader"].enabled = true
end
if data.raw.item["fast-loader"] ~= nil then
    data.raw.item["fast-loader"].flags = {"goes-to-quickbar"}
end

-- express-loader
if data.raw.recipe["express-loader"] ~= nil then
    data.raw.recipe["express-loader"].enabled = true
end
if data.raw.item["express-loader"] ~= nil then
    data.raw.item["express-loader"].flags = {"goes-to-quickbar"}
end