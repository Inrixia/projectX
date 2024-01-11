--- @class Array
--- @field length integer
--- @field private items any[]
local Array = {}
Array.__index = Array

function Array.new()
	return setmetatable({ items = {}, length = 0 }, Array)
end

--- @param item any
function Array:add(item)
	table.insert(self.items, item)
	self.length = self.length + 1
end

--- @param index integer
--- @returns any
function Array:remove(index)
	self.length = math.max(0, self.length - 1)
	return table.remove(self.items, index)
end

return Array
