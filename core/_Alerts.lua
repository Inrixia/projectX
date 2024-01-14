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
--- @field next fun(self: ObjectStorage, unit_number?: integer): integer?, AlertItem?
--- @field pairs fun(self: ObjectStorage): fun(table: table<integer, AlertItem>, unit_number?: integer): integer, AlertItem
--- @field ensure fun(self: ObjectStorage, unit_number: integer, default: AlertItem): AlertItem
--- @field set fun(self: ObjectStorage, unit_number: integer, value: AlertItem | nil)
--- @field get fun(self: ObjectStorage, unit_number: integer): AlertItem | nil
--- @field getValid fun(self: ObjectStorage, unit_number: integer): AlertItem | nil
Alerts.storage = ObjectStorage.new("alerts")

--- @param alertItem AlertItem|nil
--- @param unit_number integer
function removeAlert(alertItem, unit_number)
	if alertItem == nil then return end
	Alerts.storage:set(unit_number, nil)
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

		for unit_number, alert in Alerts.storage:pairs() do
			if not alert.entity.valid then
				removeAlert(alert, unit_number)
			elseif alert.iconId ~= nil then
				rendering.set_visible(alert.iconId, (event.tick / 30) % 2 ~= 0)
			end
		end
	end)
	onNthTick.add(600, function(event, remove)
		if Alerts.storage:next() == nil then
			remove()
			ensureListener = _ensureListener
		end

		for unit_number, alert in Alerts.storage:pairs() do
			if not alert.entity.valid then
				removeAlert(alert, unit_number)
			else
				ensureCustomAlert(alert)
			end
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
	if (Alerts.storage:get(entity.unit_number) ~= nil) then return end
	local alert = Alerts.storage:set(entity.unit_number, {
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
	})
	ensureCustomAlert(alert);
	ensureListener()
end

--- @param unit_number integer
function Alerts.resolve(unit_number)
	removeAlert(Alerts.storage:get(unit_number), unit_number)
end

return Alerts
