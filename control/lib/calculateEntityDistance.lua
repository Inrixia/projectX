-- Cache table
local distanceCache = {}

local function calculateEntityDistance(point1, point2)
    -- Handle identical points
    if point1.x == point2.x and point1.y == point2.y then
        return 0
    end
    
    -- Arrange points to canonicalize the pair (smaller comes first)
    if point1.x > point2.x or (point1.x == point2.x and point1.y > point2.y) then
        point1, point2 = point2, point1
    end

    -- Generate a unique string key for the pair of points
    local key = string.format("%.1f_%.1f_%.1f_%.1f", point1.x, point1.y, point2.x, point2.y)

    -- Check the cache
    if distanceCache[key] then
        return distanceCache[key]
    end

    -- Calculate the distance
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Store the result in the cache
    distanceCache[key] = distance

    return distance
end

return calculateEntityDistance
