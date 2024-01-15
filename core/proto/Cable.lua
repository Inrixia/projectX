local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_cable", function(prototypeName)
	local cable = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
	cable.name = prototypeName
	cable.minable.result = prototypeName
	cable.heat_buffer.connections = {}
	cable.heat_buffer.max_temperature = 1
	cable.heat_buffer.min_working_temperature = 0
	cable.heat_buffer.minimum_glow_temperature = 0
	cable.heat_buffer.default_temperature = 0
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

	data:extend { cable, item, recipe }
end)
