local load = require("events/load")

local entityCreated = require("events/entityCreated")
local entityRemoved = require("events/entityRemoved")
local guiOpened = require("events/guiOpened")
local nthTick = require("events/nthTick")

--- @alias EntityBase.onLoad fun(storage: table, unit_number: integer)
--- @alias EntityBase.onEntityCreated onEntityCreated
--- @alias EntityBase.onEntityRemoved onEntityRemoved
--- @alias EntityBase.onEntityGuiOpened onGuiOpened

local nullFunc = function() end

--- @class EntityBase
--- @field public protoName string
--- @field private _onEntityCreated EntityBase.onEntityCreated
--- @field private _onEntityRemoved EntityBase.onEntityRemoved
--- @field private _onLoad EntityBase.onLoad
--- @field private _onGuiOpened EntityBase.onEntityGuiOpened
--- @field private ensureOnEntityCreated fun(self: EntityBase)
--- @field private ensureOnLoad fun(self: EntityBase)
--- @field private ensureOnEntityRemoved fun(self: EntityBase)
--- @field private ensureOnGuiOpened fun(self: EntityBase)
local EntityBase = {}
EntityBase.__index = EntityBase

local registeredEntities = {}

--- @param prototype ProtoBase
function EntityBase.new(prototype)
	local self = setmetatable({}, EntityBase)

	if registeredEntities[prototype.protoName] ~= nil then
		error("EntityBase " .. prototype.protoName .. " already exists")
	end

	self.protoName = prototype.protoName
	registeredEntities[prototype.protoName] = false

	return self
end

--- @generic T : function
--- @type fun(originalMethod: T, newMethod: T): T
function EntityBase.overloadMethod(originalMethod, newMethod)
	if originalMethod == nil then
		return newMethod
	else
		return function(...)
			originalMethod(...)
			newMethod(...)
		end
	end
end

--- @param method EntityBase.onEntityCreated
--- @returns EntityBase
function EntityBase:onEntityCreated(method)
	self._onEntityCreated = EntityBase.overloadMethod(self._onEntityCreated, method)
	self:ensureOnEntityCreated()
	return self
end

function EntityBase:ensureOnEntityCreated()
	entityCreated.add(self.protoName, self._onEntityCreated)
	self.ensureOnEntityCreated = nullFunc
end

--- @param method EntityBase.onEntityRemoved
--- @returns EntityBase
function EntityBase:onEntityRemoved(method)
	self._onEntityRemoved = EntityBase.overloadMethod(self._onEntityRemoved, method)
	self:ensureOnEntityRemoved()
	return self
end

function EntityBase:ensureOnEntityRemoved()
	entityRemoved.add(self.protoName, self._onEntityRemoved)
	self.ensureOnEntityRemoved = nullFunc
end

--- @param method EntityBase.onLoad
--- @returns EntityBase
function EntityBase:onLoad(method)
	self._onLoad = EntityBase.overloadMethod(self._onLoad, method)
	self:ensureOnLoad()
	return self
end

function EntityBase:ensureOnLoad()
	load(self._onLoad)
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

--- @param tick integer
--- @param method onNthTick
--- @returns EntityBase
function EntityBase:onNthTick(tick, method)
	nthTick.add(tick, method)
	return self
end

--- @param entity LuaEntity
--- @returns LuaEntity[]
function EntityBase:findAdjacent(entity)
	--- @type LuaEntity[]
	local adjacent_entities = {}


	local width = entity.tile_width
	local height = entity.tile_height
	local x = entity.position.x
	local y = entity.position.y

	-- Calculate offsets for easier area calculation
	local width_offset = (width - 1) / 2
	local height_offset = (height - 1) / 2

	-- Search horizontally (left and right)
	local horizontal_area = {
		{ x - width_offset - 1, y - height_offset },
		{ x + width_offset + 1, y + height_offset }
	}
	for _, adjacent_entity in pairs(entity.surface.find_entities(horizontal_area)) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			table.insert(adjacent_entities, adjacent_entity)
		end
	end

	-- Search vertically (top and bottom)
	local vertical_area = {
		{ x - width_offset, y - height_offset - 1 },
		{ x + width_offset, y + height_offset + 1 }
	}
	for _, adjacent_entity in pairs(entity.surface.find_entities(vertical_area)) do
		if adjacent_entity.unit_number ~= entity.unit_number and not adjacent_entities[adjacent_entity.unit_number] then
			table.insert(adjacent_entities, adjacent_entity)
		end
	end

	return adjacent_entities
end

return EntityBase
