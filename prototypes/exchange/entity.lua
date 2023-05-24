local exchangeEntity = table.deepcopy(data.raw["linked-container"]["linked-chest"])
exchangeEntity.name = "exchange-entity"
exchangeEntity.inventory_size = 12*100
exchangeEntity.gui_mode = "none"
exchangeEntity.minable.result = "exchange"

return exchangeEntity