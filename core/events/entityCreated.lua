local builtEntity = require("builtEntity")
local robotBuiltEntity = require("robotBuiltEntity")

--- @alias onEntityCreatedEvent EventData.on_built_entity|EventData.on_robot_built_entity
--- @alias onEntityCreated fun(event: onEntityCreatedEvent)

--- @param name string
--- @param method onEntityCreated
function add(name, method)
	robotBuiltEntity:add(name, method)
	builtEntity:add(name, method)
end

--- @param name string
function remove(name)
	robotBuiltEntity:remove(name)
	builtEntity:remove(name)
end

return {
	add = add,
	remove = remove
}
