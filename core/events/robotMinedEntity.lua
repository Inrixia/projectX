local EventHandler = require("EventHandler")

--- @alias onRobotMinedEntity fun(event:EventData.on_robot_mined_entity)

--- @class RobotMinedEntity : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: onRobotMinedEntity)
--- @field remove fun(self: EventHandler, prototypeName: string)
local robotMinedEntity = EventHandler.new(defines.events.on_robot_mined_entity, function(methods, filters)
	script.on_event(defines.events.on_robot_mined_entity, function(event)
		methods[event.entity.name](event)
	end, filters)
end, function(prototypeName) return { filter = "name", name = prototypeName } end)

return robotMinedEntity
