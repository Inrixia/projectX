local indexHash = require("indexHash")
local EventHandler = require("EventHandler")


--- @alias onGuiElemChanged fun(event:EventData.on_gui_elem_changed)

--- @class GuiElemChanged : EventHandler
--- @field add fun(self: EventHandler, index: integer, method: onGuiElemChanged)
--- @field remove fun(self: EventHandler, index: integer)
local guiElemChanged = EventHandler.new(defines.events.on_gui_elem_changed, function(methods)
	script.on_event(defines.events.on_gui_elem_changed, function(event)
		local method = methods[indexHash(event.element.index, event.player_index)];
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
