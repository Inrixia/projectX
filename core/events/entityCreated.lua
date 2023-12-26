local builtEntity = require("builtEntity")
local robotBuiltEntity = require("robotBuiltEntity")

--- @alias onEntityCreatedEvent EventData.on_built_entity|EventData.on_robot_built_entity
--- @alias onEntityCreated fun(event: onEntityCreatedEvent)

--- @param prototypeName string
--- @param method onEntityCreated
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
