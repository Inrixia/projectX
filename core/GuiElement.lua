local guiElemChanged = require("events/guiElemChanged")
local guiClicked = require("events/guiClicked")

--- @alias onCreate fun(parentElement: LuaGuiElement): LuaGuiElement

--- @class GuiElement
--- @field public name string
--- @field private _onCreate onCreate
local GuiElement = {}
GuiElement.__index = GuiElement

script.register_metatable("GuiElement", GuiElement)

--- @param name string
--- @param onCreate onCreate|table onCreate callback or a table with properties.
function GuiElement.new(name, onCreate)
	local self = setmetatable({}, GuiElement)

	self.name = name

	if type(onCreate) == "function" then
		self._onCreate = onCreate
	elseif type(onCreate) == "table" then
		self._onCreate = function(parentElement)
			return parentElement.add(onCreate)
		end
	else
		error("GuiElement onCreate must be either a function or a table")
	end

	return self
end

--- @param method onGuiElemChanged
function GuiElement:onChanged(method) guiElemChanged:add(self.name, method) end

--- @param caption string
--- @returns GuiElement
function GuiElement:withTitlebar(caption)
	local oldOnCreate = self._onCreate
	self._onCreate = function(parentElement)
		return GuiElement.addTitlebar(oldOnCreate(parentElement), caption)
	end
	ensureCloseButtonEvent()
	return self
end

--- @param child GuiElement
--- @returns GuiElement
function GuiElement:addChild(child)
	local oldOnCreate = self._onCreate
	self._onCreate = function(parentElement)
		local thisElement = oldOnCreate(parentElement)
		child:addTo(thisElement)
		return thisElement
	end
	return self
end

--- @param parentElement LuaGuiElement
--- @returns LuaGuiElement
function GuiElement:addTo(parentElement)
	local newElement = self._onCreate(parentElement)
	newElement.name = self.name
	return newElement
end

--- @param parentElement LuaGuiElement
--- @returns LuaGuiElement
function GuiElement:ensureOn(parentElement)
	return GuiElement.getChild(parentElement, self.name) or self:addTo(parentElement)
end

--- @param guiElement LuaGuiElement
--- @param caption string
--- @returns LuaGuiElement
function GuiElement.addTitlebar(guiElement, caption)
	local titlebar = guiElement.add { type = "flow" }
	titlebar.drag_target = guiElement
	titlebar.add {
		type = "label",
		style = "frame_title",
		caption = caption,
		ignored_by_interaction = true,
	}
	local filler = titlebar.add {
		type = "empty-widget",
		style = "draggable_space",
		ignored_by_interaction = true,
	}
	filler.style.height = 24
	filler.style.horizontally_stretchable = true
	titlebar.add {
		type = "sprite-button",
		name = "__close-button__",
		style = "frame_action_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		tooltip = { "gui.close-instruction" },
	}
	ensureCloseButtonEvent()
	return guiElement
end

function ensureCloseButtonEvent()
	guiClicked:add("__close-button__", function(event)
		event.element.parent.parent.visible = false
	end)
end

--- @param parentElement LuaGuiElement
--- @param name string
--- @returns GuiElementInstance
function GuiElement.remove(parentElement, name)
	local element = GuiElement.getChild(parentElement, name)
	if (element ~= nil) then element.remove() end
end

--- @param parentElement LuaGuiElement
--- @param name string
--- @returns GuiElementInstance
function GuiElement.getChild(parentElement, name)
	if name == nil then return nil end
	for _, element in ipairs(parentElement.children) do
		if (element.name == name) then
			return element
		end
	end
end

--- @param parentElement LuaGuiElement
--- @param addParams LuaGuiElement.add_param
--- @returns LuaGuiElement
function GuiElement.addOrReplace(parentElement, addParams)
	if (addParams.name ~= nil) then GuiElement.remove(parentElement, addParams.name) end
	return parentElement.add(addParams)
end

--- @param parentElement LuaGuiElement
--- @param addParams LuaGuiElement.add_param
--- @returns LuaGuiElement
function GuiElement.ensureElement(parentElement, addParams)
	return GuiElement.getChild(parentElement, addParams.name) or parentElement.add(addParams)
end

return GuiElement
