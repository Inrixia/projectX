local playerMinedEntity = require("playerMinedEntity")
local robotMinedEntity = require("robotMinedEntity")
local entityDied = require("entityDied")
local scriptDestroyedEntity = require("scriptDestroyedEntity")

--- @alias onEntityRemovedEvent EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died|EventData.script_raised_destroy
--- @alias onEntityRemoved fun(event: onEntityRemovedEvent)

--- @param name string
--- @param method onEntityRemoved
function add(name, method)
	playerMinedEntity:set(name, method)
	robotMinedEntity:set(name, method)
	entityDied:set(name, method)
	scriptDestroyedEntity:set(name, method)
end

--- @param name string
function remove(name)
	playerMinedEntity:remove(name)
	robotMinedEntity:remove(name)
	entityDied:remove(name)
	scriptDestroyedEntity:remove(name)
end

return {
	set = add,
	remove = remove
}
