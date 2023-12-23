require("events/onBuilt")
require("events/onGuiOpened")

local protoName = "projectX-export_bus"

--- @class ExportBus
local ExportBus = {}

function ExportBus.RegisterEvents()
	onBuilt(protoName, function(event)
		event.created_entity.get_inventory(defines.inventory.chest).set_bar(0)
	end)
	onGuiOpened(protoName, function(event)
		local test = nil
	end)
end

function ExportBus.CreateProto()
	local invisibleChest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
	invisibleChest.name = protoName
	invisibleChest.inventory_size = 1
	invisibleChest.inventory_type = "with_filters_and_bar"
	invisibleChest.gui_mode = "none"

	-- Item
	local item = table.deepcopy(data.raw.item["transport-belt"])
	item.name = protoName
	item.place_result = protoName

	-- Recipe
	local recipe = {
		type = "recipe",
		name = protoName,
		enabled = true,
		hidden = false,
		energy_required = 1,
		ingredients = {
			{ "iron-plate",         10 },
			{ "electronic-circuit", 10 },
			{ "inserter",           5 },
			{ "transport-belt",     5 },
		},
		result = protoName,
	}

	data:extend { invisibleChest, item, recipe }
end

return ExportBus
