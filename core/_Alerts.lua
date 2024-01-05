local onLoad = require("events/load")
local onNthTick = require("events/nthTick")

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

--- @class AlertStorage : GlobalStorage
--- @field next fun(self: GlobalStorage, unit_number?: integer): integer?, AlertItem?
--- @field pairs fun(self: GlobalStorage): fun(table: table<integer, AlertItem>, unit_number?: integer): integer, AlertItem
--- @field ensure fun(self: GlobalStorage, unit_number: integer, default: AlertItem): AlertItem
--- @field set fun(self: GlobalStorage, unit_number: integer, value: AlertItem | nil)
--- @field get fun(self: GlobalStorage, unit_number: integer): AlertItem | nil
--- @field getValid fun(self: GlobalStorage, unit_number: integer): AlertItem | nil
Alerts.storage = require("storage/globalStorage").new("alerts")

--- @param alertItem AlertItem|nil
function removeAlert(alertItem)
	if alertItem == nil then return end
	Alerts.storage:set(alertItem.entity.unit_number, nil)
	if alertItem.iconId ~= nil then rendering.destroy(alertItem.iconId) end
end

function _ensureListener()
	onNthTick.add(30, function(event, remove)
		if Alerts.storage:next() == nil then
			remove()
			ensureListener = _ensureListener
		end

		for _, alert in Alerts.storage:pairs() do
			if not alert.entity.valid then removeAlert(alert) end

			for _, player in pairs(game.players) do
				if player.connected and player.force == alert.entity.force then
					player.add_custom_alert(alert.entity, alert.icon, alert.message, true)
				end
			end

			if alert.iconId ~= nil then rendering.set_visible(alert.iconId, (event.tick / 30) % 2 ~= 0) end
		end
	end)
	ensureListener = function() end
end

ensureListener = _ensureListener;

onLoad(function()
	if Alerts.storage:next() ~= nil then ensureListener() end
end)

--- @param entity LuaEntity
--- @param message LocalisedString
--- @param spritePath SpritePath
function Alerts.raise(entity, message, spritePath)
	if (Alerts.storage:get(entity.unit_number) ~= nil) then return end
	Alerts.storage:set(entity.unit_number, {
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
	ensureListener()
end

--- @param unit_number integer
function Alerts.resolve(unit_number)
	removeAlert(Alerts.storage:get(unit_number))
end

return Alerts
