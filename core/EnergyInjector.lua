local NetworkedEntity = require("_NetworkedEntity")

--- @class NetEnergyInjector : NetEntity
NetEnergyInjector = {}
NetEnergyInjector.__index = NetEnergyInjector
setmetatable(NetEnergyInjector, { __index = NetEntity })
script.register_metatable("NetEnergyInjector", NetEnergyInjector)

function NetEnergyInjector:onRequestEnergy()
	local entity = self.entity;
	entity.power_usage = math.max((self.network.energy * -1) + self.energy, 0)
	self:setEnergy(math.min(entity.power_usage, entity.energy))
end

--- @class EnergyInjector : NetworkedEntity
local energyInjector = NetworkedEntity.new(require("proto/EnergyInjector"), NetEnergyInjector)

energyInjector
	:onNthTick(30, function(netEnt)
		netEnt:onRequestEnergy()
	end)
