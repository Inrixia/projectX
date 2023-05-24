StorageInventory = nil;
ExchangeRate = {
    ["iron-plate"] = 1,
    ["copper-plate"] = 2,
}
EMC = 100;
EMCOverflow = 0;
PreviousStorage = {};

function PopulateStorage()
    if StorageInventory == nil then
        return
    end

    StorageInventory.clear()
    PreviousStorage = {}
    EMCOverflow = 0;

    if EMC == 0 then
        return
    end

    for name, rate in pairs(ExchangeRate) do
        local count = math.floor(EMC / rate);
        local item_prototype = game.item_prototypes[name]
        local max_stack_size = item_prototype.stack_size

        if (count >= 1) then
            -- Limit count to the max stack size
            count = math.min(count, max_stack_size)

            EMCOverflow = EMCOverflow + EMC % rate;

            StorageInventory.insert{name = name, count = count}
            PreviousStorage[name] = count;
        end
    end
    
end

function OnCreate(event)
    local entity = event.created_entity
    if entity.name == "exchange-entity" then
        StorageInventory = entity.get_inventory(defines.inventory.chest)
        StorageInventory.clear()
    end
end

function OnDestroy(event)
    local entity = event.entity
    if entity.name == "exchange-entity" then
        StorageInventory = nil;
    end
end

function OnTick(event)
    if StorageInventory ~= nil then
        local emcChange = 0;

        -- Store the contents of StorageInventory
        local storageContents = StorageInventory.get_contents()

        -- Create a table with unique keys from both storageContents and PreviousStorage
        local combinedKeys = {}
        for name in pairs(storageContents) do combinedKeys[name] = true end
        for name in pairs(PreviousStorage) do combinedKeys[name] = true end

        -- Iterate over combinedKeys
        for name in pairs(combinedKeys) do
            local newCount = storageContents[name] or 0
            local oldCount = PreviousStorage[name] or 0
            emcChange = emcChange + (newCount - oldCount) * (ExchangeRate[name] or 0)
        end

        EMC = math.max(0, EMC + emcChange + EMCOverflow);

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