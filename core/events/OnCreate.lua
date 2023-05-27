local Requester = require("core/proto/Requester")

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
}, function(event)
    Requester.OnCreate(event)
end)