local hash = require("lib/hash")

local built = require("events/built")
local guiOpened = require("events/guiOpened")
local guiElemChanged = require("events/guiElemChanged")

local protoName = "projectX_export-bus"

--- @class ExportBus
local ExportBus = {}

function ExportBus.RegisterEvents()
	built.add(protoName, function(event)
		local entity = event.created_entity
		local inventory = entity.get_inventory(defines.inventory.chest)

		if inventory ~= nil then
			inventory.set_bar(1)

			local guiName = protoName .. "_" .. entity.unit_number

			guiOpened:add(entity.unit_number, function(event)
				local player = game.players[event.player_index]
				-- player.opened = nil
				if player.gui.center[guiName] == nil then
					local frame = player.gui.center.add { type = "frame", name = guiName, direction = "vertical" }
					local button = frame.add { type = "choose-elem-button", name = guiName .. "_button", elem_type = "item" }
					local currentFilter = inventory.get_filter(1);
					if currentFilter ~= nil then button.elem_value = currentFilter end
				end
			end)
			guiElemChanged:add(guiName .. "_button", function(event)
				local selected_item = event.element.elem_value;
				if type(selected_item) == "string" then
					entity.link_id = hash(selected_item)
					-- inventory = entity.get_inventory(defines.inventory.chest)
					inventory.set_filter(1, selected_item)
					inventory.set_bar()
				end
			end)
		end
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
