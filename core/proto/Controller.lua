local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_controller", function(prototypeName)
	local entity = table.deepcopy(data.raw["lamp"]["small-lamp"])
	entity.name = prototypeName
	entity.gui_mode = "none"

	entity.energy_usage_per_tick = "250kW"
	entity.always_on = true

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
