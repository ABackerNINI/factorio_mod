function position_to_string(p)
    return p.x .. ',' .. p.y
end

function surface_and_position_to_string(entity)
    return entity.surface.index .. ',' .. entity.position.x .. ',' .. entity.position.y
end

function calc_distance_between_two_points(p1, p2)
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end
