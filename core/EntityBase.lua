local load = require("events/load")

local built = require("events/built")
local guiOpened = require("events/guiOpened")

--- @alias onLoad fun(storage: table, unit_number: integer)
--- @alias onEntityBuilt fun(event: onBuiltEvent, storage: table, unit_number: integer)
--- @alias onEntityGuiOpened fun(event: EventData.on_gui_opened, storage: table, unit_number: integer)

--- @class EntityBase
--- @field public prototypeName string
--- @field private _onBuilt onEntityBuilt
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
		for unit_number, storage in pairs(global.entities[self.prototypeName]) do
			self:_setup(storage, unit_number)
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
function EntityBase:onBuilt(onBuiltMethod)
	built.add(self.prototypeName, function(event)
		if global.entities == nil then global.entities = {} end
		if global.entities[self.prototypeName] == nil then global.entities[self.prototypeName] = {} end

		local unit_number = event.created_entity.unit_number

		global.entities[self.prototypeName][unit_number] = {}
		local storage = global.entities[self.prototypeName][unit_number]
		onBuiltMethod(event, storage, unit_number)
		self:_setup(storage, unit_number)
	end)
end

--- @param method onLoad
function EntityBase:onLoad(method) self._onLoad = method end

--- @param method onEntityGuiOpened
function EntityBase:onGuiOpened(method) self._onGuiOpened = method end

return EntityBase
