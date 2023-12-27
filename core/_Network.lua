--- @alias refLookupTable table<integer, NetworkStorage>

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
function Network:ensureRefs(entityName)
	if self.refs[entityName] == nil then self.refs[entityName] = {} end
	local refs = self.refs;

	--- @type Network.getRefs
	self.ensureRefs = function(_, entityName) return refs[entityName] end

	return self:ensureRefs(entityName)
end

--- @param name string
--- @param unit_number integer
--- @param storage NetworkStorage
function Network:add(name, unit_number, storage)
	self:ensureRefs(name)[unit_number] = storage
	self.refsCount = self.refsCount + 1
	storage.network = self
end

--- @param name string
--- @param unit_number integer
--- @param storage NetworkStorage
function Network:remove(name, unit_number, storage)
	storage.network = nil

	local refStorage = self:ensureRefs(name)
	if (refStorage[unit_number] ~= nil) then
		refStorage[unit_number] = nil
		self.refsCount = self.refsCount - 1
	end
end

--- @param unit_number integer
--- @param node NetworkStorage
--- @param visited table<integer, NetworkStorage>
function depthFirstSearch(unit_number, node, visited)
	visited[unit_number] = node
	for unit_number, neighbor in pairs(node.adjacent) do
		if not visited[unit_number] then
			depthFirstSearch(unit_number, neighbor, visited)
		end
	end
end

--- @param storage NetworkStorage
function Network.split(storage)
	--- @type table<integer, NetworkStorage>
	local visited = {}
	for unit_number, node in pairs(storage.adjacent) do
		if not visited[unit_number] then
			visited = {}
			depthFirstSearch(unit_number, node, visited)
			local newNetwork = Network.new()
			for unit_number, storage in pairs(visited) do
				for entityName, refLookupTable in pairs(storage.network.refs) do
					if refLookupTable[unit_number] ~= nil then
						storage.network:remove(entityName, unit_number, storage)
						newNetwork:add(entityName, unit_number, storage)
					end
				end
			end
		end
	end
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

return Network
