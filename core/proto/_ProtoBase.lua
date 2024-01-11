--- @class ProtoBase
--- @field public protoName string
local ProtoBase = {}
ProtoBase.__index = ProtoBase

--- @param prototypeName string
--- @param atData fun(prototypeName: string)
function ProtoBase.new(prototypeName, atData)
	local self = setmetatable({}, ProtoBase)

	self.protoName = prototypeName

	if script == nil then atData(self.protoName) end

	return self
end

return ProtoBase
