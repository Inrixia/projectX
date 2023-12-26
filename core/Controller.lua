local EntityBase = require("_EntityBase")

--- @class ControllerInstance
--- @field instances integer

--- @class ControllerStorage
--- @field controller ControllerInstance

local controller = EntityBase.new(require("Controller_proto"))

--- @param storage ControllerStorage
controller:onBuilt(function(event, storage)
	local entity = event.created_entity

	local adjacent = controller:findFirstAdjacent(entity)
	if adjacent == nil then
		storage.controller = { instances = 0 }
	else
		storage.controller = controller:getInstanceStorage(adjacent.unit_number).controller
	end

	storage.controller.instances = storage.controller.instances + 1
end)
