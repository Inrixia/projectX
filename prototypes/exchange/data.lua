local exchangeEntity = require("entity")
local exchangePowerEntity = require("power")

-- Item
local exchangeItem = table.deepcopy(data.raw.item["iron-chest"])
exchangeItem.name = "exchange"
exchangeItem.place_result = exchangeEntity.name

-- Recipe
local exchangeItemRecipe = table.deepcopy(data.raw.recipe["iron-chest"])
exchangeItemRecipe.enabled = true
exchangeItemRecipe.name = exchangeItem.name
exchangeItemRecipe.ingredients = {{"iron-plate", 20},{"electronic-circuit", 10}}
exchangeItemRecipe.result = exchangeItem.name

data:extend{exchangeItem, exchangeItemRecipe, exchangeEntity, exchangePowerEntity}