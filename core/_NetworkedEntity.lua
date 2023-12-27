local EntityBase = require("_EntityBase")

--- @class NetworkedEntity : EntityBase
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	--- @param storage StorageWithNetwork
	self:onCreated(function(event, storage, unit_number)
		local entity = event.created_entity
		local adjacentEntities = self:findAdjacent(entity)

		storage.adjacent = {}
		if #adjacentEntities == 0 then
			Network.new():add(self.protoName, storage, unit_number)
		else
			--- @type StorageWithNetwork
			local adjacentStorage = self:getInstanceStorage(adjacentEntities[1].unit_number)

			adjacentStorage.network:add(self.protoName, storage, unit_number)
			table.insert(storage.adjacent, adjacentStorage)

			if #adjacentEntities ~= 1 then
				for i, adjacentEntity in ipairs(adjacentEntities) do
					if i ~= 1 then
						--- @type StorageWithNetwork
						adjacentStorage = self:getInstanceStorage(adjacentEntity.unit_number)
						table.insert(storage.adjacent, adjacentStorage)

						Network.merge(storage.network, adjacentStorage.network)
					end
				end
			end
		end

		print(storage.network.refsCount)
	end)

	--- @param storage StorageWithNetwork
	self:onRemoved(function(_, storage, unit_number)
		storage.network:remove(self.protoName, unit_number)
	end)

	return self
end

return NetworkedEntity
