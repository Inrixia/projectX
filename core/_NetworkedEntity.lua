local EntityBase = require("_EntityBase")
local NetEntity = require("_NetEntity")
local ObjectStorage = require("storage/objectStorage")

local nthTick = require("events/nthTick")

--- @alias ProtoNetEntityStorage table<integer, NetEntity|nil>

--- @class NetEntityProtoStorage : ObjectStorage
--- @field next fun(self: ObjectStorage, protoName?: string): string?, table<string, ProtoNetEntityStorage>?
--- @field pairs fun(self: ObjectStorage): fun(table: table<string, ProtoNetEntityStorage>, protoName?: string): string, ProtoNetEntityStorage
--- @field ensure fun(self: ObjectStorage, protoName: string, default: ProtoNetEntityStorage): NetEntityStorage
--- @field set fun(self: ObjectStorage, protoName: string, value: ProtoNetEntityStorage | nil)
--- @field get fun(self: ObjectStorage, protoName: string): ProtoNetEntityStorage | nil

--- @class NetworkedEntity : EntityBase
--- @field protoStorage NetEntityProtoStorage
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

NetworkedEntity.protoStorage = ObjectStorage.new("netEntityByProto")

--- @param tick integer
--- @param method fun(netEntity: NetEntity, unit_number: integer, event: NthTickEventData, )
function NetworkedEntity:onNthTick(tick, method)
	nthTick.add(tick, function(event)
		for unit_number, netEntity in pairs(self.protoStorage:ensure(self.protoName, {})) do
			if netEntity.entity.valid then
				method(netEntity, unit_number, event)
			end
		end
	end)
end

--- @param method fun(netEntity: NetEntity, event: onEntityCreatedEvent)
function NetworkedEntity:onEntityCreatedWithStorage(method)
	self:onEntityCreated(function(event)
		method(NetEntity.from(event), event)
	end)
end

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onEntityCreated(function(event)
		local netEntity = NetEntity.from(event)
		self.protoStorage:ensure(self.protoName, {})[netEntity.unit_number] = netEntity
	end)

	self:onEntityRemoved(function(event)
		local netEntityStorage = self.protoStorage:get(self.protoName)
		if netEntityStorage ~= nil then
			local netEntity = netEntityStorage[event.entity.unit_number]
			if netEntity ~= nil then
				netEntity:remove();
				netEntityStorage[event.entity.unit_number] = nil
			end
		end
	end)

	return self
end

return NetworkedEntity
