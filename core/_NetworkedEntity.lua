local EntityBase = require("_EntityBase")
local Network = require("_Network")

--- @class NetStorage
--- @field entity LuaEntity
--- @field enabled boolean
--- @field network Network|nil
--- @field adjacent table<integer, NetStorage>

--- @class NetworkedEntityStorage : GlobalStorage
--- @field next fun(self: GlobalStorage, unit_number?: integer): integer?, NetStorage?
--- @field pairs fun(self: GlobalStorage): fun(table: table<integer, NetStorage>, unit_number?: integer): integer, NetStorage
--- @field ensure fun(self: GlobalStorage, unit_number: integer, default: NetStorage): NetStorage
--- @field set fun(self: GlobalStorage, unit_number: integer, value: NetStorage | nil)
--- @field get fun(self: GlobalStorage, unit_number: integer): NetStorage | nil
--- @field getValid fun(self: GlobalStorage, unit_number: integer): NetStorage | nil

--- @class NetworkedEntity : EntityBase
--- @field storage NetworkedEntityStorage
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

NetworkedEntity.storage = require("storage/globalStorage").new("networkedEntity")

--- @param unit_number integer
function NetworkedEntity:getValidStorage(unit_number)
	local netStorage = self.storage:get(unit_number)
	if netStorage == nil then return nil end
	if not netStorage.entity.valid then
		self.storage:set(unit_number, nil)
		return nil
	end

	return netStorage
end

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onEntityCreated(function(event)
		local entity = event.created_entity
		local netStorage = self.storage:ensure(entity.unit_number, {
			entity = entity,
			adjacent = {},
			enabled = true
		})
		for _, adjacentEntity in pairs(self:findAdjacent(entity)) do
			local adjacentStorage = self.storage:get(adjacentEntity.unit_number)
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
	end)

	self:onEntityRemoved(function(event)
		local unit_number = event.entity.unit_number
		local netStorage = self.storage:get(unit_number)
		if netStorage == nil then return end
		local adjCount = 0
		for _, adjacentStorage in pairs(netStorage.adjacent) do
			adjCount = adjCount + 1
			adjacentStorage.adjacent[unit_number] = nil
		end
		netStorage.network:remove(unit_number, netStorage)
		if adjCount > 1 then Network.split(netStorage) end
		self.storage:set(unit_number, nil)
	end)

	return self
end

return NetworkedEntity
