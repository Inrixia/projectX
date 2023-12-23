local indexHash = require("indexHash")
local EventHandler = require("EventHandler")

--- @alias onGuiClosed fun(event:EventData.on_gui_closed)

--- @class GuiClosed : EventHandler
--- @field add fun(self: EventHandler, index: integer, method: onGuiClosed)
--- @field remove fun(self: EventHandler, index: integer)
local guiClosed = EventHandler.new(defines.events.on_gui_closed, function(methods)
	script.on_event(defines.events.on_gui_closed, function(event)
		if event.element == nil then return end
		local method = methods[indexHash(event.element.index, event.player_index)]
		if method ~= nil then method(event) end
	end)
end)

--- @param guiElement LuaGuiElement
--- @param player LuaPlayer
--- @param method onGuiElemChanged
function add(guiElement, player, method) guiClosed:add(indexHash(guiElement.index, player.index), method) end

--- @param guiElement LuaGuiElement
--- @param player LuaPlayer
function remove(guiElement, player) guiClosed:remove(indexHash(guiElement.index, player.index)) end

return {
	add = add,
	remove = remove
}
