local exchangePowerEntity = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
exchangePowerEntity.name = "exchange-entity-power"
exchangePowerEntity.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "5MJ"  -- Set this according to your needs
}
exchangePowerEntity.picture = {
    filename = "__core__/graphics/empty.png",
    width = 1,
    height = 1,
    shift = util.by_pixel(0, 0)
}
exchangePowerEntity.localised_name = {"", "Exchange"}

-- Make it non-collidable and non-selectable
exchangePowerEntity.collision_box = nil
exchangePowerEntity.selection_box = nil
exchangePowerEntity.selectable = false
exchangePowerEntity.collision_mask = {}

return exchangePowerEntity