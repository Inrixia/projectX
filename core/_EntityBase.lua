local entityCreated = require("events/entityCreated")
local entityRemoved = require("events/entityRemoved")
local guiOpened = require("events/guiOpened")


--- @alias EntityBase.onEntityCreated onEntityCreated
--- @alias EntityBase.onEntityRemoved onEntityRemoved
--- @alias EntityBase.onEntityGuiOpened onGuiOpened

--- @class EntityBase
--- @field public protoName string
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

	return self
end

--- @generic T : function
--- @type fun(originalMethod: T, newMethod: T, newFirst?: boolean): T
function EntityBase.overloadMethod(originalMethod, newMethod, newFirst)
	if originalMethod == nil then
		return newMethod
	else
		if newFirst then
			return function(...)
				newMethod(...)
				originalMethod(...)
			end
		else
			return function(...)
				originalMethod(...)
				newMethod(...)
			end
		end
	end
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
	self._onEntityRemoved = EntityBase.overloadMethod(self._onEntityRemoved, method, true)
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

return EntityBase
