local builtEntity = require("builtEntity")
local robotBuiltEntity = require("robotBuiltEntity")
local scriptBuiltEntity = require("scriptBuiltEntity")
local scriptRevivedEntity = require("scriptRevivedEntity")

--- @alias onEntityCreatedEvent EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive
--- @alias onEntityCreated fun(event: onEntityCreatedEvent)

--- @param name string
--- @param method onEntityCreated
function add(name, method)
	robotBuiltEntity:add(name, method)
	builtEntity:add(name, method)
	scriptBuiltEntity:add(name, method)
	scriptRevivedEntity:add(name, method)
end

--- @param name string
function remove(name)
	robotBuiltEntity:remove(name)
	builtEntity:remove(name)
	scriptBuiltEntity:remove(name)
	scriptRevivedEntity:remove(name)
end

return {
	add = add,
	remove = remove
}
