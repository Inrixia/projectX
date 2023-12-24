local guiElemChanged = require("events/guiElemChanged")

--- @class GuiElement
--- @field public name string
--- @field private elementParams LuaGuiElement.add_param
--- @field private _onChanged onGuiElemChanged
local GuiElement = {}
GuiElement.__index = GuiElement

--- @param name string
--- @param elementParams LuaGuiElement.add_param
function GuiElement.new(name, elementParams)
	local self = setmetatable({}, GuiElement)

	self.elementParams = elementParams
	self.elementParams.name = name
	self.name = name

	return self
end

--- @param method onGuiElemChanged
function GuiElement:onChanged(method) guiElemChanged:add(self.name, method) end

--- @param guiElement LuaGuiElement
--- @returns LuaGuiElement
function GuiElement:addTo(guiElement)
	return guiElement.add(self.elementParams)
end

return GuiElement
