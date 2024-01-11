-- --- @class GlobalArray
-- --- @field public key any
-- local GlobalArray = {}
-- GlobalArray.__index = GlobalArray

-- function GlobalArray.new(key)
-- 	local self = setmetatable({}, GlobalArray)

-- 	self.key = key

-- 	return self
-- end

-- --- @alias GlobalArray.ensureStorage fun(self: GlobalArray): any[]
-- --- @type GlobalArray.ensureStorage
-- function GlobalArray:ensureRootStorage()
-- 	local key = self.key
-- 	if global[key] == nil then global[key] = {} end
-- 	local rootStorage = global[key]

-- 	--- @type GlobalArray.ensureStorage
-- 	self.ensureRootStorage = function() return rootStorage end
-- 	return self:ensureRootStorage()
-- end

-- --- @generic T: table, V
-- --- @return fun(table: V[], i?: integer):integer, V
-- --- @return T
-- --- @return integer i
-- function GlobalArray:ipairs()
-- 	if global[self.key] == nil then return ipairs({}) end
-- 	return ipairs(global[self.key])
-- end

-- --- @generic K, V
-- --- @param index? K
-- --- @return K?
-- --- @return V?
-- function GlobalArray:next(index)
-- 	if global[self.key] == nil then return nil end
-- 	return next(global[self.key], index)
-- end

-- --- @alias GlobalArray.add fun(self: GlobalArray, value: any): integer
-- --- @type GlobalArray.add
-- function GlobalArray:add(value)
-- 	local rootStorage = self:ensureRootStorage()

-- 	--- @type GlobalArray.add
-- 	self.add = function(_, value)
-- 		table.insert(rootStorage, value)
-- 		return #rootStorage
-- 	end
-- 	return self:add(value)
-- end

-- --- @alias GlobalArray.remove fun(self: GlobalArray, index: integer)
-- --- @type GlobalArray.remove
-- function GlobalArray:remove(index)
-- 	local rootStorage = self:ensureRootStorage()

-- 	--- @type GlobalArray.remove
-- 	self.remove = function(_, index) table.remove(rootStorage, index) end
-- 	return self:remove(index)
-- end

-- --- @alias GlobalArray.get fun(self: GlobalArray, index: integer): any
-- --- @type GlobalArray.get
-- function GlobalArray:get(index)
-- 	local rootStorage = self:ensureRootStorage()

-- 	--- @type GlobalArray.get
-- 	self.get = function(_, index) return rootStorage[index] end
-- 	return self:get(index)
-- end

-- --- @alias GlobalArray.length fun(self: GlobalArray): integer
-- --- @type GlobalArray.length
-- function GlobalArray:length()
-- 	if global[self.key] == nil then return 0 end
-- 	local rootStorage = self:ensureRootStorage()

-- 	--- @type GlobalArray.length
-- 	self.length = function(_) return #rootStorage end
-- 	return self:length()
-- end

-- return GlobalArray
