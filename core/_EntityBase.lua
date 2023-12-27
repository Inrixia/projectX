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

function EntityBase:ensureInstanceStorage()
	if global.entities == nil then global.entities = {} end
	if global.entities[self.protoName] == nil then global.entities[self.protoName] = {} end

	--- @type table<integer, table>
	return global.entities[self.protoName]
end

--- @alias EntityBase.getInstanceStorage fun(self: EntityBase, unit_number: integer): table
--- @type EntityBase.getInstanceStorage
function EntityBase:getInstanceStorage(unit_number)
	local instanceStorage = self:ensureInstanceStorage()

	--- Self modifying code baby! Dont re-check what we dont need to
	--- @type EntityBase.getInstanceStorage
	self.getInstanceStorage = function(_, unit_number)
		if instanceStorage[unit_number] == nil then instanceStorage[unit_number] = {} end
		return instanceStorage[unit_number]
	end
	return self:getInstanceStorage(unit_number)
end

--- @alias EntityBase.clearInstanceStorage fun(self: EntityBase, unit_number: integer)
--- @type EntityBase.clearInstanceStorage
function EntityBase:clearInstanceStorage(unit_number)
	local instanceStorage = self:ensureInstanceStorage()

	--- Self modifying code baby! Dont re-check what we dont need to
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
			self._onLoad(self:getInstanceStorage(unit_number), unit_number)
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

--- @param entity LuaEntity
--- @returns LuaEntity[]
function EntityBase:findAdjacent(entity)
	--- @type LuaEntity[]
	local adjacent = {}
	local adjacentEntity = entity.surface.find_entity(self.protoName, { entity.position.x, entity.position.y - 1 }) -- Above
	if adjacentEntity ~= nil then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.protoName, { entity.position.x, entity.position.y + 1 })    -- Below
	if adjacentEntity ~= nil then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.protoName, { entity.position.x - 1, entity.position.y })    -- Left
	if adjacentEntity ~= nil then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.protoName, { entity.position.x + 1, entity.position.y })    -- Right
	if adjacentEntity ~= nil then table.insert(adjacent, adjacentEntity) end
	return adjacent
end

--- @param entity LuaEntity
--- @returns LuaEntity|nil
function EntityBase:findFirstAdjacent(entity)
	return entity.surface.find_entity(self.protoName, { entity.position.x, entity.position.y - 1 }) -- Above
		or entity.surface.find_entity(self.protoName, { entity.position.x, entity.position.y + 1 }) -- Below
		or entity.surface.find_entity(self.protoName, { entity.position.x - 1, entity.position.y }) -- Left
		or entity.surface.find_entity(self.protoName, { entity.position.x + 1, entity.position.y }) -- Right
end

return EntityBase
