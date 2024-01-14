local NetworkedEntity = require("_NetworkedEntity")

--- @class Controller : NetworkedEntity
local controller = NetworkedEntity.new(require("proto/Controller"))

local providesChannels = 4;

--- @param netEnt NetEntity
function controller.tick(netEnt)
	netEnt:setChannels(math.ceil(providesChannels *
		math.min(netEnt.entity.energy / netEnt.entity.electric_buffer_size, 1)))
end

controller:onNthTick(30, controller.tick)
