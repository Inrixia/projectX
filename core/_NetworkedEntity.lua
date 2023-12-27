local EntityBase = require("_EntityBase")

--- @class NetworkedEntity : EntityBase
--- @field getInstanceStorage fun(self: NetworkedEntity, unit_number: integer): StorageWithNetwork
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onCreated(function(event)
		local entity = event.created_entity

		local unit_number = entity.unit_number
		local storage = self:getInstanceStorage(unit_number)

		local adjacentEntities = self:findAdjacent(entity)
		if #adjacentEntities == 0 then
			Network.new():add(self.protoName, storage, unit_number)
		else
			self:getInstanceStorage(adjacentEntities[1].unit_number).network:add(self.protoName, storage, unit_number)
			if #adjacentEntities ~= 1 then
				for i, adjacentEntity in ipairs(adjacentEntities) do
					if i ~= 1 then
						Network.merge(storage.network, self:getInstanceStorage(adjacentEntity.unit_number).network)
					end
				end
			end
		end

		print(storage.network.refsCount)
	end)

	self:onRemoved(function(event)
		local entity = event.entity
		local unit_number = entity.unit_number

		local adjacentEntities = self:findAdjacent(entity)
		if #adjacentEntities == 1 then
			self:getInstanceStorage(unit_number).network:remove(self.protoName, unit_number)
		else

		end
	end)

	return self
end

return NetworkedEntity
