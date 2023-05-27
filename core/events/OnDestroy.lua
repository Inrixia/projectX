local Requester = require("core/proto/Requester")

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_robot_mined_entity,
    defines.events.on_player_mined_entity
}, function(event)
    Requester.OnDestroy(event)
end)