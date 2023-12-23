local EventHandler = require("EventHandler")

local function indexHash(player_index, element_index)
	local global_index = 5381
	global_index = (global_index * 33) + player_index
	global_index = (global_index * 33) + element_index
	return global_index
end

--- @alias onGuiElemChanged fun(event:EventData.on_gui_elem_changed)

--- @class GuiElemChanged : EventHandler
--- @field add fun(self: EventHandler, elementName: string, method: onGuiElemChanged)
--- @field remove fun(self: EventHandler, elementName: string)
local guiElemChanged = EventHandler.new(defines.events.on_gui_elem_changed, function(methods)
	script.on_event(defines.events.on_gui_elem_changed, function(event)
		local method = methods[indexHash(event.player_index, event.element.index)];
		if method ~= nil then method(event) end
	end)
end)

--- @param guiElement LuaGuiElement
--- @param player LuaPlayer
--- @param method onGuiElemChanged
function add(guiElement, player, method) guiElemChanged:add(indexHash(guiElement.index, player.index), method) end

--- @param guiElement LuaGuiElement
--- @param player LuaPlayer
function remove(guiElement, player) guiElemChanged:remove(indexHash(guiElement.index, player.index)) end

return {
	add = add,
	remove = remove
}
