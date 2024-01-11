local NetworkedEntity = require("_NetworkedEntity")

--- @class Controller : NetworkedEntity
local controller = NetworkedEntity.new(require("proto/Controller"))

local providesChannels = 4;

--- @param netEntity NetEntity
function controller.tick(netEntity)
	netEntity:setChannels(math.ceil(providesChannels *
		math.min(netEntity.entity.energy / netEntity.entity.electric_buffer_size, 1)))
end

controller:onNthTick(30, controller.tick)
