local load = require("events/load")

local entityCreated = require("events/entityCreated")
local entityRemoved = require("events/entityRemoved")
local guiOpened = require("events/guiOpened")

--- @alias EntityBase.onLoad fun(storage: table, unit_number: integer)
--- @alias EntityBase.onEntityCreated onEntityCreated
--- @alias EntityBase.onEntityRemoved onEntityRemoved
--- @alias EntityBase.onEntityGuiOpened onGuiOpened

local nullFunc = function() end

--- @class EntityBase
--- @field public protoName string
--- @field private _onCreated EntityBase.onEntityCreated
--- @field private _onRemoved EntityBase.onEntityRemoved
--- @field private _onLoad EntityBase.onLoad
--- @field private _onGuiOpened EntityBase.onEntityGuiOpened
--- @field private ensureOnCreated fun(self: EntityBase)
--- @field private ensureOnLoad fun(self: EntityBase)
--- @field private ensureOnRemoved fun(self: EntityBase)
--- @field private ensureOnGuiOpened fun(self: EntityBase)
local EntityBase = {}
EntityBase.__index = EntityBase

--- @param prototype ProtoBase
function EntityBase.new(prototype)
	local self = setmetatable({}, EntityBase)

	self.protoName = prototype.protoName

	return self
end

--- @generic T : function
--- @type fun(originalMethod: T, newMethod: T): T
function EntityBase.overloadMethod(originalMethod, newMethod)
	if originalMethod == nil then
		return newMethod
	else
		return function(...)
			newMethod(...)
			originalMethod(...)
		end
	end
end

function EntityBase:ensureGlobalEntities()
	if global.entities == nil then global.entities = {} end
	if global.entities[self.protoName] == nil then global.entities[self.protoName] = {} end

	self.ensureGlobalEntities = function()
		--- @type table
		return global.entities[self.protoName]
	end
	return self.ensureGlobalEntities()
end

--- @alias EntityBase.ensureInstanceStorage fun(self: EntityBase, unit_number: integer): table
--- @type EntityBase.ensureInstanceStorage
function EntityBase:ensureInstanceStorage(unit_number)
	local instanceStorage = self:ensureGlobalEntities()

	--- @type EntityBase.ensureInstanceStorage
	self.ensureInstanceStorage = function(_, unit_number)
		if instanceStorage[unit_number] == nil then instanceStorage[unit_number] = {} end
		return instanceStorage[unit_number]
	end
	return self:ensureInstanceStorage(unit_number)
end

--- @alias EntityBase.clearInstanceStorage fun(self: EntityBase, unit_number: integer)
--- @type EntityBase.clearInstanceStorage
function EntityBase:clearInstanceStorage(unit_number)
	local instanceStorage = self:ensureGlobalEntities()

	--- @type EntityBase.clearInstanceStorage
	self.clearInstanceStorage = function(_, unit_number) instanceStorage[unit_number] = nil end
	self:clearInstanceStorage(unit_number)
end

--- @param method EntityBase.onEntityCreated
--- @returns EntityBase
function EntityBase:onCreated(method)
	self._onCreated = EntityBase.overloadMethod(self._onCreated, method)
	self:ensureOnCreated()
	return self
end

function EntityBase:ensureOnCreated()
	self:ensureOnRemoved()
	entityCreated.add(self.protoName, function(event)
		if self._onCreated ~= nil then self._onCreated(event) end
		if self._onLoad ~= nil then
			local unit_number = event.created_entity.unit_number
			self._onLoad(self:ensureInstanceStorage(unit_number), unit_number)
		end
	end)
	self.ensureOnCreated = nullFunc
end

--- @param method EntityBase.onEntityRemoved
--- @returns EntityBase
function EntityBase:onRemoved(method)
	self._onRemoved = EntityBase.overloadMethod(self._onRemoved, method)
	self:ensureOnRemoved()
	return self
end

function EntityBase:ensureOnRemoved()
	entityRemoved.add(self.protoName, function(event)
		if self._onRemoved then self._onRemoved(event) end
		self:clearInstanceStorage(event.entity.unit_number)
	end)
	self.ensureOnRemoved = nullFunc
end

--- @param method EntityBase.onLoad
--- @returns EntityBase
function EntityBase:onLoad(method)
	self._onLoad = EntityBase.overloadMethod(self._onLoad, method)
	self:ensureOnLoad()
	return self
end

function EntityBase:ensureOnLoad()
	self:ensureOnCreated()
	load(function()
		if global.entities ~= nil and global.entities[self.protoName] ~= nil then
			for unit_number, storage in pairs(global.entities[self.protoName]) do
				if self._onLoad ~= nil then self._onLoad(storage, unit_number) end
			end
		end
	end)
	self.ensureOnLoad = nullFunc
end

--- @param method EntityBase.onEntityGuiOpened
--- @returns EntityBase
function EntityBase:onGuiOpened(method)
	self._onGuiOpened = EntityBase.overloadMethod(self._onGuiOpened, method)
	self:ensureOnGuiOpened()
	return self
end

function EntityBase:ensureOnGuiOpened()
	guiOpened:add(self.protoName, self._onGuiOpened)
	self.ensureOnGuiOpened = nullFunc
end

--- @alias makeSearchArea fun(x: number, y: number): BoundingBox

--- @type makeSearchArea
function verticalSearchArea(x, y) return { { x - 0.5, y - 1.5 }, { x + 0.5, y + 1.5 } } end

--- @type makeSearchArea
function horizontalSearchArea(x, y) return { { x - 1.5, y - 0.5 }, { x + 1.5, y + 0.5 } } end

--- @param entity LuaEntity
--- @returns LuaEntity[]
function EntityBase:findAdjacent(entity)
	local x = entity.position.x
	local y = entity.position.y

	local surface = entity.surface

	--- @type LuaEntity[]
	local adjacent_entities = {}

	-- Search vertically (top and bottom)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = verticalSearchArea(x, y) })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			table.insert(adjacent_entities, adjacent_entity)
		end
	end

	-- Search horizontally (left and right)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = horizontalSearchArea(x, y) })) do
		if adjacent_entity.unit_number ~= entity.unit_number and not adjacent_entities[adjacent_entity.unit_number] then
			table.insert(adjacent_entities, adjacent_entity)
		end
	end

	return adjacent_entities
end

--- @param entity LuaEntity
--- @returns LuaEntity|nil
function EntityBase:findFirstAdjacent(entity)
	local x = entity.position.x
	local y = entity.position.y

	local surface = entity.surface

	-- Search vertically (top and bottom)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = verticalSearchArea(x, y), limit = 1 })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			return adjacent_entity
		end
	end

	-- Search horizontally (left and right)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = horizontalSearchArea(x, y), limit = 1 })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			return adjacent_entity
		end
	end

	return nil
end

return EntityBase
