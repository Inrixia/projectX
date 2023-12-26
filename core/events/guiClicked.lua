local EventHandler = require("EventHandler")

--- @alias onGuiClicked fun(event:EventData.on_gui_click)

--- @class GuiClicked : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onGuiClicked)
--- @field remove fun(self: EventHandler, name: string)
local guiClicked = EventHandler.new(defines.events.on_gui_click, function(methods)
	script.on_event(defines.events.on_gui_click, function(event)
		if event.element == nil then return end
		local method = methods[event.element.name]
		if method ~= nil then method(event) end
	end)
end)

return guiClicked
