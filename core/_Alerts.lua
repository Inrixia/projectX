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

--- @class AlertStorage : GlobalArray
--- @field next fun(self: GlobalArray, index?: integer): integer?, AlertItem?
--- @field ipairs fun(self: GlobalArray): fun(table: AlertItem[], i?: integer): integer, AlertItem
--- @field remove fun(self: GlobalArray, index: integer)
--- @field get fun(self: GlobalArray, index: integer): AlertItem | nil
--- @field add fun(self: GlobalArray, value: AlertItem): integer
Alerts.storage = require("storage/globalArray").new("alerts")

function _ensureListener()
	onNthTick.add(30, function(event, remove)
		if Alerts.storage:next() == nil then
			remove()
			ensureListener = _ensureListener
		end

		for alertId, alert in Alerts.storage:ipairs() do
			if not alert.entity.valid then
				Alerts.storage:remove(alertId)
				if alert.iconId ~= nil then rendering.destroy(alert.iconId) end
				return
			end

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
--- @returns integer
function Alerts.raise(entity, message, spritePath)
	local alertId = Alerts.storage:add({
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
	return alertId
end

--- @param alertId integer
function Alerts.resolve(alertId)
	Alerts.storage:remove(alertId)
end

return Alerts
