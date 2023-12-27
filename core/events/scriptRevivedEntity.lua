local EventHandler = require("EventHandler")

--- @alias onScriptRevivedEntity fun(event:EventData.script_raised_revive)

--- @class ScriptRevivedEntity : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onScriptRevivedEntity)
--- @field remove fun(self: EventHandler, name: string)
local scriptRevivedEntity = EventHandler.new(defines.events.script_raised_revive, function(methods, filters)
	script.on_event(defines.events.script_raised_revive, function(event)
		---@diagnostic disable-next-line: inject-field
		event.created_entity = event.entity
		methods[event.entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return scriptRevivedEntity
