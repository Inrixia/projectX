local hash = require("lib/hash")

local NetworkedEntity = require("_NetworkedEntity")
local GuiElement = require("_GuiElement")

local Alerts = require("_Alerts")

--- @class Interface : NetworkedEntity
local interface = NetworkedEntity.new(require("proto/Interface"))


--- @param netEntity NetEntity
function interface.tick(netEntity)
	local entity = netEntity.entity

	if netEntity.network.channels < 0 then
		Alerts.raise(entity, "Network overloaded! Not enough channels", "utility/too_far_from_roboport_icon")
		if entity.active then
			entity.active = false
			entity.operable = false
			entity.get_inventory(defines.inventory.chest).set_bar(1)
		end
		return
	end

	if not entity.active then
		entity.active = true
		entity.operable = true
		entity.get_inventory(defines.inventory.chest).set_bar()
	end
	Alerts.resolve(entity.unit_number)
end

interface:onEntityCreatedWithStorage(function(netEntity)
	netEntity.entity.get_inventory(defines.inventory.chest).set_bar(1)
	netEntity:setChannels(-1);
	interface.tick(netEntity)
end)

interface:onNthTick(30, interface.tick)

local filterButton =
	GuiElement.new("filterButton", { type = "choose-elem-button", elem_type = "item" })
	:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value
		local unit_number = changedEvent.element.tags.unit_number
		if type(unit_number) ~= "number" then return end

		local netEntity = NetEntity.getValid(unit_number)
		if netEntity == nil then return end
		local entity = netEntity.entity

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
	player.opened = luaInterfaceGui
end)
