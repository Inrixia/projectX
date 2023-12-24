local guiElemChanged = require("events/guiElemChanged")

--- @class GuiElement
--- @field public name string
--- @field public children table<string, GuiElement>
--- @field private elementParams LuaGuiElement.add_param
--- @field private _onChanged onGuiElemChanged
local GuiElement = {}
GuiElement.__index = GuiElement

if script then
	script.register_metatable("GuiElement", GuiElement)
end

--- @param name string
--- @param elementParams LuaGuiElement.add_param
--- @param children? table<string, LuaGuiElement.add_param>
function GuiElement.new(name, elementParams, children)
	local self = setmetatable({}, GuiElement)

	self.elementParams = elementParams
	self.elementParams.name = name
	self.name = name
	self.children = {}

	if children ~= nil then
		for childName, child in pairs(children) do
			self.children[childName] = GuiElement.new(self.name .. childName, child)
		end
	end

	return self
end

--- @param method onGuiElemChanged
function GuiElement:onChanged(method) guiElemChanged:add(self.name, method) end

--- @param guiElement LuaGuiElement
--- @returns LuaGuiElement
function GuiElement:addTo(guiElement)
	local guiElement = guiElement.add(self.elementParams)
	for _, child in pairs(self.children) do
		child:addTo(guiElement)
	end
	return guiElement
end

--- @class GuiElementInstance
--- @field public guiElem GuiElement
--- @field public elem LuaGuiElement
local GuiElementInstance = {}
GuiElementInstance.__index = GuiElementInstance

--- @param guiElement GuiElement
--- @param luaElement LuaGuiElement
function GuiElementInstance.new(guiElement, luaElement)
	local self = setmetatable({}, GuiElementInstance)

	self.guiElem = guiElement
	self.elem = luaElement

	return self
end

--- @param name string
--- @returns GuiElementInstance
function GuiElementInstance:childInst(name)
	local fullName = self.guiElem.name .. name
	for _, child in ipairs(self.elem.children) do
		if child.name == fullName then return GuiElementInstance.new(self.guiElem.children[child.name], child) end
	end
end

--- @param name string
--- @returns LuaGuiElement
function GuiElementInstance:child(name)
	local fullName = self.guiElem.name .. name
	for _, child in ipairs(self.elem.children) do
		if child.name == fullName then return child end
	end
end

--- @param parentElement LuaGuiElement
--- @returns GuiElementInstance
function GuiElement:tryAddTo(parentElement)
	for _, element in ipairs(parentElement.children) do
		if element.name == self.name then
			return GuiElementInstance.new(self, element)
		end
	end
	return GuiElementInstance.new(self, self:addTo(parentElement))
end

return GuiElement
