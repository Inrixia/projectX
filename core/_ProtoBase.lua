--- @class ProtoBase
--- @field public prototypeName string
local ProtoBase = {}
ProtoBase.__index = ProtoBase

--- @param prototypeName string
--- @param atData fun(prototypeName: string)
function ProtoBase.new(prototypeName, atData)
	local self = setmetatable({}, ProtoBase)

	self.prototypeName = prototypeName

	if script == nil then atData(self.prototypeName) end

	return self
end

return ProtoBase
