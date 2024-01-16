local NetworkedEntity = require("_NetworkedEntity")
local NetEntity = require("_NetEntity")

--- @class NetCable : NetEntity
NetCable = {}
NetCable.__index = NetCable
setmetatable(NetCable, { __index = NetEntity })
script.register_metatable("NetCable", NetCable)

NetCable.energy = -100

function NetCable:enable()
	self.entity.temperature = 1
end

function NetCable:disable()
	self.entity.temperature = 0
end

NetworkedEntity.new(require("proto/Cable"), NetCable)
