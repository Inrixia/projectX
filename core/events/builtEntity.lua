local EventHandler = require("EventHandler")

--- @alias onBuilt fun(event:EventData.on_built_entity)

--- @class BuiltEntity : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onBuilt)
--- @field remove fun(self: EventHandler, name: string)
local builtEntity = EventHandler.new(defines.events.on_built_entity, function(methods, filters)
	script.on_event(defines.events.on_built_entity, function(event)
		methods[event.created_entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return builtEntity
