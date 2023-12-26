local EntityBase = require("_EntityBase")

--- @class ControllerInstance
--- @field controllers integer

--- @class SharedReference
--- @field ref ControllerInstance

--- @class ControllerStorage
--- @field network SharedReference
--- @field adjacent table<ControllerStorage>

local controller = EntityBase.new(require("Controller_proto"))

--- @param storage ControllerStorage
controller:onCreated(function(event, storage)
	local entity = event.created_entity

	local adjacentEntities = controller:findAdjacent(entity)
	if #adjacentEntities == 0 then
		storage.network = { ref = { controllers = 1 } }
		storage.adjacent = {}
	elseif #adjacentEntities == 1 then
		--- @type ControllerStorage
		local adjacentStorage = controller:getInstanceStorage(adjacentEntities[1].unit_number)

		storage.adjacent = { adjacentStorage }
		table.insert(adjacentStorage.adjacent, storage)

		storage.network = adjacentStorage.network
		storage.network.ref.controllers = storage.network.ref.controllers + 1
	else
		storage.adjacent = {}
		for i, adjacentEntity in ipairs(adjacentEntities) do
			--- @type ControllerStorage
			local adjacentStorage = controller:getInstanceStorage(adjacentEntity.unit_number)
			table.insert(adjacentStorage.adjacent, storage)
			if i == 1 then
				storage.network = adjacentStorage.network
			else
				local thisNetwork = storage.network
				local adjacentNetwork = adjacentStorage.network
				if thisNetwork.ref ~= adjacentNetwork.ref then
					thisNetwork.ref.controllers = thisNetwork.ref.controllers + adjacentNetwork.ref.controllers
					adjacentNetwork.ref = thisNetwork.ref
				end
			end
			table.insert(storage.adjacent, adjacentStorage)
		end
		storage.network.ref.controllers = storage.network.ref.controllers + 1
	end
	print(storage.network.ref.controllers)
end)
