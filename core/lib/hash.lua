--- @param value string
--- @returns integer
local function hash(value)
	local hash = 5381
	for i = 1, #value do
		local char = string.byte(value, i)
		hash = (hash * 33) + char
		-- To keep it within Lua's integer limit, you can modulo it with a large prime
		hash = hash % 2147483647
	end
	return hash
end

return hash
