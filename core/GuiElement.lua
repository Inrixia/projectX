local guiElemChanged = require("events/guiElemChanged")

--- @class GuiElement
--- @field public name string
--- @field public children table<string, GuiElement>
--- @field public elem LuaGuiElement.add_param
--- @field protected _onChanged onGuiElemChanged
local GuiElement = {}
GuiElement.__index = GuiElement

if script then
	script.register_metatable("GuiElement", GuiElement)
end

--- @param name string
--- @param elementParams LuaGuiElement.add_param
--- @param children? GuiElement[]
function GuiElement.new(name, elementParams, children)
	local self = setmetatable({}, GuiElement)

	self.elem = elementParams
	self.elem.name = name
	self.name = name
	self.children = {}

	if children ~= nil then
		for _, child in ipairs(children) do
			self.children[child.name] = child
		end
	end

	return self
end

--- @param name string
--- @param child LuaGuiElement.add_param
function GuiElement:addChild(name, child)
	child.name = name
	self.children[name] = GuiElement.new(name, child)
end

--- @param method onGuiElemChanged
function GuiElement:onChanged(method) guiElemChanged:add(self.name, method) end

--- @param guiElement LuaGuiElement
--- @returns LuaGuiElement
function GuiElement:addTo(guiElement)
	local guiElement = guiElement.add(self.elem)
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
function GuiElement:open(parentElement)
	for _, element in ipairs(parentElement.children) do
		if element.name == self.name then
			element.destroy()
			break
		end
	end
	return GuiElementInstance.new(self, self:addTo(parentElement))
end

return GuiElement
