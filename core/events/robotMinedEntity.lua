local EventHandler = require("EventHandler")

--- @alias onRobotMinedEntity fun(event:EventData.on_robot_mined_entity)

--- @class RobotMinedEntity : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onRobotMinedEntity)
--- @field remove fun(self: EventHandler, name: string)
local robotMinedEntity = EventHandler.new(defines.events.on_robot_mined_entity, function(methods, filters)
	script.on_event(defines.events.on_robot_mined_entity, function(event)
		methods[event.entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return robotMinedEntity
