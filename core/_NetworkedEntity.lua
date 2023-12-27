local EntityBase = require("_EntityBase")
local Network = require("_Network")

--- @class NetworkStorage
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
		local netStorage = NetworkedEntity.ensureNetStorage(entity.unit_number)
		for _, adjacentEntity in pairs(self:findAdjacent(entity)) do
			local adjacentStorage = self.getNetStorage(adjacentEntity.unit_number)
			if adjacentStorage ~= nil then
				if netStorage.network == nil then
					adjacentStorage.network:add(entity.name, entity.unit_number, netStorage)
				else
					Network.merge(netStorage.network, adjacentStorage.network)
				end
				netStorage.adjacent[adjacentEntity.unit_number] = adjacentStorage
				adjacentStorage.adjacent[entity.unit_number] = netStorage
			end
		end

		if netStorage.network == nil then
			Network.new():add(entity.name, entity.unit_number, netStorage)
		end

		print(netStorage.network.refsCount)
	end)
	self:onRemoved(function(event)
		local unit_number = event.entity.unit_number
		local netEntities = self.ensureGlobalNetworkEntities()
		local netStorage = netEntities[unit_number]
		if netStorage == nil then return end
		for _, adjacentStorage in pairs(netStorage.adjacent) do
			adjacentStorage.adjacent[unit_number] = nil
		end
		netEntities[unit_number] = nil

		--- Do stuff with netStorage.adjacent and netStorage.network to ensure its removed properly
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

--- @param unit_number integer
function NetworkedEntity.ensureNetStorage(unit_number)
	local netEntities = NetworkedEntity.ensureGlobalNetworkEntities()
	if netEntities[unit_number] == nil then netEntities[unit_number] = { adjacent = {} } end
	return netEntities[unit_number]
end

return NetworkedEntity
