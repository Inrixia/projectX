local guiElemChanged = require("events/guiElemChanged")
local guiClicked = require("events/guiClicked")

--- @class GuiElement
--- @field public name string
--- @field private addParams LuaGuiElement.add_param
--- @field private _onChanged onGuiElemChanged
local GuiElement = {}
GuiElement.__index = GuiElement

if script then
	script.register_metatable("GuiElement", GuiElement)
end

--- @param name string
--- @param addParams LuaGuiElement.add_param
function GuiElement.new(name, addParams)
	local self = setmetatable({}, GuiElement)

	self.name = name

	addParams.name = name
	self.addParams = addParams

	return self
end

--- @param method onGuiElemChanged
function GuiElement:onChanged(method) guiElemChanged:add(self.name, method) end

--- @param parentElement LuaGuiElement
function GuiElement:addTo(parentElement) return parentElement.add(self.addParams) end

--- @param parentElement LuaGuiElement
--- @param name string
--- @returns GuiElementInstance
function GuiElement.remove(parentElement, name)
	for _, element in ipairs(parentElement.children) do
		if element.name == name then
			element.destroy()
			break
		end
	end
end

--- @param parentElement LuaGuiElement
--- @param addParams LuaGuiElement.add_param
function GuiElement.addOrReplace(parentElement, addParams)
	if (addParams.name ~= nil) then GuiElement.remove(parentElement, addParams.name) end
	return parentElement.add(addParams)
end

--- @param guiElement LuaGuiElement
--- @param caption string
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

	guiClicked:add("__close-button__", function(event)
		event.element.parent.parent.destroy()
	end)
end

return GuiElement
