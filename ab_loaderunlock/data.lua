--loader unlock
-- loader
if data.raw.recipe["loader"] ~= nil then
    data.raw.recipe["loader"].enabled = true
end
-- fast-loader
if data.raw.recipe["fast-loader"] ~= nil then
    data.raw.recipe["fast-loader"].enabled = true
end
-- express-loader
if data.raw.recipe["express-loader"] ~= nil then
    data.raw.recipe["express-loader"].enabled = true
end