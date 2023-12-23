--- @alias onGuiOpened fun(event:EventData.on_gui_opened)

local notRegistered = true

--- @type table<string, onGuiOpened>
local on_gui_opened_lookup = {}

--- @param prototypeName string
--- @param method onGuiOpened
function onGuiOpened(prototypeName, method)
	on_gui_opened_lookup[prototypeName] = method;

	if notRegistered then
		notRegistered = false
		script.on_event(defines.events.on_gui_opened, function(event)
			if (event.entity == nil) then return end

			local method = on_gui_opened_lookup[event.entity.name];
			if method ~= nil then method(event) end
		end)
	end
end

return onGuiOpened
