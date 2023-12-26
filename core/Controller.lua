local EntityBase = require("_EntityBase")

--- @class Network
--- @field controllers integer
--- @field id integer
Network = {}
Network.__index = Network

--- @type (Network|integer)[]
local networkInstances = {}

function Network.new()
	local networkId = #networkInstances + 1

	local self = setmetatable({ id = networkId }, Network)
	networkInstances[networkId] = self

	self.controllers = 0

	return self
end

function Network.getNetwork(networkId)
	local theNetwork = networkInstances[networkId]
	if (type(theNetwork) == "number") then
		--- @type Network
		return Network.getNetwork(theNetwork)
	end

	--- @type Network
	return theNetwork
end

-- Function to merge two networks
function Network:merge(networkId)
	local srcNetwork = Network.getNetwork(networkId)
	if self.id == srcNetwork.id then return end
	self.controllers = self.controllers + srcNetwork.controllers
	-- Overwrite reference to save memory
	networkInstances[networkId] = self.id
end

--- @class ControllerStorage
--- @field networkId integer

local controller = EntityBase.new(require("Controller_proto"))

--- @param storage ControllerStorage
controller:onCreated(function(event, storage)
	local entity = event.created_entity

	local adjacentEntities = controller:findAdjacent(entity)
	if #adjacentEntities == 0 then
		storage.networkId = Network.new().id
	else
		--- @type ControllerStorage
		local adjacentStorage = controller:getInstanceStorage(adjacentEntities[1].unit_number)
		storage.networkId = adjacentStorage.networkId

		local thisNetwork = Network.getNetwork(storage.networkId)
		if #adjacentEntities ~= 1 then
			for i, adjacentEntity in ipairs(adjacentEntities) do
				if i ~= 1 then
					adjacentStorage = controller:getInstanceStorage(adjacentEntity.unit_number)
					local adjacentNetwork = Network.getNetwork(adjacentStorage.networkId)
					if thisNetwork.id ~= adjacentNetwork.id then
						thisNetwork:merge(adjacentNetwork.id)
					end
				end
			end
		end
	end
	local thisNetwork = Network.getNetwork(storage.networkId)
	thisNetwork.controllers = thisNetwork.controllers + 1
	print(thisNetwork.controllers, countTableItems(global.entities.projectX_controller))
end)

function countTableItems(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end
