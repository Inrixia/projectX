--- @class NetworkEvent
--- @field private netEnts NetEntity[]
--- @field public methodKey string
local NetworkEvent = {}
NetworkEvent.__index = NetworkEvent

script.register_metatable("NetworkEvent", NetworkEvent)

--- @param methodKey string
function NetworkEvent.new(methodKey)
	return setmetatable({ netEnts = {}, methodKey = methodKey }, NetworkEvent)
end

--- @param netEnt NetEntity
function NetworkEvent:add(netEnt)
	if netEnt[self.methodKey] == nil then return end
	self.netEnts[netEnt.unit_number] = netEnt
end

--- @param netEnt NetEntity
function NetworkEvent:remove(netEnt)
	self.netEnts[netEnt.unit_number] = nil
end

function NetworkEvent:execute(...)
	for unit_number, netEnt in pairs(self.netEnts) do
		if netEnt.entity.valid then
			netEnt[self.methodKey](netEnt, ...)
		else
			self.netEnts[unit_number] = nil
		end
	end
end

return NetworkEvent
