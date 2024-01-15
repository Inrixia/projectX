local NetworkedEntity = require("_NetworkedEntity")

--- @class EnergyInjector : NetworkedEntity
local energyInjector = NetworkedEntity.new(require("proto/EnergyInjector"))

energyInjector
	:onNthTick(30, function(netEnt)
		netEnt:setEnergy(math.min(netEnt.entity.power_usage, netEnt.entity.energy))
		if netEnt.network.energy == 0 then return end
		netEnt.entity.power_usage = math.max((netEnt.network.energy * -1) + netEnt.energy, 0)

		netEnt:setEnergy(math.min(netEnt.entity.power_usage, netEnt.entity.energy))
		print(netEnt.network.energy, netEnt.entity.energy, netEnt.entity.power_usage)
	end)
