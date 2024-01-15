local ProtoBase = require("_ProtoBase")

return ProtoBase.new("projectX_energyInjector", function(prototypeName)
	local energyInjector = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
	energyInjector.name = prototypeName
	energyInjector.minable.result = prototypeName
	energyInjector.gui_mode = "none"

	energyInjector.energy_source = {
		type = "electric",
		buffer_capacity = "150kJ",
		usage_priority = "secondary-input",
		input_flow_limit = "300kW",
		output_flow_limit = "0W",
		drain = nil,
	}
	energyInjector.energy_production = nil

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

	data:extend { energyInjector, item, recipe }
end)
