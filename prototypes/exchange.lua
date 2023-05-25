-- Entity
local exchangeEntity = table.deepcopy(data.raw["linked-container"]["linked-chest"])
exchangeEntity.name = "exchange-entity"
exchangeEntity.inventory_size = 12*100
exchangeEntity.gui_mode = "none"
exchangeEntity.minable.result = "exchange"

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

-- local exchangePowerEntity = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
-- exchangePowerEntity.name = "exchange-entity-power"
-- exchangePowerEntity.energy_source = {
--     type = "electric",
--     usage_priority = "secondary-input",
--     buffer_capacity = "5MJ"  -- Set this according to your needs
-- }
-- exchangePowerEntity.picture = {
--     filename = "__core__/graphics/empty.png",
--     width = 1,
--     height = 1,
--     shift = util.by_pixel(0, 0)
-- }
-- exchangePowerEntity.localised_name = {"", "Exchange"}

-- -- Make it non-collidable and non-selectable
-- exchangePowerEntity.collision_box = nil
-- exchangePowerEntity.selection_box = nil
-- exchangePowerEntity.selectable = false
-- exchangePowerEntity.collision_mask = {}

data:extend{exchangeItem, exchangeItemRecipe, exchangeEntity}