local hash = require("lib/hash")

local EntityBase = require("EntityBase")
local GuiElement = require("GuiElement")

local interface = EntityBase.new(require("Interface_proto"))

--- @class InterfaceStorage
--- @field entity LuaEntity

--- @param storage InterfaceStorage
interface:onBuilt(function(event, storage)
	storage.entity = event.created_entity
	storage.entity.get_inventory(defines.inventory.chest).set_bar(1)
end)

local filterButton = GuiElement.new("filterButton", { type = "choose-elem-button", elem_type = "item" })
filterButton:onChanged(function(changedEvent)
	local selected_item = changedEvent.element.elem_value
	local unit_number = changedEvent.element.tags.unit_number
	if type(unit_number) ~= "number" then return end

	local entity = interface:getInstanceStorage(unit_number).entity

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

local interfaceGui = GuiElement
	.new("interfaceGui", { type = "frame", direction = "vertical" })
	:withTitlebar("Interface Gui")
	:addChild(filterButton)

interface:onGuiOpened(function(openedEvent)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end
	local currentFilter = inventory.get_filter(1);

	local player = game.players[openedEvent.player_index]
	local playerGui = player.gui.screen

	local luaInterfaceGui = interfaceGui:ensureOn(playerGui)

	local filterButton = GuiElement.getChild(luaInterfaceGui, filterButton.name)

	filterButton.tags = { unit_number = entity.unit_number }
	--- @diagnostic disable-next-line: assign-type-mismatch
	filterButton.elem_value = currentFilter

	luaInterfaceGui.location = {
		x = (entity.position.x - player.position.x),
		y = (entity.position.y - player.position.y)
	}

	luaInterfaceGui.visible = true

	player.opened = luaInterfaceGui
end)
