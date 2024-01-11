--- @class ObjectStorage
--- @field rootStorage table
--- @field key string
local ObjectStorage = {}
ObjectStorage.__index = ObjectStorage
script.register_metatable("ObjectStorage", ObjectStorage)

--- @param rootStorage table
--- @param key string
function ObjectStorage.new(rootStorage, key)
	if type(rootStorage) ~= "table" then error("rootStorage must be a table! Got type " .. type(rootStorage)) end
	local self = setmetatable({}, ObjectStorage)

	self.rootStorage = rootStorage
	self.key = key

	return self
end

--- @alias ObjectStorage.ensureStorage fun(self: ObjectStorage): table<any, any>
--- @type ObjectStorage.ensureStorage
function ObjectStorage:ensureRootStorage()
	local key = self.key
	if self.rootStorage[key] == nil then self.rootStorage[key] = {} end
	local rootStorage = self.rootStorage[key]

	--- @type ObjectStorage.ensureStorage
	self.ensureRootStorage = function() return rootStorage end
	return self:ensureRootStorage()
end

--- @generic T: table, K, V
--- @return fun(table: table<K, V>, index?: K): K, V
--- @return T
function ObjectStorage:pairs()
	if self.rootStorage[self.key] == nil then return pairs({}) end
	return pairs(self.rootStorage[self.key])
end

--- @generic K, V
--- @param index? K
--- @return K?
--- @return V?
function ObjectStorage:next(index)
	if self.rootStorage[self.key] == nil then return nil end
	return next(self.rootStorage[self.key], index)
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
