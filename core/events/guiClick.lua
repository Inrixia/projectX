local EventHandler = require("EventHandler")

--- @class GuiClick : EventHandler
--- @field add fun(self: EventHandler, prototypeName: string, method: fun(event:EventData.on_gui_click))
--- @field remove fun(self: EventHandler, prototypeName: string)
local guiClick = EventHandler.new(defines.events.on_gui_click, function()
	script.on_event(defines.events.on_gui_click, function()
		local nothing = nil
	end)
end)

return guiClick
