global.StorageContainers = {}

local function CalculateRecipeComplexity(recipe)
    if recipe == nil then return 1 end

    local cost = 0;
    for _, ingredient in pairs(recipe.ingredients) do
        local rate = CalculateRecipeComplexity(game.recipe_prototypes[ingredient.name])
        cost = cost + (ingredient.amount * rate)
        if game.item_prototypes[ingredient.name] ~= nil and cost > 0 then
            global.ExchangeRate[ingredient.name] = rate;
        end
    end
    if cost > 0 then
        for _, product in pairs(recipe.products) do
            if (game.item_prototypes[product.name] ~= nil and (global.ExchangeRate[product.name] or 0) < cost) then 
                global.ExchangeRate[product.name] = cost
            end
        end
    end
    return cost;
end

local function CalculateRecipiesComplexity()
	global.ExchangeRate = {}
    for _, recipe in pairs(game.recipe_prototypes) do
        CalculateRecipeComplexity(recipe)
    end
end

return CalculateRecipiesComplexity