local NetworkedEntity = require("_NetworkedEntity")

--- @class Controller : NetworkedEntity
local controller = NetworkedEntity.new(require("proto/Controller"))

local providesChannels = 4;

controller:onNthTick(30, function(netEnt)
	netEnt:setChannels(math.ceil(providesChannels *
		math.min(netEnt.entity.energy / netEnt.entity.electric_buffer_size, 1)))
end)
