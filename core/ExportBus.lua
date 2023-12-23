require("events/onBuilt")
require("events/onGuiOpened")
require("events/onGuiSelectionStateChanged")

local protoName = "projectX_export-bus"
local guiName = protoName .. "_gui"

--- @class ExportBus
local ExportBus = {}

-- Function to create the initial GUI with an item filter box
local function create_filter_box_gui(player)
	if player.gui.center.filter_box_gui == nil then
		local frame = player.gui.center.add { type = "frame", name = "filter_box_gui", direction = "vertical" }
		frame.add { type = "choose-elem-button", name = "item_filter_button", elem_type = "item" }
	end
end

--- @param event EventData.on_gui_selection_state_changed
local function create_item_selection_gui(event)
	local player = game.players[event.player_index]
	if player.gui.center.item_selection_gui == nil then
		local frame = player.gui.center.add { type = "frame", name = "item_selection_gui", direction = "vertical" }
		local flow = frame.add { type = "flow", name = "item_selection_flow", direction = "horizontal" }

		-- Add buttons for each item
		for _, item in pairs(game.item_prototypes) do
			flow.add { type = "sprite-button", name = "item_button_" .. item.name, sprite = "item/" .. item.name }
		end
	end
end

function ExportBus.RegisterEvents()
	onBuilt(protoName, function(event)
		event.created_entity.get_inventory(defines.inventory.chest).set_bar(1)
	end)
	onGuiOpened(protoName, function(event)
		local player = game.players[event.player_index]
		player.opened = nil
	end)
	onGuiSelectionStateChanged(guiName, create_item_selection_gui)
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
