StorageInventory = nil;
EMC = 1;
EMCOverflow = 0;
PreviousStorage = {};

global.ExchangeRate = {}

local function CalculateRecipeCost(recipe)
    if recipe == nil then return 1 end

    local cost = 0;
    for _, ingredient in pairs(recipe.ingredients) do
        local rate = CalculateRecipeCost(game.recipe_prototypes[ingredient.name])
        cost = cost + (ingredient.amount * rate)
        if game.item_prototypes[ingredient.name] ~= nil and cost > 0 then
            global.ExchangeRate[ingredient.name] = rate;
        end
    end
    if cost > 0 then
        for _, product in pairs(recipe.products) do
            if (game.item_prototypes[product.name] ~= nil) then 
                global.ExchangeRate[product.name] = cost
            end
        end
    end
    return cost;
end

script.on_init(function()
    global.ExchangeRate = {}
    for _, recipe in pairs(game.recipe_prototypes) do
        CalculateRecipeCost(recipe)
    end
end)

function GetDictionaryLength(dictionary)
    local count = 0
    for key, value in pairs(dictionary) do
        count = count + 1
    end
    return count
end

local function isNaN(num)
    return num ~= num
end

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

    for name, rate in pairs(global.ExchangeRate) do
        local count = math.floor(EMC / rate);

        if (count >= 1) then
            -- Limit count to the max stack size
            count = math.min(count, game.item_prototypes[name].stack_size)

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
    if (event.tick % 120 == 0) then
        for _, recipe in pairs(game.recipe_prototypes) do
            CalculateRecipeCost(recipe)
        end
    end
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
            emcChange = emcChange + (newCount - oldCount) * (global.ExchangeRate[name] or 0)
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