local hash = require("lib/hash")

local EntityBase = require("EntityBase")
local GuiElement = require("GuiElement")

local interface = EntityBase.new("projectX_interface", function(prototypeName)
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

--- @class InterfaceStorage
--- @field filterButton GuiElement
--- @field entity LuaEntity

--- @param storage InterfaceStorage
interface:onBuilt(function(event, storage, unit_number)
	storage.entity = event.created_entity
	storage.entity.get_inventory(defines.inventory.chest).set_bar(1)
	storage.filterButton = GuiElement.new(
		"filterButton" .. unit_number,
		{ type = "choose-elem-button", elem_type = "item" }
	)
end)

--- @param storage InterfaceStorage
interface:onLoad(function(storage)
	storage.filterButton:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value
		local entity = storage.entity

		local inventory = entity.get_inventory(defines.inventory.chest)
		if inventory == nil then return end

		if selected_item == nil then
			entity.link_id = 0
			inventory.set_filter(1, selected_item)
			inventory.set_bar(1)
		elseif type(selected_item) == "string" then
			entity.link_id = hash(selected_item)
			inventory.set_filter(1, selected_item)
			inventory.set_bar()
		end
	end)
end)

--- @param storage InterfaceStorage
interface:onGuiOpened(function(openedEvent, storage, unit_number)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end
	local currentFilter = inventory.get_filter(1);

	local player = game.players[openedEvent.player_index]
	local playerGui = player.gui.screen

	local interfaceGui = GuiElement.addOrReplace(playerGui,
		{ type = "frame", name = entity.prototype.name, direction = "vertical" })
	GuiElement.addTitlebar(interfaceGui, "Interface Gui")

	local filterButton = storage.filterButton:addTo(interfaceGui)
	if currentFilter ~= nil then filterButton.elem_value = currentFilter end

	interfaceGui.force_auto_center()
	-- player.opened = interfaceGui.elem
end)

return interface
