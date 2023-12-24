local hash = require("lib/hash")

local EntityBase = require("EntityBase")
local GuiElement = require("GuiElement")

local exportBus = EntityBase.new("projectX_export-bus", function(prototypeName)
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

--- @class ExportBusStorage
--- @field guiElement GuiElement

--- @param storage ExportBusStorage
exportBus:onBuilt(function(event, storage)
	event.created_entity.get_inventory(defines.inventory.chest).set_bar(1)
	storage.guiElement = GuiElement.new(event.created_entity.prototype.name, {
		type = "choose-elem-button",
		elem_type = "item"
	})
end)

--- @param storage ExportBusStorage
exportBus:onLoad(function(storage)
	storage.guiElement:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value;
		local entity = changedEvent.element.entity
		if type(selected_item) == "string" then
			entity.link_id = hash(selected_item)
			local inventory = entity.get_inventory(defines.inventory.chest)
			if inventory ~= nil then
				inventory.set_filter(1, selected_item)
				inventory.set_bar()
			end
		end
	end)
end)

--- @param storage ExportBusStorage
exportBus:onGuiOpened(function(openedEvent, storage)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end

	local player = game.players[openedEvent.player_index]
	-- player.opened = nil

	local guiName = storage.guiElement.name
	local protoElement = player.gui.center[guiName]
	if protoElement == nil then
		local frame = player.gui.center.add { type = "frame", name = guiName .. "frame", direction = "vertical" }

		local button = storage.guiElement:addTo(frame)

		local currentFilter = inventory.get_filter(1);
		if currentFilter ~= nil then button.elem_value = currentFilter end
	end
end)

return exportBus
