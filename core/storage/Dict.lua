--- @class Dict<T>
--- @field private __count integer
local Dict = {}
Dict.__index = Dict
script.register_metatable("Dict", Dict)

function Dict.new()
	return setmetatable({ __count = 0 }, Dict)
end

function Dict.__len(self)
	return self.__count
end

function Dict.__pairs(table)
	return function(t, k)
		local nextKey, nextValue
		nextKey, nextValue = next(t, k)
		if nextKey == "__count" then
			nextKey, nextValue = next(t, nextKey)
		end
		return nextKey, nextValue
	end, table, nil
end

function Dict.__newindex(self, key, value)
	rawset(self, key, value)
	self.__count = self.__count + 1
end

function Dict:remove(key)
	rawset(self, key, nil)
	self.__count = self.__count - 1
end

return Dict
