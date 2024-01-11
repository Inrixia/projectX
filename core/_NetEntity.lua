local Network = require("_Network")
local ObjectStorage = require("storage/objectStorage")

--- @class NetEntityStorage : ObjectStorage
--- @field next fun(self: ObjectStorage, unit_number?: integer): integer?, NetEntity?
--- @field pairs fun(self: ObjectStorage): fun(table: table<integer, NetEntity>, unit_number?: integer): integer, NetEntity
--- @field ensure fun(self: ObjectStorage, unit_number: integer, default: NetEntity): NetEntity
--- @field set fun(self: ObjectStorage, unit_number: integer, value: NetEntity | nil)
--- @field get fun(self: ObjectStorage, unit_number: integer): NetEntity | nil

--- @class NetEntity
--- @field entity LuaEntity
--- @field unit_number integer
--- @field internalCables LuaEntity[]
--- @field childEntities LuaEntity[]
--- @field network Network|nil
--- @field adjacent table<integer, NetEntity>
--- @field channels integer
--- @field storage NetEntityStorage
NetEntity = {}
NetEntity.__index = NetEntity
script.register_metatable("NetworkStorage", NetEntity)

NetEntity.storage = ObjectStorage.new(global, "netEntity")

local networkCableName = require("proto/Cable").protoName

--- @param event onEntityCreatedEvent
function NetEntity.from(event)
	local entity = event.created_entity
	local self = NetEntity.storage:get(entity.unit_number)
	if self ~= nil then return self end

	self = NetEntity.storage:set(entity.unit_number, setmetatable({}, NetEntity))

	self.entity = entity
	self.unit_number = entity.unit_number

	self.internalCables = {}
	self.childEntities = {}
	self.adjacent = {}
	self.channels = 0

	if entity.name ~= networkCableName then
		self.internalCables = {
			entity.surface.create_entity({
				name = networkCableName,
				position = entity.position,
				player = entity.last_user,
				force = entity.force,
				create_build_effect_smoke = false,
			})
		}
	end

	for _, adjacentEntity in pairs(self.findAdjacent(entity)) do
		local adjacentNetEntity = self.storage:get(adjacentEntity.unit_number)
		if adjacentNetEntity ~= nil then
			if self.network == nil then
				adjacentNetEntity.network:add(self)
			else
				Network.merge(self.network, adjacentNetEntity.network)
			end
			self:addAdjacent(adjacentNetEntity)
		end
	end
	if self.network == nil then Network.from(self) end

	return self
end

--- @param channels integer
function NetEntity:setChannels(channels)
	if self.channels == channels then return end
	self.network:updateChannels(self.channels, channels);
	self.channels = channels
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

function NetEntity:remove()
	local adjCount = 0
	for _, adjacentStorage in pairs(self.adjacent) do
		adjCount = adjCount + 1
		adjacentStorage.adjacent[self.unit_number] = nil
	end
	for _, entity in ipairs(self.internalCables) do entity.destroy() end
	for _, entity in ipairs(self.childEntities) do entity.destroy() end

	self.network:remove(self)
	if adjCount > 1 then Network.split(self) end

	self.storage:set(self.unit_number, nil)
end

--- @param adjacent NetEntity
function NetEntity:addAdjacent(adjacent)
	self.adjacent[adjacent.unit_number] = adjacent
	adjacent.adjacent[self.unit_number] = self
end

--- @param unit_number integer
function NetEntity.getValid(unit_number)
	local netEntity = NetEntity.storage:get(unit_number)
	if netEntity == nil then return nil end
	if not netEntity.entity.valid then
		NetEntity.storage:set(unit_number, nil)
		return nil
	end
	return netEntity
end

return NetEntity
