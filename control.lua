local OnCreate = require("control/events/OnCreate")
local OnDestroy = require("control/events/OnDestroy")
local OnTick = require("control/events/OnTick")
local OnInit = require("control/events/OnInit")

script.on_init(OnInit)

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive
}, OnCreate)

script.on_event({
    defines.events.on_entity_died,
    defines.events.script_raised_destroy,
    defines.events.on_robot_mined_entity,
    defines.events.on_player_mined_entity
}, OnDestroy)

script.on_event(defines.events.on_tick, OnTick)