require("onBuiltEntity")
require("onRobotBuiltEntity")

--- @alias onBuilt fun(event:EventData.on_built_entity|EventData.on_robot_built_entity)

--- @param prototypeName string
--- @param method onBuilt
function onBuilt(prototypeName, method)
	onRobotBuiltEntity(prototypeName, method)
	onBuiltEntity(prototypeName, method)
end
