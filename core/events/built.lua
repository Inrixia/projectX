local builtEntity = require("builtEntity")
local robotBuiltEntity = require("robotBuiltEntity")

--- @alias onBuiltEvent EventData.on_built_entity|EventData.on_robot_built_entity
--- @alias onBuilt fun(event: onBuiltEvent)

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
