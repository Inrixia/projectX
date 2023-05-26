local calculateEntityDistance = require("control/lib/calculateEntityDistance")
local getMissingRequests = require("control/lib/getMissingRequests")

-- Class
local Requester = {
	name = "projectx-requester",
	itemName = "projectx-requester-item",
}

function Requester:BuildProto()
	-- Entity
	local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
	entity.name = Requester.name
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

function Requester:OnCreate(event)
	if event.created_entity.name ~= Requester.name then return end
	local entity = event.created_entity
	global.Requesters[entity.unit_number] = entity
end

function Requester:OnDestroy(event)
	if event.entity.name ~= Requester.name then return end
	local entity = event.entity
	global.Requesters[entity.unit_number] = nil
end

function Requester:OnInit(event)
	global.Requesters = {}
end

function Requester:OnTick(event)
	for unit_number, requesterChest in pairs(global.Requesters) do

		if requesterChest.logistic_network == nil then goto continue end

		local nearestCell = requesterChest.logistic_network.find_cell_closest_to(requesterChest.position)
		if (nearestCell.owner == nil) then goto continue end
		if (nearestCell.owner.energy < 100000) then goto continue end

		for i, request in pairs(getMissingRequests(requesterChest)) do
			while request.count > 0 do
				local pickupPoint = requesterChest.logistic_network.select_pickup_point{name=request.name}
				if pickupPoint == nil then
					break
				end
				local pickupInventory = pickupPoint.owner.get_inventory(defines.inventory.chest)
				local requesterInventory = requesterChest.get_inventory(defines.inventory.chest)

				local pickupInventoryAvalible = pickupInventory.get_item_count(request.name)

				local maxTransferAmount = 1;

				local transferAmount = math.min(pickupInventoryAvalible, maxTransferAmount)
				if transferAmount > 0 then
					local distance = calculateEntityDistance(pickupPoint.owner.position, requesterChest.position)
					local requiredPower = transferAmount*distance*1000

					if nearestCell.owner.energy < requiredPower then goto continue end
					nearestCell.owner.energy = nearestCell.owner.energy - requiredPower

					pickupInventory.remove{name = request.name, count = transferAmount}
					requesterInventory.insert{name = request.name, count = transferAmount}
					request.count = maxTransferAmount - transferAmount
				end
			end
		end
		::continue::
	end
end

return Requester