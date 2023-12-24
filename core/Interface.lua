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
	storage.filterButton = GuiElement.new("filterButton" .. unit_number, {
		type = "choose-elem-button",
		elem_type = "item"
	})
end)

--- @param storage InterfaceStorage
interface:onLoad(function(storage)
	storage.filterButton:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value
		local entity = storage.entity
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

--- @param storage InterfaceStorage
interface:onGuiOpened(function(openedEvent, storage, unit_number)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end

	local player = game.players[openedEvent.player_index]
	local playerGui = player.gui.screen

	gui = game.player.gui.screen.add { type = "frame", name = "my-mod-gui", direction = "vertical" }
	gui.auto_center = true
	local titlebar = gui.add { type = "flow" }
	titlebar.drag_target = gui
	titlebar.add {
		type = "label",
		style = "frame_title",
		caption = caption,
		ignored_by_interaction = true,
	}
	local filler = titlebar.add {
		type = "empty-widget",
		style = "draggable_space",
		ignored_by_interaction = true,
	}
	filler.style.height = 24
	filler.style.horizontally_stretchable = true
	titlebar.add {
		type = "sprite-button",
		name = close_button_name,
		style = "frame_action_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		tooltip = { "gui.close-instruction" },
	}


	local guiInstance = storage.filterButton:open(playerGui)
	local currentFilter = inventory.get_filter(1);
	if currentFilter ~= nil then guiInstance:child("filterButton" .. unit_number).elem_value = currentFilter end

	guiInstance.elem.force_auto_center()
	player.opened = guiInstance.elem
end)

return interface
