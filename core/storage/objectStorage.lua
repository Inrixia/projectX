--- @class ObjectStorage
--- @field key string
local ObjectStorage = {}
ObjectStorage.__index = ObjectStorage
script.register_metatable("ObjectStorage", ObjectStorage)

--- @param key string
function ObjectStorage.new(key)
	local self = setmetatable({}, ObjectStorage)

	self.key = key

	return self
end

--- @alias ObjectStorage.ensureStorage fun(self: ObjectStorage): table<any, any>
--- @type ObjectStorage.ensureStorage
function ObjectStorage:ensureRootStorage()
	local key = self.key
	if global[key] == nil then global[key] = {} end
	local rootStorage = global[key]

	--- @type ObjectStorage.ensureStorage
	self.ensureRootStorage = function() return rootStorage end
	return self:ensureRootStorage()
end

--- @generic T: table, K, V
--- @return fun(table: table<K, V>, index?: K): K, V
--- @return T
function ObjectStorage:pairs()
	if global[self.key] == nil then return pairs({}) end
	return pairs(global[self.key])
end

--- @generic K, V
--- @param index? K
--- @return K?
--- @return V?
function ObjectStorage:next(index)
	if global[self.key] == nil then return nil end
	return next(global[self.key], index)
end

--- @generic T
--- @alias ObjectStorage.set fun(self: ObjectStorage, key: any, value: T): T
--- @type ObjectStorage.set
function ObjectStorage:set(key, value)
	local rootStorage = self:ensureRootStorage()

	--- @type ObjectStorage.set
	self.set = function(_, key, value)
		rootStorage[key] = value
		return value
	end
	return self:set(key, value)
end

--- @generic T
--- @alias ObjectStorage.ensure fun(self: ObjectStorage, key: any, default: T): T
--- @type ObjectStorage.ensure
function ObjectStorage:ensure(key, default)
	local rootStorage = self:ensureRootStorage()

	--- @type ObjectStorage.ensure
	self.ensure = function(_, key, default)
		if rootStorage[key] == nil then rootStorage[key] = default end
		return rootStorage[key]
	end
	return self:ensure(key, default)
end

--- @alias ObjectStorage.get fun(self: ObjectStorage, key: any): any
--- @type ObjectStorage.get
function ObjectStorage:get(key)
	local rootStorage = self:ensureRootStorage()

	--- @type ObjectStorage.get
	self.get = function(_, key) return rootStorage[key] end
	return self:get(key)
end

return ObjectStorage
