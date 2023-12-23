--- @alias onRobotBuiltEntity fun(event:EventData.on_robot_built_entity)

local notRegistered = true

--- @type table<string, onRobotBuiltEntity>
local on_robot_built_entity_lookup = {}
--- @type LuaRobotBuiltEntityEventFilter[]
local on_robot_built_entity_filters = {}

--- @param prototypeName string
--- @param method onRobotBuiltEntity
function onRobotBuiltEntity(prototypeName, method)
	table.insert(on_robot_built_entity_filters, { filter = "name", name = prototypeName })
	on_robot_built_entity_lookup[prototypeName] = method;

	if notRegistered then
		notRegistered = false
		script.on_event(defines.events.on_robot_built_entity, function(event)
			on_robot_built_entity_lookup[event.created_entity.name](event)
		end, on_robot_built_entity_filters)
	end
end

return onRobotBuiltEntity
