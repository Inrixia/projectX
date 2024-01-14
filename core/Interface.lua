local hash = require("lib/hash")

local NetworkedEntity = require("_NetworkedEntity")
local GuiElement = require("_GuiElement")

local Alerts = require("_Alerts")

--- @class Interface : NetworkedEntity
local interface = NetworkedEntity.new(require("proto/Interface"))

local filterButton =
	GuiElement.new("filterButton", { type = "choose-elem-button", elem_type = "item" })
	:onChanged(function(changedEvent)
		local selected_item = changedEvent.element.elem_value
		local unit_number = changedEvent.element.tags.unit_number
		if type(unit_number) ~= "number" then return end

		local netEnt = NetEntity.getValid(unit_number)
		if netEnt == nil then return end
		local entity = netEnt.entity

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

interface
	:onEntityCreatedWithStorage(function(netEnt)
		netEnt.entity.get_inventory(defines.inventory.chest).set_bar(1)
		netEnt:setChannels(-1);
	end)
	:onEnabled(function(netEnt)

	end)
	:onNoChannels(function(netEnt)
		Alerts.raise(netEnt.entity, "Network overloaded! Not enough channels",
			"utility/too_far_from_roboport_icon")
		netEnt.entity.operable = false
		netEnt.entity.get_inventory(defines.inventory.chest).set_bar(1)
	end)
	:onChannels(function(netEnt)
		netEnt.entity.operable = true
		netEnt.entity.get_inventory(defines.inventory.chest).set_bar()
		Alerts.resolve(netEnt.unit_number)
	end)
	:onJoinedNetwork(function(netEnt)
		Alerts.resolve(netEnt.unit_number)
	end)
	:onGuiOpened(function(openedEvent)
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
