--- @type callOn
local callOn = require("__projectX__/core/lib/object")
local ProtoBase = require("_ProtoBase")

local function escapePattern(text)
	return text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

return ProtoBase.new("projectX_cable", function(prototypeName)
	local cable = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
	cable.name = prototypeName
	cable.minable.result = prototypeName
	cable.heat_buffer.connections = {}
	cable.heat_buffer.max_temperature = 1
	cable.heat_buffer.min_working_temperature = 0
	cable.heat_buffer.minimum_glow_temperature = 0
	cable.heat_buffer.default_temperature = 0

	local base = escapePattern("__base__/graphics/entity/heat-pipe")
	local new = "__projectX__/graphics/cable-blue"

	--- @param spriteParams data.SpriteParameters
	callOn(cable.heat_glow_sprites, "filename", function(spriteParams)
		spriteParams.filename = spriteParams.filename:gsub(base, new)
		spriteParams.draw_as_glow = true
	end)
	--- @param spriteParams data.SpriteParameters
	callOn(cable.connection_sprites, "filename", function(spriteParams)
		spriteParams.filename = spriteParams.filename:gsub(base, new)
	end)

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
