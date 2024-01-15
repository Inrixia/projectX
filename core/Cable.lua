local NetworkedEntity = require("_NetworkedEntity")
local NetEntity = require("_NetEntity")

--- @class NetCable : NetEntity
NetCable = {}
NetCable.__index = NetCable
setmetatable(NetCable, { __index = NetEntity })
script.register_metatable("NetCable", NetCable)

function NetCable:onChannels()
	self.entity.temperature = 1
end

function NetCable:onNoChannels()
	self.entity.temperature = 0
end

NetworkedEntity.new(require("proto/Cable"), NetCable)
