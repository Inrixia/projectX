--- @alias onBuiltEntity fun(event:EventData.on_built_entity)

local notRegistered = true

--- @type table<string, onBuiltEntity>
local on_built_entity_lookup = {}
--- @type LuaPlayerBuiltEntityEventFilter[]
local on_built_entity_filters = {}
--- @param prototypeName string
--- @param method onBuiltEntity
function onBuiltEntity(prototypeName, method)
	table.insert(on_built_entity_filters, { filter = "name", name = prototypeName })
	on_built_entity_lookup[prototypeName] = method;

	if notRegistered then
		notRegistered = false
		script.on_event(defines.events.on_built_entity, function(event)
			on_built_entity_lookup[event.created_entity.name](event)
		end, on_built_entity_filters)
	end
end

return onBuiltEntity
