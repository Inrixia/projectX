local load = require("events/load")

local entityCreated = require("events/entityCreated")
local guiOpened = require("events/guiOpened")

--- @alias onLoad fun(storage: table, unit_number: integer)
--- @alias onEntityBuilt fun(event: onEntityCreatedEvent, storage: table, unit_number: integer)
--- @alias onEntityGuiOpened fun(event: EventData.on_gui_opened, storage: table, unit_number: integer)

--- @class EntityBase
--- @field public prototypeName string
--- @field private _onBuilt onEntityCreated
--- @field private _onLoad onLoad
--- @field private _onGuiOpened onEntityGuiOpened
local EntityBase = {}
EntityBase.__index = EntityBase

script.register_metatable("EntityBase", EntityBase)

--- @param prototype ProtoBase
function EntityBase.new(prototype)
	local self = setmetatable({}, EntityBase)

	self.prototypeName = prototype.prototypeName

	load(function()
		if global.entities ~= nil and global.entities[self.prototypeName] ~= nil then
			for unit_number, storage in pairs(global.entities[self.prototypeName]) do
				self:_setup(storage, unit_number)
			end
		end
	end)

	return self
end

--- @param unit_number integer
--- @return table
function EntityBase:getInstanceStorage(unit_number)
	return global.entities[self.prototypeName][unit_number]
end

function EntityBase:_setup(storage, unit_number)
	if self._onLoad ~= nil then self._onLoad(storage, unit_number) end
	if self._onGuiOpened ~= nil then
		guiOpened:add(unit_number, function(event) self._onGuiOpened(event, storage, unit_number) end)
	end
end

--- @param onBuiltMethod onEntityBuilt
--- @returns EntityBase
function EntityBase:onBuilt(onBuiltMethod)
	entityCreated.add(self.prototypeName, function(event)
		if global.entities == nil then global.entities = {} end
		if global.entities[self.prototypeName] == nil then global.entities[self.prototypeName] = {} end

		local unit_number = event.created_entity.unit_number

		global.entities[self.prototypeName][unit_number] = {}
		local storage = global.entities[self.prototypeName][unit_number]
		onBuiltMethod(event, storage, unit_number)
		self:_setup(storage, unit_number)
	end)
	return self
end

--- @param entity LuaEntity
--- @returns LuaEntity[]
function EntityBase:findAdjacent(entity)
	local adjacent = {}
	local adjacentEntity = nil
	adjacentEntity = entity.surface.find_entity(self.prototypeName, { entity.position.x, entity.position.y - 1 }) -- Above
	if adjacentEntity then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.prototypeName, { entity.position.x, entity.position.y + 1 }) -- Below
	if adjacentEntity then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.prototypeName, { entity.position.x - 1, entity.position.y }) -- Left
	if adjacentEntity then table.insert(adjacent, adjacentEntity) end
	adjacentEntity = entity.surface.find_entity(self.prototypeName, { entity.position.x + 1, entity.position.y }) -- Right
	if adjacentEntity then table.insert(adjacent, adjacentEntity) end
end

--- @param entity LuaEntity
--- @returns LuaEntity|nil
function EntityBase:findFirstAdjacent(entity)
	return entity.surface.find_entity(self.prototypeName, { entity.position.x, entity.position.y - 1 }) -- Above
		or entity.surface.find_entity(self.prototypeName, { entity.position.x, entity.position.y + 1 }) -- Below
		or entity.surface.find_entity(self.prototypeName, { entity.position.x - 1, entity.position.y }) -- Left
		or entity.surface.find_entity(self.prototypeName, { entity.position.x + 1, entity.position.y }) -- Right
end

--- @param method onLoad
--- @returns EntityBase
function EntityBase:onLoad(method)
	self._onLoad = method
	return self
end

--- @param method onEntityGuiOpened
--- @returns EntityBase
function EntityBase:onGuiOpened(method)
	self._onGuiOpened = method
	return self
end

return EntityBase
