local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_cable", function(prototypeName)
	local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
	entity.name = prototypeName
	entity.heat_buffer.connections = {}
	entity.heat_buffer.max_temperature = 100
	entity.heat_buffer.min_working_temperature = 0
	entity.heat_buffer.minimum_glow_temperature = 1
	entity.heat_buffer.default_temperature = 0
	-- Item
	local item = table.deepcopy(data.raw.item["iron-chest"])
	item.name = prototypeName
	item.place_result = prototypeName

	-- Recipe
	local recipe = {
		type = "recipe",
		name = prototypeName,
		result = prototypeName,
		ingredients = {}
	}

	data:extend { entity, item, recipe }
end)
