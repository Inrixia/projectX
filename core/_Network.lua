--- @class StorageWithNetwork
--- @field network Network
--- @field adjacent StorageWithNetwork[]

--- @alias refLookupTable table<integer, StorageWithNetwork >

--- @class Network
--- @field refs table<string, refLookupTable>
--- @field refsCount integer
Network = {}
Network.__index = Network

script.register_metatable("Network", Network)

function Network.new()
	local self = setmetatable({}, Network)
	self.refs = {}
	self.refsCount = 0
	return self
end

--- @alias Network.getRefs fun(self: Network, entityName: string): refLookupTable

--- @type Network.getRefs
function Network:getRefs(entityName)
	if self.refs[entityName] == nil then self.refs[entityName] = {} end
	local refs = self.refs;

	--- @type Network.getRefs
	self.getRefs = function(_, entityName) return refs[entityName] end

	return self:getRefs(entityName)
end

--- @type fun(name: string, unit_number: integer, storage: StorageWithNetwork, adjacentStorage: StorageWithNetwork|nil)
function Network.mergeStorage(name, unit_number, storage, adjacentStorage)
	if adjacentStorage ~= nil then
		if storage.network == nil then
			adjacentStorage.network:add(name, unit_number, storage)
		else
			Network.merge(storage.network, adjacentStorage.network)
		end
		table.insert(storage.adjacent, adjacentStorage)
		table.insert(adjacentStorage.adjacent, storage)
	end
end

--- @type onEntityCreated
function Network.onEntityCreated(event)
	local entity = event.created_entity
	local name = entity.name
	local unit_number = entity.unit_number

	local x = entity.position.x
	local y = entity.position.y

	local entityStorage = Network.ensureEntityNetworkStorage(x, y)

	Network.mergeStorage(name, unit_number, entityStorage, Network.getNetworkStorage(x, y - 1)) -- Above
	Network.mergeStorage(name, unit_number, entityStorage, Network.getNetworkStorage(x, y + 1)) -- Below
	Network.mergeStorage(name, unit_number, entityStorage, Network.getNetworkStorage(x - 1, y)) -- Left
	Network.mergeStorage(name, unit_number, entityStorage, Network.getNetworkStorage(x + 1, y)) -- Right

	if entityStorage.network == nil then
		Network.new():add(entity.name, entity.unit_number, entityStorage)
	end

	print(entityStorage.network.refsCount)
end

--- @type onEntityRemoved
function Network.onEntityRemoved(event)

end

--- @type fun(self: Network, name: string, unit_number: integer, storage: StorageWithNetwork)
function Network:add(name, unit_number, storage)
	self:getRefs(name)[unit_number] = storage
	self.refsCount = self.refsCount + 1
	storage.network = self
end

--- @param entityName string
--- @param unit_number integer
function Network:remove(entityName, unit_number)
	local refStorage = self:getRefs(entityName)
	if (refStorage[unit_number] == nil) then return end

	refStorage[unit_number] = nil
	self.refsCount = self.refsCount - 1
end

--- @param networkA Network
--- @param networkB Network
function Network.merge(networkA, networkB)
	if networkA == networkB then return end

	local largerNetwork
	local smallerNetwork

	if networkA.refsCount >= networkB.refsCount then
		largerNetwork = networkA
		smallerNetwork = networkB
	else
		largerNetwork = networkB
		smallerNetwork = networkA
	end

	for entityName, refLookupTable in pairs(smallerNetwork.refs) do
		for unit_number, storage in pairs(refLookupTable) do
			largerNetwork:add(entityName, unit_number, storage)
		end
	end

	return largerNetwork
end

function Network.ensureNetworkEntities()
	if global.networkEntites == nil then global.networkEntites = {} end
	return global.networkEntites
end

--- @alias Network.ensureNetworkStorage fun(x: number, y: number): StorageWithNetwork
--- @type Network.ensureNetworkStorage
function Network.ensureEntityNetworkStorage(x, y)
	local networkStorage = Network.ensureNetworkEntities()

	--- @type Network.ensureNetworkStorage
	Network.ensureEntityNetworkStorage = function(x, y)
		if networkStorage[x] == nil then networkStorage[x] = {} end
		if networkStorage[x][y] == nil then networkStorage[x][y] = { adjacent = {}, network = nil } end
		return networkStorage[x][y]
	end
	return Network.ensureEntityNetworkStorage(x, y)
end

--- @alias Network.getNetworkStorage fun(x: number, y: number): StorageWithNetwork|nil
--- @type Network.getNetworkStorage
function Network.getNetworkStorage(x, y)
	local networkStorage = Network.ensureNetworkEntities()

	--- @type Network.getNetworkStorage
	Network.getNetworkStorage = function(x, y)
		if networkStorage[x] == nil then return nil end
		return networkStorage[x][y]
	end
	return Network.getNetworkStorage(x, y)
end

--- @alias Network.clearNetworkStorage fun(x: number, y: number)
--- @type Network.clearNetworkStorage
function Network.clearNetworkStorage(x, y)
	local networkStorage = Network.ensureNetworkEntities()

	--- @type Network.clearNetworkStorage
	Network.clearNetworkStorage = function(x, y)
		if networkStorage[x] == nil then return end
		networkStorage[x][y] = nil
	end
	Network.clearNetworkStorage(x, y)
end

return Network
