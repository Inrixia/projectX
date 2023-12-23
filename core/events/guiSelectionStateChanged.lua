local EventHandler = require("EventHandler")

--- @class GuiSelectionStateChanged : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: fun(event:EventData.on_robot_built_entity))
--- @field remove fun(self: EventHandler, prototypeName: string)
local guiSelectionStateChanged = EventHandler.new(defines.events.on_robot_built_entity, function(methods)
	script.on_event(defines.events.on_gui_selection_state_changed, function(event)
		local method = methods[event.element.name];
		if method ~= nil then method(event) end
	end)
end)

return guiSelectionStateChanged
