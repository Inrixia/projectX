local calculateEntityDistance = require("control/lib/calculateEntityDistance")
local getMissingRequests = require("control/lib/getMissingRequests")

-- Class
local Requester = {
	name = "projectx-requester",
	itemName = "ProjectX Requester",
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
		for i, request in ipairs(getMissingRequests(requesterChest)) do
			local pickupPoint = requesterChest.logistic_network.select_pickup_point{name=request.name}
			if pickupPoint == nil then return end
			
			local distance = calculateEntityDistance(pickupPoint.owner.position, requesterChest.position)
			if distance > 0 then return end
		end
	end
end

return Requester