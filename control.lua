local OnCreate = require("core/events/OnCreate")
local OnDestroy = require("core/events/OnDestroy")
local OnTick = require("core/events/OnTick")
local OnInit = require("core/events/OnInit")

script.on_init(OnInit)

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
}, OnCreate)

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_robot_mined_entity,
    defines.events.on_player_mined_entity
}, OnDestroy)

script.on_nth_tick(15, OnTick)