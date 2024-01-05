local entityCreated = require("events/entityCreated")
local entityRemoved = require("events/entityRemoved")
local guiOpened = require("events/guiOpened")
local nthTick = require("events/nthTick")


--- @alias EntityBase.onEntityCreated onEntityCreated
--- @alias EntityBase.onEntityRemoved onEntityRemoved
--- @alias EntityBase.onEntityGuiOpened onGuiOpened
--- @alias EntityBase.onNthTick onNthTick

--- @class EntityBase
--- @field public protoName string
--- @field private _onNthTick table<integer, EntityBase.onNthTick>
--- @field private _onEntityCreated EntityBase.onEntityCreated
--- @field private _onEntityRemoved EntityBase.onEntityRemoved
--- @field private _onGuiOpened EntityBase.onEntityGuiOpened
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

	self._onNthTick = {}

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

--- @param method EntityBase.onNthTick
--- @returns EntityBase
function EntityBase:onNthTick(tick, method)
	if self._onNthTick[tick] ~= nil then nthTick.remove(tick, self._onNthTick[tick]) end

	self._onNthTick[tick] = EntityBase.overloadMethod(self._onNthTick[tick], method)
	nthTick.add(tick, self._onNthTick[tick])
	return self
end

--- @param method EntityBase.onEntityCreated
--- @returns EntityBase
function EntityBase:onEntityCreated(method)
	self._onEntityCreated = EntityBase.overloadMethod(self._onEntityCreated, method)
	entityCreated.set(self.protoName, self._onEntityCreated)
	return self
end

--- @param method EntityBase.onEntityRemoved
--- @returns EntityBase
function EntityBase:onEntityRemoved(method)
	self._onEntityRemoved = EntityBase.overloadMethod(self._onEntityRemoved, method)
	entityRemoved.set(self.protoName, self._onEntityRemoved)
	return self
end

--- @param method EntityBase.onEntityGuiOpened
--- @returns EntityBase
function EntityBase:onGuiOpened(method)
	self._onGuiOpened = EntityBase.overloadMethod(self._onGuiOpened, method)
	guiOpened:set(self.protoName, self._onGuiOpened)
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
