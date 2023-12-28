local EntityBase = require("_EntityBase")
local Network = require("_Network")

local networkStorage = require("storage/networkedEntity")

--- @class NetworkedEntity : EntityBase
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onEntityCreated(function(event)
		local entity = event.created_entity
		local netStorage = networkStorage:ensure(entity.unit_number, { name = entity.name, adjacent = {} })
		for _, adjacentEntity in pairs(self:findAdjacent(entity)) do
			local adjacentStorage = networkStorage:get(adjacentEntity.unit_number)
			if adjacentStorage ~= nil then
				if netStorage.network == nil then
					adjacentStorage.network:add(entity.unit_number, netStorage)
				else
					Network.merge(netStorage.network, adjacentStorage.network)
				end
				netStorage.adjacent[adjacentEntity.unit_number] = adjacentStorage
				adjacentStorage.adjacent[entity.unit_number] = netStorage
			end
		end

		if netStorage.network == nil then
			Network.new():add(entity.unit_number, netStorage)
		end
		print(netStorage.network.refsCount)
	end)
	self:onEntityRemoved(function(event)
		local unit_number = event.entity.unit_number
		local netStorage = networkStorage:get(unit_number)
		if netStorage == nil then return end
		local adjCount = 0
		for _, adjacentStorage in pairs(netStorage.adjacent) do
			adjCount = adjCount + 1
			adjacentStorage.adjacent[unit_number] = nil
		end
		local tempNet = netStorage.network
		netStorage.network:remove(unit_number, netStorage)
		print(tempNet.refsCount)
		if adjCount > 1 then Network.split(netStorage) end
		networkStorage:set(unit_number, nil)
	end)

	return self
end

return NetworkedEntity
