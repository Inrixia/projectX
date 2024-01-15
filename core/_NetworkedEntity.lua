local EntityBase = require("_EntityBase")
local ObjectStorage = require("storage/objectStorage")
local NetEntity = require("_NetEntity")

local nthTick = require("events/nthTick")

--- @alias ProtoNetEntityStorage table<integer, NetEntity|nil>

--- @class NetEntityProtoStorage : ObjectStorage
--- @field next fun(self: ObjectStorage, protoName?: string): string?, table<string, ProtoNetEntityStorage>?
--- @field pairs fun(self: ObjectStorage): fun(table: table<string, ProtoNetEntityStorage>, protoName?: string): string, ProtoNetEntityStorage
--- @field ensure fun(self: ObjectStorage, protoName: string, default: ProtoNetEntityStorage): NetEntityStorage
--- @field set fun(self: ObjectStorage, protoName: string, value: ProtoNetEntityStorage | nil)
--- @field get fun(self: ObjectStorage, protoName: string): ProtoNetEntityStorage | nil

--- @alias NetEntMethod fun(netEnt: NetEntity, ...)

--- @class NetworkedEntity : EntityBase
--- @field protoStorage NetEntityProtoStorage
--- @field Lookup table<string, NetworkedEntity>
--- @field NetEntClass NetEntity
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })
script.register_metatable("NetworkedEntity", NetworkedEntity)

NetworkedEntity.protoStorage = ObjectStorage.new("netEntByProto")
NetworkedEntity.Lookup = {}


--- @param protoBase ProtoBase
--- @param NetEntClass NetEntity?
function NetworkedEntity.new(protoBase, NetEntClass)
	--- @type NetworkedEntity
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)

	self.NetEntClass = NetEntClass or NetEntity

	self:onEntityCreated(function(event)
		local netEnt = self.NetEntClass:from(event)
		self.protoStorage:ensure(self.protoName, {})[netEnt.unit_number] = netEnt
	end)

	self:onEntityRemoved(function(event)
		local netEntStorage = self.protoStorage:get(self.protoName)
		if netEntStorage ~= nil then
			local netEnt = netEntStorage[event.entity.unit_number]
			if netEnt ~= nil then
				netEnt:destroy();
				netEntStorage[event.entity.unit_number] = nil
			end
		end
	end)

	return self
end

--- @param method NetEntMethod
function NetworkedEntity:forEachNetEntity(method, ...)
	for _, netEnt in pairs(self.protoStorage:ensure(self.protoName, {})) do
		if netEnt.entity.valid then
			method(netEnt, ...)
		end
	end
end

--- @param tick integer
--- @param method fun(netEnt: NetEntity, unit_number: integer, event: NthTickEventData, )
function NetworkedEntity:onNthTick(tick, method)
	nthTick.add(tick, function(event)
		self:forEachNetEntity(method, event)
	end)
	return self
end

--- @param method fun(netEnt: NetEntity, event: onEntityCreatedEvent)
function NetworkedEntity:onEntityCreatedWithStorage(method)
	self:onEntityCreated(function(event)
		method(self.NetEntClass:from(event), event)
	end)
	return self
end

return NetworkedEntity
