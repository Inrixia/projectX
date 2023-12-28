--- @class NetworkStorage
--- @field name string
--- @field network Network|nil
--- @field adjacent table<integer, NetworkStorage>

--- @class NetworkStorage : GlobalStorage
--- @field ensure fun(self: GlobalStorage, unit_number: integer, default: NetworkStorage): NetworkStorage
--- @field get fun(self: GlobalStorage, unit_number: integer): NetworkStorage | nil
--- @field set fun(self: GlobalStorage, unit_number: integer, value: NetworkStorage | nil)
local networkStorage = require("global").new("networkedEntity")
return networkStorage
