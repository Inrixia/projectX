local EntityBase = require("_EntityBase")

--- @class ControllerInstance
--- @field instances integer

--- @class ControllerStorarge
--- @field controller ControllerInstance

local interface = EntityBase.new(require("Controller_proto"))

--- @param storage ControllerStorarge
interface:onBuilt(function(event, storage)
	if storage.controller == nil then storage.controller = { instances = 0 } end
	storage.controller.instances = storage.controller.instances + 1
end)
