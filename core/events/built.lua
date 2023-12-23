local builtEntity = require("builtEntity")
local robotBuiltEntity = require("robotBuiltEntity")

--- @alias onBuilt fun(event:EventData.on_built_entity|EventData.on_robot_built_entity)

--- @param prototypeName string
--- @param method onBuilt
function add(prototypeName, method)
	robotBuiltEntity:add(prototypeName, method)
	builtEntity:add(prototypeName, method)
end

--- @param prototypeName string
function remove(prototypeName)
	robotBuiltEntity:remove(prototypeName)
	builtEntity:remove(prototypeName)
end

return {
	add = add,
	remove = remove
}
