local EventHandler = require("EventHandler")

--- @alias onGuiOpened fun(event:EventData.on_gui_opened)

--- @class GuiOpened : EventHandler
--- @field set fun(self: EventHandler, name: string, method: onGuiOpened)
--- @field remove fun(self: EventHandler, name: string)
local guiOpened = EventHandler.new(defines.events.on_gui_opened, function(methods)
	script.on_event(defines.events.on_gui_opened, function(event)
		if (event.entity == nil) then return end
		local method = methods[event.entity.name]
		if method ~= nil then method(event) end
	end)
end)

return guiOpened
