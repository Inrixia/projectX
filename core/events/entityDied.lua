local EventHandler = require("EventHandler")

--- @alias onEntityDied fun(event:EventData.on_entity_died)

--- @class EntityDied : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: onEntityDied)
--- @field remove fun(self: EventHandler, prototypeName: string)
local entityDied = EventHandler.new(defines.events.on_entity_died, function(methods, filters)
	script.on_event(defines.events.on_entity_died, function(event)
		methods[event.entity.name](event)
	end, filters)
end, function(prototypeName) return { filter = "name", name = prototypeName } end)

return entityDied
