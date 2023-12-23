local EventHandler = require("EventHandler")

--- @class GuiOpened : EventHandler
--- @field add fun(self: EventHandler, unit_number: integer, method: fun(event:EventData.on_gui_opened))
--- @field remove fun(self: EventHandler, unit_number: integer)
local guiOpened = EventHandler.new(defines.events.on_gui_opened, function(methods)
	script.on_event(defines.events.on_gui_opened, function(event)
		if (event.entity == nil) then return end
		local method = methods[event.entity.unit_number]
		if method ~= nil then method(event) end
	end)
end)

return guiOpened
