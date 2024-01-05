local EventHandler = require("EventHandler")

--- @alias onScriptBuiltEntity fun(event:EventData.script_raised_built)

--- @class ScriptBuiltEntity : EventHandler
--- @field set fun(self: EventHandler, name: string, method: onScriptBuiltEntity)
--- @field remove fun(self: EventHandler, name: string)
local scriptBuiltEntity = EventHandler.new(defines.events.script_raised_built, function(methods, filters)
	script.on_event(defines.events.script_raised_built, function(event)
		---@diagnostic disable-next-line: inject-field
		event.created_entity = event.entity
		methods[event.entity.name](event)
	end, filters)
end, function(name) return { filter = "name", name = name } end)

return scriptBuiltEntity
