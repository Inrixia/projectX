local ProtoBase = require("core/_ProtoBase")

return ProtoBase.new("projectX_controller", function(prototypeName)
	local entity = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
	entity.name = prototypeName
	entity.gui_mode = "none"
	entity.energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "250kW",
		render_no_power_icon = true,
		render_no_network_icon = true,
		emissions_per_minute = nil
	}
	entity.energy_usage = nil
	entity.energy_production = nil

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
