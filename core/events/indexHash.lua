--- @param a integer
--- @param b integer
--- @returns integer
local function indexHash(a, b)
	local global_index = 5381
	global_index = (global_index * 33) + a
	global_index = (global_index * 33) + b
	return global_index
end

return indexHash
