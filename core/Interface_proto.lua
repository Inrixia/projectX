local ProtoBase = require("ProtoBase")

return ProtoBase.new("projectX_interface", function(prototypeName)
	local chest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
	chest.name = prototypeName
	chest.inventory_size = 1
	chest.inventory_type = "with_filters_and_bar"
	chest.gui_mode = "none"

	-- Item
	local item = table.deepcopy(data.raw.item["transport-belt"])
	item.name = prototypeName
	item.place_result = prototypeName

	-- Recipe
	local recipe = {
		type = "recipe",
		name = prototypeName,
		enabled = true,
		hidden = false,
		energy_required = 1,
		ingredients = {
			{ "iron-plate",         10 },
			{ "electronic-circuit", 10 },
			{ "inserter",           5 },
			{ "transport-belt",     5 },
		},
		result = prototypeName,
	}

	data:extend { chest, item, recipe }
end)
