local onLoad = require("events/load")
local onNthTick = require("events/nthTick")

local ObjectStorage = require("storage/objectStorage")

--- @class AlertItem
--- @field iconId integer?
--- @field entity LuaEntity
--- @field icon SignalID
--- @field message LocalisedString

--- @class Alerts
--- @field storage AlertStorage
Alerts = {}
Alerts.__index = Alerts
setmetatable(Alerts, { __index = Alerts })

--- @class AlertStorage : ObjectStorage
--- @field next fun(self: ObjectStorage, unit_number?: integer): integer?, AlertItem[]?
--- @field pairs fun(self: ObjectStorage): fun(table: table<integer, AlertItem[]>, unit_number?: integer): integer, AlertItem[]
--- @field ensure fun(self: ObjectStorage, unit_number: integer, default: AlertItem[]): AlertItem[]
--- @field set fun(self: ObjectStorage, unit_number: integer, value: AlertItem []| nil)
--- @field get fun(self: ObjectStorage, unit_number: integer): AlertItem[] | nil
Alerts.storage = ObjectStorage.new("alerts")
function Alerts.storage:firstAlertPairs()
	-- This is an iterator function
	return function(alerts, unit_number)
		-- Get the next storage
		local next_unit_number, alerts = self:next(unit_number)
		if alerts == nil then
			-- No more storages, end iteration
			return nil
		end

		-- Get the first alert from the alerts table
		local _, firstAlert = next(alerts)
		if firstAlert == nil then
			-- If no alerts are present, set the storage to nil and skip to the next one
			self:set(unit_number, nil)
			return self:firstAlertPairs()(alerts, next_unit_number)
		else
			if not firstAlert.entity.valid then
				removeAlert(firstAlert, unit_number)
				return self:firstAlertPairs()(alerts, next_unit_number)
			end
			-- Return the current storage unit number and the first alert
			return next_unit_number, firstAlert
		end
	end, self, nil
end

--- @param alertItem AlertItem|nil
--- @param unit_number integer
function removeAlert(alertItem, unit_number)
	if alertItem == nil then return end


	local alertStorage = Alerts.storage:get(unit_number)
	if alertStorage ~= nil then
		alertStorage[alertItem.message] = nil
		if next(alertStorage) == nil then Alerts.storage:set(unit_number, nil) end
	end

	if alertItem.iconId ~= nil then rendering.destroy(alertItem.iconId) end

	if alertItem.entity.valid then
		for _, player in pairs(game.players) do
			if player.connected and player.force == alertItem.entity.force then
				player.remove_alert(alertItem)
			end
		end
	end
end

function _ensureListener()
	onNthTick.add(30, function(event, remove)
		if Alerts.storage:next() == nil then
			remove()
			ensureListener = _ensureListener
		end

		for _, firstAlert in Alerts.storage:firstAlertPairs() do
			if firstAlert.iconId ~= nil then
				if rendering.is_valid(firstAlert.iconId) then
					rendering.set_visible(firstAlert.iconId, (event.tick / 30) % 2 ~= 0)
				else
					firstAlert.iconId = nil
				end
			end
		end
	end)
	onNthTick.add(600, function(_, remove)
		if Alerts.storage:next() == nil then
			remove()
			ensureListener = _ensureListener
		end

		for _, firstAlert in Alerts.storage:firstAlertPairs() do
			ensureCustomAlert(firstAlert)
		end
	end)
	ensureListener = function() end
end

ensureListener = _ensureListener;

--- @param alert AlertItem
function ensureCustomAlert(alert)
	for _, player in pairs(game.players) do
		if player.connected and player.force == alert.entity.force then
			player.add_custom_alert(alert.entity, alert.icon, alert.message, true)
		end
	end
end

onLoad(function()
	if Alerts.storage:next() ~= nil then ensureListener() end
end)

--- @param entity LuaEntity
--- @param message LocalisedString
--- @param spritePath SpritePath
function Alerts.raise(entity, message, spritePath)
	local entityAlerts = Alerts.storage:ensure(entity.unit_number, {})
	if entityAlerts[message] ~= nil then return end

	local newAlert = {
		iconId = rendering.draw_sprite({
			sprite = spritePath,
			target = entity,
			surface = entity.surface,
			players = nil,
			x_scale = 0.5,
			y_scale = 0.5,
			visible = false
		}),
		entity = entity,
		icon = { type = "item", name = entity.name },
		message = message
	}
	entityAlerts[message or ""] = newAlert

	ensureCustomAlert(newAlert);
	ensureListener()
end

--- @param unit_number integer
--- @param message LocalisedString
function Alerts.resolve(unit_number, message)
	local entityAlerts = Alerts.storage:get(unit_number)
	if entityAlerts == nil then return end
	removeAlert(entityAlerts[message], unit_number)
end

return Alerts
