local indexHash = require("indexHash")
local EventHandler = require("EventHandler")


--- @alias onGuiElemChanged fun(event:EventData.on_gui_elem_changed)

--- @class GuiElemChanged : EventHandler
--- @field add fun(self: EventHandler, name: string, method: onGuiElemChanged)
--- @field remove fun(self: EventHandler, name: string)
local guiElemChanged = EventHandler.new(defines.events.on_gui_elem_changed, function(methods)
	script.on_event(defines.events.on_gui_elem_changed, function(event)
		local method = methods[event.element.name];
		if method ~= nil then method(event) end
	end)
end)

return guiElemChanged
