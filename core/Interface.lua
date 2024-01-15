local hash = require("lib/hash")

local NetworkedEntity = require("_NetworkedEntity")
local GuiElement = require("_GuiElement")

local Alerts = require("_Alerts")

--- @class NetInterface : NetEntity
NetInterface = {}
NetInterface.__index = NetInterface
setmetatable(NetInterface, { __index = NetEntity })
script.register_metatable("NetInterface", NetInterface)

function NetInterface:enable()
	self.entity.operable = true
	self.entity.get_inventory(defines.inventory.chest).set_bar()
end

function NetInterface:disable()
	self.entity.operable = false
	self.entity.get_inventory(defines.inventory.chest).set_bar(1)
end

function NetInterface:onNoChannels()
	Alerts.raise(self.entity, "Network overloaded! Not enough channels",
		"utility/too_far_from_roboport_icon")
	self:disable()
end

function NetInterface:onChannels()
	Alerts.resolve(self.unit_number, "Network overloaded! Not enough channels")
	self:enable()
end

function NetInterface:onNoEnergy()
	Alerts.raise(self.entity, "Network does not have enough energy!",
		"utility/electricity_icon_unplugged")
	self:disable()
end

function NetInterface:onEnergy()
	Alerts.resolve(self.unit_number, "Network does not have enough energy!")
	self:enable()
end

--- @class Interface : NetworkedEntity
local interface = NetworkedEntity.new(require("proto/Interface"), NetInterface)

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
		netEnt:setEnergy(-1000);
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
