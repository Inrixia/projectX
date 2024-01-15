local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_controller", function(prototypeName)
	local controller = table.deepcopy(data.raw["lamp"]["small-lamp"])
	controller.name = prototypeName
	controller.gui_mode = "none"

	controller.energy_usage_per_tick = "250kW"
	controller.always_on = true

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

	data:extend { controller, item, recipe }
end)
