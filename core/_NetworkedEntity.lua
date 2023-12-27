local EntityBase = require("_EntityBase")
local Network = require("_Network")

--- @class NetworkStorage
--- @field name string
--- @field network Network|nil
--- @field adjacent table<integer, NetworkStorage>

--- @class NetworkedEntity : EntityBase
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onCreated(function(event)
		local entity = event.created_entity
		local netStorage = NetworkedEntity.ensureNetStorage(entity)
		for _, adjacentEntity in pairs(self:findAdjacent(entity)) do
			local adjacentStorage = self.getNetStorage(adjacentEntity.unit_number)
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
	self:onRemoved(function(event)
		local unit_number = event.entity.unit_number
		local netEntities = self.ensureGlobalNetworkEntities()
		local netStorage = netEntities[unit_number]
		if netStorage == nil then return end
		local adjCount = 0
		for _, adjacentStorage in pairs(netStorage.adjacent) do
			adjCount = adjCount + 1
			adjacentStorage.adjacent[unit_number] = nil
		end
		netStorage.network:remove(unit_number, netStorage)
		if adjCount > 1 then Network.split(netStorage) end
		netEntities[unit_number] = nil
	end)

	return self
end

--- @param unit_number integer
function NetworkedEntity.getNetStorage(unit_number)
	return NetworkedEntity.ensureGlobalNetworkEntities()[unit_number]
end

function NetworkedEntity.ensureGlobalNetworkEntities()
	if global.networkEntites == nil then global.networkEntites = {} end

	NetworkedEntity.ensureGlobalNetworkEntities = function()
		--- @type table<integer, NetworkStorage>
		return global.networkEntites
	end
	return NetworkedEntity.ensureGlobalNetworkEntities()
end

--- @param entity LuaEntity
function NetworkedEntity.ensureNetStorage(entity)
	local netEntities = NetworkedEntity.ensureGlobalNetworkEntities()
	local unit_number = entity.unit_number
	if netEntities[unit_number] == nil then netEntities[unit_number] = { name = entity.name, adjacent = {} } end
	return netEntities[unit_number]
end

return NetworkedEntity
