local playerMinedEntity = require("playerMinedEntity")
local robotMinedEntity = require("robotMinedEntity")
local entityDied = require("entityDied")

--- @alias onEntityRemovedEvent EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died
--- @alias onEntityRemoved fun(event: onEntityRemovedEvent)

--- @param prototypeName string
--- @param method onEntityRemoved
function add(prototypeName, method)
	playerMinedEntity:add(prototypeName, method)
	robotMinedEntity:add(prototypeName, method)
	entityDied:add(prototypeName, method)
end

--- @param prototypeName string
function remove(prototypeName)
	playerMinedEntity:remove(prototypeName)
	robotMinedEntity:remove(prototypeName)
	entityDied:remove(prototypeName)
end

return {
	add = add,
	remove = remove
}
