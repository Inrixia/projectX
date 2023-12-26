local EventHandler = require("EventHandler")

--- @alias onGuiSelectionStateChanged fun(event:EventData.on_gui_selection_state_changed)

--- @class GuiSelectionStateChanged : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: onGuiSelectionStateChanged)
--- @field remove fun(self: EventHandler, prototypeName: string)
local guiSelectionStateChanged = EventHandler.new(defines.events.on_gui_selection_state_changed, function(methods)
	script.on_event(defines.events.on_gui_selection_state_changed, function(event)
		local method = methods[event.element.name];
		if method ~= nil then method(event) end
	end)
end)

return guiSelectionStateChanged
