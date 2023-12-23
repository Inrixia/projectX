local init = require("events/init")
local load = require("events/load")

local built = require("events/built")
local guiOpened = require("events/guiOpened")

--- @class EntityBase
--- @field public prototypeName string
--- @field private _onData fun()
--- @field private _onBuilt onBuilt
--- @field private _onGuiOpened onGuiOpened
local EntityBase = {}
EntityBase.__index = EntityBase

--- @param prototypeName string
function EntityBase.new(prototypeName)
	local self = setmetatable({}, EntityBase)

	self.prototypeName = prototypeName

	return self
end

function EntityBase:RegisterEvents()
	init(function()
		if global.entityBases == nil then global.entityBases = {} end
		if global.entityBases[self.prototypeName] == nil then global.entityBases[self.prototypeName] = {} end
	end)

	--- @param unit_number integer
	local function registerEvents(unit_number)
		if self._onGuiOpened ~= nil then guiOpened:add(unit_number, self._onGuiOpened) end
	end

	load(function()
		for unit_number, _ in pairs(global.entityBases[self.prototypeName]) do
			registerEvents(unit_number)
		end
	end)

	built.add(self.prototypeName, function(event)
		local unit_number = event.created_entity.unit_number;
		global.entityBases[self.prototypeName][unit_number] = true
		registerEvents(unit_number)

		if (self._onBuilt ~= nil) then self._onBuilt(event) end
	end)
end

function EntityBase:CreateProto() self._onData() end

--- @param method onBuilt onBuilt
function EntityBase:onBuilt(method) self._onBuilt = method end

--- @param method onGuiClosed onGuiOpened
function EntityBase:onGuiOpened(method) self._onGuiOpened = method end

--- @param method fun()
function EntityBase:onData(method) self._onData = method end

return EntityBase
