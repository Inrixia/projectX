--- @class GlobalStorage
--- @field public key any
local GlobalStorage = {}
GlobalStorage.__index = GlobalStorage

function GlobalStorage.new(key)
	local self = setmetatable({}, GlobalStorage)

	self.key = key

	return self
end

--- @alias GlobalStorage.ensureStorage fun(self: GlobalStorage): table<any, any>
--- @type GlobalStorage.ensureStorage
function GlobalStorage:ensureRootStorage()
	local key = self.key
	if global[key] == nil then global[key] = {} end
	local rootStorage = global[key]

	--- @type GlobalStorage.ensureStorage
	self.ensureRootStorage = function() return rootStorage end
	return self:ensureRootStorage()
end

--- @generic T: table, K, V
--- @return fun(table: table<K, V>, index?: K): K, V
--- @return T
function GlobalStorage:pairs()
	if global[self.key] == nil then return pairs({}) end
	return pairs(global[self.key])
end

--- @generic K, V
--- @param index? K
--- @return K?
--- @return V?
function GlobalStorage:next(index)
	if global[self.key] == nil then return nil end
	return next(global[self.key], index)
end

--- @alias GlobalStorage.set fun(self: GlobalStorage, key: any, value: any)
--- @type GlobalStorage.set
function GlobalStorage:set(key, value)
	local rootStorage = self:ensureRootStorage()

	--- @type GlobalStorage.set
	self.set = function(_, key, value) rootStorage[key] = value end
	return self:set(key, value)
end

--- @generic T
--- @alias GlobalStorage.ensure fun(self: GlobalStorage, key: any, default: T): T
--- @type GlobalStorage.ensure
function GlobalStorage:ensure(key, default)
	local rootStorage = self:ensureRootStorage()

	--- @type GlobalStorage.ensure
	self.ensure = function(_, key, default)
		rootStorage[key] = default
		return rootStorage[key]
	end
	return self:ensure(key, default)
end

--- @alias GlobalStorage.get fun(self: GlobalStorage, key: any): any
--- @type GlobalStorage.get
function GlobalStorage:get(key)
	local rootStorage = self:ensureRootStorage()

	--- @type GlobalStorage.get
	self.get = function(_, key) return rootStorage[key] end
	return self:get(key)
end

return GlobalStorage
