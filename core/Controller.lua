local NetworkedEntity = require("_NetworkedEntity")

local controller = NetworkedEntity.new(require("Controller_proto"))
-- local networkStorage = require("storage/networkedEntity")

controller:onNthTick(15, function()
end)
