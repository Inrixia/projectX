StorageInventory = nil;
ExchangeRate = {
    ["iron-plate"] = 1,
    ["copper-plate"] = 2,
}
EMC = 200;
EMCOverflow = 0;
PreviousStorage = {};

function PopulateStorage()
    if StorageInventory == nil or EMC == 0 then
        return
    end

    StorageInventory.clear()
    PreviousStorage = {}
    EMCOverflow = 0;

    for name, rate in pairs(ExchangeRate) do
        local count = EMC / rate;
        EMCOverflow = EMCOverflow + EMC % rate;
        if (count <= 0) then
            StorageInventory.remove{name = name}
        else
            StorageInventory.insert{name = name, count = count}
            PreviousStorage[name] = count;
        end
    end
end

function OnCreate(event)
    local entity = event.created_entity
    if entity.name == "exchange-entity" then
        StorageInventory = entity.get_inventory(defines.inventory.chest)
    end
end

function OnDestroy(event)
    local entity = event.entity
    if entity.name == "exchange-entity" then
        StorageInventory = nil;
    end
end

function OnTick(event)
    -- if event.tick % 120 ~= 0 then
    --     return
    -- end
    if StorageInventory ~= nil then
        local emcChange = 0;
        for name, count in pairs(StorageInventory.get_contents()) do
            emcChange = emcChange + (count - (PreviousStorage[name] or 0)) * (ExchangeRate[name] or 0)
        end

        EMC = EMC + emcChange + EMCOverflow;

        PopulateStorage()
    end
end

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

script.on_event({defines.events.on_tick}, OnTick)