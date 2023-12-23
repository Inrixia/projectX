local hash = require("lib/hash")

local guiElemChanged = require("events/guiElemChanged")
local guiClosed = require("events/guiClosed")

local EntityBase = require("EntityBase")

local exportBus = EntityBase.new("projectX_export-bus")

exportBus:onBuilt(function(event)
	event.created_entity.get_inventory(defines.inventory.chest).set_bar(1)
end)
exportBus:onGuiOpened(function(openedEvent)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end

	local player = game.players[openedEvent.player_index]
	-- player.opened = nil

	local guiName = tostring(entity.unit_number)
	local protoElement = player.gui.center[guiName]
	if protoElement == nil then
		local frame = player.gui.center.add { type = "frame", name = guiName, direction = "vertical" }
		local button = frame.add { type = "choose-elem-button", elem_type = "item" }

		local currentFilter = inventory.get_filter(1);
		if currentFilter ~= nil then button.elem_value = currentFilter end

		guiElemChanged.add(button, player, function(changedEvent)
			local selected_item = changedEvent.element.elem_value;
			if type(selected_item) == "string" then
				entity.link_id = hash(selected_item)
				inventory.set_filter(1, selected_item)
				inventory.set_bar()
			end
		end)
	end
end)

exportBus:onData(function()
	local chest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
	chest.name = exportBus.prototypeName
	chest.inventory_size = 1
	chest.inventory_type = "with_filters_and_bar"
	chest.gui_mode = "none"

	-- Item
	local item = table.deepcopy(data.raw.item["transport-belt"])
	item.name = exportBus.prototypeName
	item.place_result = exportBus.prototypeName

	-- Recipe
	local recipe = {
		type = "recipe",
		name = exportBus.prototypeName,
		enabled = true,
		hidden = false,
		energy_required = 1,
		ingredients = {
			{ "iron-plate",         10 },
			{ "electronic-circuit", 10 },
			{ "inserter",           5 },
			{ "transport-belt",     5 },
		},
		result = exportBus.prototypeName,
	}

	data:extend { chest, item, recipe }
end)

return exportBus
