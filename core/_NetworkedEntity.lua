local EntityBase = require("_EntityBase")
local Network = require("_Network")

--- @class NetworkedEntity : EntityBase
--- @field getInstanceStorage fun(self: NetworkedEntity, unit_number: integer): StorageWithNetwork
NetworkedEntity = {}
NetworkedEntity.__index = NetworkedEntity
setmetatable(NetworkedEntity, { __index = EntityBase })

--- @param protoBase ProtoBase
function NetworkedEntity.new(protoBase)
	local self = setmetatable(EntityBase.new(protoBase), NetworkedEntity)
	--- @cast self NetworkedEntity

	self:onCreated(Network.onEntityCreated)
	self:onRemoved(Network.onEntityRemoved)

	return self
end

return NetworkedEntity
