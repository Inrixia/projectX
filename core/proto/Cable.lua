local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_cable", function(prototypeName)
	local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
	entity.name = prototypeName
	entity.heat_buffer.connections = {}

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
