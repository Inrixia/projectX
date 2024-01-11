local NetworkedEntity = require("_NetworkedEntity")

--- @class Controller : NetworkedEntity
local controller = NetworkedEntity.new(require("proto/Controller"))

local providesChannels = 4;

--- @param netEntity NetEntity
function controller.tick(netEntity)
	netEntity:setChannels(math.floor(math.min(netEntity.entity.energy / netEntity.entity.electric_drain, providesChannels)))
end

controller:onNthTick(30, controller.tick)
