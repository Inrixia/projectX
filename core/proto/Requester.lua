local calculateEntityDistance = require("core/lib/calculateEntityDistance")
local getMissingRequests = require("core/lib/getMissingRequests")

-- Class
local Requester = {
	entityName = "projectx-requester",
	itemName = "projectx-requester-item",
	minTickInterval = 15,
	maxTickInterval = 300,
	maxTransferAmount = 100
}
Requester.__index = Requester
script.register_metatable("projectx-requester-metatable", Requester)

-- Instance creation
function Requester.New(entity)
	return setmetatable({entity = entity, nextTick = 0, tickInterval = Requester.maxTickInterval}, Requester)
end

-- Instance methods
function Requester:setNextTick(hasMoreWork, tick)
	if hasMoreWork then
		if self.tickInterval > Requester.minTickInterval then
			self.tickInterval = self.tickInterval - Requester.minTickInterval;
		end
	else
		if self.tickInterval < Requester.maxTickInterval then
			self.tickInterval = self.tickInterval + Requester.minTickInterval;
		end
	end
	self.nextTick = tick + self.tickInterval;
end

function Requester:onTick(tick)
	if self.nextTick <= tick then
		for _, player in pairs(game.players) do
			player.print(self.tickInterval)
		end
		self:setNextTick(self:processRequests(), tick)
	end
end

function Requester:processRequests()
	if self.entity.logistic_network == nil then return false end

	local nearestCell = self.entity.logistic_network.find_cell_closest_to(self.entity.position)
	if (nearestCell.owner == nil) then return false end
	if (nearestCell.owner.energy < 100000) then return false end

	local amountTransferred = 0;
	for i, itemRequest in pairs(getMissingRequests(self.entity)) do
		while itemRequest.count > 0 do
			if amountTransferred >= Requester.maxTransferAmount then return true end

			local pickupPoint = self.entity.logistic_network.select_pickup_point{name=itemRequest.name}
			if pickupPoint == nil then
				break
			end

			local pickupInventory = pickupPoint.owner.get_inventory(defines.inventory.chest)
			local requesterInventory = self.entity.get_inventory(defines.inventory.chest)

			local pickupInventoryAvalible = pickupInventory.get_item_count(itemRequest.name)

			local transferAmount = math.min(pickupInventoryAvalible, Requester.maxTransferAmount)
			if transferAmount > 0 then
				local distance = calculateEntityDistance(pickupPoint.owner.position, self.entity.position)
				local requiredPower = transferAmount*distance*(global.ExchangeRate[itemRequest.name] or 1)

				if nearestCell.owner.energy < requiredPower then break end
				nearestCell.owner.energy = nearestCell.owner.energy - requiredPower

				pickupInventory.remove{name = itemRequest.name, count = transferAmount}
				requesterInventory.insert{name = itemRequest.name, count = transferAmount}
				itemRequest.count = itemRequest.count - transferAmount
				amountTransferred = amountTransferred + transferAmount
			end
		end
	end

	-- If the amount transferred is not 0 then we can assume there is more to transfer
	return amountTransferred ~= 0
end

-- Static methods
function Requester.BuildProto()
	-- Entity
	local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
	entity.name = Requester.entityName
	entity.inventory_size = 12*100
	entity.gui_mode = "none"
	entity.minable.result = Requester.itemName

	-- Item
	local item = table.deepcopy(data.raw.item["logistic-chest-requester"])
	item.name = Requester.itemName
	item.place_result = entity.name

	-- Recipe
	local recipe = table.deepcopy(data.raw.recipe["logistic-chest-requester"])
	recipe.enabled = true
	recipe.name = item.name
	recipe.ingredients = {{"iron-plate", 1}}
	recipe.result = item.name

	data:extend{item, recipe, entity}
end
-- Static event methods
function Requester.OnInit()
	global.Requesters = {}
end

function Requester.OnCreate(event)
	-- TODO: FIX Handlers as event is multiple types
	if event.created_entity.name ~= Requester.entityName then return end
	global.Requesters[event.created_entity.unit_number] = Requester.New(event.created_entity);
end

function Requester.OnDestroy(event)
	-- TODO: FIX Handlers as event is multiple types
	if event.entity.name ~= Requester.entityName then return end
	global.Requesters[event.entity.unit_number] = nil
end

function Requester.OnTick(tick)
	for unit_number, requester in pairs(global.Requesters) do
		requester:onTick(tick)
	end
end

return Requester