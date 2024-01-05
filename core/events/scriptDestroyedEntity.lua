local EventHandler = require("EventHandler")

--- @alias onScriptDestroyedEntity fun(event:EventData.script_raised_destroy)

--- @class ScriptDestroyedEntity : EventHandler
--- @field set fun(self: EventHandler, name: string, method: onScriptDestroyedEntity)
--- @field remove fun(self: EventHandler, name: string)
local scriptDestroyedEntity = EventHandler.new(defines.events.script_raised_destroy, function(methods, filters)
	script.on_event(defines.events.script_raised_destroy, function(event)
		methods[event.entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return scriptDestroyedEntity
