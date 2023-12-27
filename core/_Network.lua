--- @class StorageWithNetwork
--- @field network Network
--- @field adjacent StorageWithNetwork[]

--- @alias refLookupTable table<integer, StorageWithNetwork>

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

--- @param entityName string
--- @param storage StorageWithNetwork
--- @param unit_number integer
function Network:add(entityName, storage, unit_number)
	self:getRefs(entityName)[unit_number] = storage
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
			largerNetwork:add(entityName, storage, unit_number)
		end
	end

	return largerNetwork
end

return Network
