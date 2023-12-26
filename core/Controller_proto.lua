local ProtoBase = require("core/_ProtoBase")

return ProtoBase.new("projectX_controller", function(prototypeName)
	local entity = table.deepcopy(data.raw["wall"]["stone-wall"])
	entity.name = prototypeName

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
