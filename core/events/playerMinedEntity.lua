local EventHandler = require("EventHandler")

--- @alias onPlayerMinedEntity fun(event:EventData.on_player_mined_entity)

--- @class PlayerMinedEntity : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: onPlayerMinedEntity)
--- @field remove fun(self: EventHandler, prototypeName: string)
local playerMinedEntity = EventHandler.new(defines.events.on_player_mined_entity, function(methods, filters)
	script.on_event(defines.events.on_player_mined_entity, function(event)
		methods[event.entity.name](event)
	end, filters)
end, function(prototypeName) return { filter = "name", name = prototypeName } end)

return playerMinedEntity
