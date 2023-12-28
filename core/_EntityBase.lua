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
	self:ensureOnEntityRemoved()
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
	self:ensureOnEntityCreated()
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

--- @alias makeSearchArea fun(entity: LuaEntity): BoundingBox

--- @type makeSearchArea
function verticalSearchArea(entity)
	local collision_box = entity.prototype.collision_box
	return { { collision_box.left_top.x, collision_box.left_top.y - 0.5 }, { collision_box.right_bottom.x, collision_box.right_bottom.y + 0.5 } }
end

--- @type makeSearchArea
function horizontalSearchArea(entity)
	local collision_box = entity.prototype.collision_box
	return { { collision_box.left_top.x - 0.5, collision_box.left_top.y }, { collision_box.right_bottom.x + 0.5, collision_box.right_bottom.y } }
end

--- @param entity LuaEntity
--- @returns LuaEntity[]
function EntityBase:findAdjacent(entity)
	local x = entity.position.x
	local y = entity.position.y

	local surface = entity.surface

	--- @type LuaEntity[]
	local adjacent_entities = {}

	-- Search vertically (top and bottom)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = verticalSearchArea(entity) })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			table.insert(adjacent_entities, adjacent_entity)
		end
	end

	-- Search horizontally (left and right)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = horizontalSearchArea(entity) })) do
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
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = verticalSearchArea(entity), limit = 1 })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			return adjacent_entity
		end
	end

	-- Search horizontally (left and right)
	for _, adjacent_entity in pairs(surface.find_entities_filtered({ area = horizontalSearchArea(entity), limit = 1 })) do
		if adjacent_entity.unit_number ~= entity.unit_number then
			return adjacent_entity
		end
	end

	return nil
end

return EntityBase
