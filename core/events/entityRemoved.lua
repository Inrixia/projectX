local playerMinedEntity = require("playerMinedEntity")
local robotMinedEntity = require("robotMinedEntity")
local entityDied = require("entityDied")
local scriptDestroyedEntity = require("scriptDestroyedEntity")

--- @alias onEntityRemovedEvent EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died|EventData.script_raised_destroy
--- @alias onEntityRemoved fun(event: onEntityRemovedEvent)

--- @param name string
--- @param method onEntityRemoved
function add(name, method)
	playerMinedEntity:add(name, method)
	robotMinedEntity:add(name, method)
	entityDied:add(name, method)
	scriptDestroyedEntity:add(name, method)
end

--- @param name string
function remove(name)
	playerMinedEntity:remove(name)
	robotMinedEntity:remove(name)
	entityDied:remove(name)
	scriptDestroyedEntity:remove(name)
end

return {
	add = add,
	remove = remove
}
