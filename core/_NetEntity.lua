local Network = require("_Network")
local ObjectStorage = require("storage/objectStorage")
local Dict = require("storage/Dict")
local EntityBase = require("_EntityBase")

--- @class NetEntityStorage : ObjectStorage
--- @field next fun(self: ObjectStorage, unit_number?: integer): integer?, NetEntity?
--- @field pairs fun(self: ObjectStorage): fun(table: table<integer, NetEntity>, unit_number?: integer): integer, NetEntity
--- @field ensure fun(self: ObjectStorage, unit_number: integer, default: NetEntity): NetEntity
--- @field set fun(self: ObjectStorage, unit_number: integer, value: NetEntity | nil)
--- @field get fun(self: ObjectStorage, unit_number: integer): NetEntity | nil

--- @class NetEntity
--- @field entity LuaEntity
--- @field name string
--- @field unit_number integer
--- @field internalCables LuaEntity[]
--- @field childEntities table<any, LuaEntity>
--- @field network Network|nil
--- @field adjacent Dict
--- @field channels integer
--- @field energy double
--- @field storage NetEntityStorage
NetEntity = {}
NetEntity.__index = NetEntity
script.register_metatable("NetworkStorage", NetEntity)

NetEntity.storage = ObjectStorage.new("netEnt")

local networkCableName = require("proto/Cable").protoName

--- @param event onEntityCreatedEvent
function NetEntity:from(event)
	local entity = event.created_entity
	local _self = NetEntity.storage:get(entity.unit_number)
	if _self ~= nil then return _self end

	_self = NetEntity.storage:set(entity.unit_number, setmetatable({}, self))

	_self.entity = entity
	_self.name = entity.name
	_self.unit_number = entity.unit_number

	_self.internalCables = {}
	_self.childEntities = {}
	_self.adjacent = Dict.new()
	_self.channels = 0
	_self.energy = 0

	if entity.name ~= networkCableName then
		_self.internalCables = {
			EntityBase.createOnEntity(entity, networkCableName)
		}
	end

	for _, adjacentEntity in pairs(_self.findAdjacent(entity)) do
		local adjacentNetEnt = _self.storage:get(adjacentEntity.unit_number)
		if adjacentNetEnt ~= nil then
			if _self.network == nil then
				adjacentNetEnt.network:add(_self)
			else
				_self.network:merge(adjacentNetEnt.network)
			end
			_self:addAdjacent(adjacentNetEnt)
		end
	end
	if _self.network == nil then Network.from(_self) end

	return _self
end

function NetEntity:base()
	local base = NetworkedEntity.Lookup[self.name];
	self.base = function() return base end
	return self.base()
end

NetEntity.onChannels = nil
NetEntity.onNoChannels = nil
NetEntity.onEnergy = nil
NetEntity.onNoEnergy = nil
NetEntity.disable = nil
NetEntity.enable = nil

function NetEntity:destroy()
	for _, entity in ipairs(self.internalCables) do entity.destroy() end
	for _, entity in pairs(self.childEntities) do entity.destroy() end

	self:removeSelfFromAdjacent()
	self.network:remove(self)
	if #self.adjacent > 1 then Network.split(self.adjacent) end

	self.storage:set(self.unit_number, nil)
end

--- @param adjacent NetEntity
function NetEntity:addAdjacent(adjacent)
	self.adjacent[adjacent.unit_number] = adjacent
	adjacent.adjacent[self.unit_number] = self
end

function NetEntity:removeSelfFromAdjacent()
	for _, adjacentNetEntity in pairs(self.adjacent) do
		adjacentNetEntity.adjacent[self.unit_number] = nil
	end
end

--- @param channels integer
--- @returns integer
function NetEntity:setChannels(channels)
	if self.channels == channels then return end
	self.network:updateChannels(channels - self.channels)
	self.channels = channels
end

--- @param energy double
--- @returns double
function NetEntity:setEnergy(energy)
	if self.energy == energy then return end
	self.network:updateEnergy(energy - self.energy)
	self.energy = energy
end

--- @param unit_number integer
function NetEntity.getValid(unit_number)
	local netEnt = NetEntity.storage:get(unit_number)
	if netEnt == nil then return nil end
	if not netEnt.entity.valid then
		NetEntity.storage:set(unit_number, nil)
		return nil
	end
	return netEnt
end

--- @param entity LuaEntity
--- @returns LuaEntity[]
function NetEntity.findAdjacent(entity)
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

return NetEntity
