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
	if event.destroyed_entity.name ~= Requester.name then return end
	local entity = event.entity
	global.Requesters[entity.unit_number] = nil
end

function Requester:OnInit()
	global.Requesters = {}
end

return Requester