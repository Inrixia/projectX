local hash = require("lib/hash")

local NetworkedEntity = require("_NetworkedEntity")
local GuiElement = require("_GuiElement")

local Alerts = require("_Alerts")

--- @class Interface : NetworkedEntity
local interface = NetworkedEntity.new(require("Interface_proto"))

--- @param netStorage NetStorage
function interface.tick(netStorage)
	local entity = netStorage.entity

	if not netStorage.network:hasPower() then
		Alerts.raise(entity, "Network has no power!", "utility/electricity_icon_unplugged")
		interface.disable(netStorage)
		return
	end

	interface.enable(netStorage)
	Alerts.resolve(entity.unit_number)
end

interface:onEntityCreated(function(event)
	local entity = event.created_entity
	entity.get_inventory(defines.inventory.chest).set_bar(1)
	local netStorage = interface:getValidStorage(entity.unit_number)
	if netStorage == nil then return end
	interface.tick(netStorage)
end)

interface:onNthTick(30, function()
	for unit_number, netStorage in interface.storage:pairs() do
		if not netStorage.entity.valid then
			return interface.storage:set(unit_number, nil)
		end
		interface.tick(netStorage)
	end
end)

local filterButton =
	GuiElement.new("filterButton", { type = "choose-elem-button", elem_type = "item" })
	:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value
		local unit_number = changedEvent.element.tags.unit_number
		if type(unit_number) ~= "number" then return end

		local storage = interface:getValidStorage(unit_number)
		if storage == nil then return end
		local entity = storage.entity

		local inventory = entity.get_inventory(defines.inventory.chest)
		if inventory == nil then return end

		if selected_item == nil then
			entity.link_id = 0
			inventory.set_filter(1, nil)
			inventory.set_bar(1)
		elseif type(selected_item) == "string" then
			entity.link_id = hash(selected_item)
			inventory.set_filter(1, selected_item)
			inventory.set_bar()
		end
	end)

local interfaceGui = GuiElement
	.new("interfaceGui", function(parent)
		local thisGui = parent.add({ type = "frame", direction = "vertical" })
		thisGui.force_auto_center()
		return thisGui
	end)
	:withTitlebar("Interface Gui")
	:addChild(filterButton)
	:onClosed(function(event)
		event.element.visible = false
	end)

interface:onGuiOpened(function(openedEvent)
	local entity = openedEvent.entity
	if entity == nil then return end

	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory == nil then return end

	local player = game.players[openedEvent.player_index]
	local playerGui = player.gui.screen

	local luaInterfaceGui = interfaceGui:ensureOn(playerGui)
	local filterButton = GuiElement.getChild(luaInterfaceGui, filterButton.name)

	-- If invalid gui then reset element
	if filterButton == nil then
		luaInterfaceGui.destroy()
		player.opened = nil
		return
	end

	--- @diagnostic disable-next-line: assign-type-mismatch
	filterButton.elem_value = inventory.get_filter(1)
	filterButton.tags = { unit_number = entity.unit_number }

	luaInterfaceGui.visible = true
	-- player.opened = luaInterfaceGui
end)

--- @param netStorage NetStorage
function interface.disable(netStorage)
	if not netStorage.enabled then return end

	local entity = netStorage.entity
	entity.active = false
	entity.operable = false
	entity.get_inventory(defines.inventory.chest).set_bar(1)

	netStorage.enabled = false
end

--- @param netStorage NetStorage
function interface.enable(netStorage)
	if netStorage.enabled then return end

	local entity = netStorage.entity
	entity.active = true
	entity.operable = true
	entity.get_inventory(defines.inventory.chest).set_bar()

	netStorage.enabled = true
end
