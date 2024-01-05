local EventHandler = require("EventHandler")

--- @alias onGuiClosed fun(event:EventData.on_gui_closed)

--- @class GuiClosed : EventHandler
--- @field set fun(self: EventHandler, name: string, method: onGuiClosed)
--- @field remove fun(self: EventHandler, name: string)
local guiClosed = EventHandler.new(defines.events.on_gui_closed, function(methods)
	script.on_event(defines.events.on_gui_closed, function(event)
		if event.element == nil then return end
		local method = methods[event.element.name]
		if method ~= nil then method(event) end
	end)
end)

return guiClosed
