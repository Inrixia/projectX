local EventHandler = require("EventHandler")

--- @alias onRobotBuiltEntity fun(event:EventData.on_robot_built_entity)

--- @class RobotBuiltEntity : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onRobotBuiltEntity)
--- @field remove fun(self: EventHandler, name: string)
local robotBuiltEntity = EventHandler.new(defines.events.on_robot_built_entity, function(methods, filters)
	script.on_event(defines.events.on_robot_built_entity, function(event)
		methods[event.created_entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return robotBuiltEntity
