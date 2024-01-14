--- @class GenericEvent
--- @field private methods function[]
local GenericEvent = {}
GenericEvent.__index = GenericEvent

script.register_metatable("GenericEvent", GenericEvent)

function GenericEvent.new()
	return setmetatable({ methods = {} }, GenericEvent)
end

function GenericEvent:add(key, method)
	self.methods[key] = method
end

function GenericEvent:remove(key)
	self.methods[key] = nil
end

function GenericEvent:execute(...)
	for _, method in pairs(self.methods) do method(...) end
end

return GenericEvent
