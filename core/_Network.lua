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

--- @param unit_number integer
--- @param storage NetworkStorage
function Network:add(unit_number, storage)
	self:ensureRefs(storage.name)[unit_number] = storage
	self.refsCount = self.refsCount + 1
	storage.network = self
end

--- @param unit_number integer
--- @param storage NetworkStorage
function Network:remove(unit_number, storage)
	storage.network = nil

	local refStorage = self:ensureRefs(storage.name)
	if (refStorage[unit_number] ~= nil) then
		refStorage[unit_number] = nil
		self.refsCount = self.refsCount - 1
	end
end

--- @class VisitedSet
--- @field nodes table<integer, NetworkStorage>
--- @field nodesCount integer

--- @param unit_number integer
--- @param node NetworkStorage
--- @param visitedSet VisitedSet
local function depthFirstSearch(unit_number, node, visitedSet)
	visitedSet.nodes[unit_number] = node
	visitedSet.nodesCount = visitedSet.nodesCount + 1
	for unit_number, neighbor in pairs(node.adjacent) do
		if not visitedSet.nodes[unit_number] then
			depthFirstSearch(unit_number, neighbor, visitedSet)
		end
	end
end

--- Check if all keys in tableA exist in tableB.
--- @param tableA table The first table to compare.
--- @param tableB table The second table to compare.
--- @return boolean Returns true if all keys in tableA are present in tableB, otherwise false.
local function allKeysIn(tableA, tableB)
	for key in pairs(tableA) do
		if not tableB[key] then return false end
	end
	return true
end


--- @param storage NetworkStorage
function Network.split(storage)
	--- @type VisitedSet[]
	local visitedSets = {}
	local largestSetSize = 0
	local largestSetIndex = nil

	--- @type fun(unit_number: number): boolean
	local function haveVisited(unit_number)
		for _, visited in ipairs(visitedSets) do
			if (visited.nodes[unit_number] ~= nil) then return true end
		end
		return false
	end

	-- Visit all nodes and track sets
	for unit_number, node in pairs(storage.adjacent) do
		if not haveVisited(unit_number) then
			--- @type VisitedSet
			local visitedSet = {
				nodes = {},
				nodesCount = 0
			}
			depthFirstSearch(unit_number, node, visitedSet)

			-- If the first search returns all adjacent nodes then there is no new networks
			if #visitedSets == 0 and allKeysIn(storage.adjacent, visitedSet.nodes) then return end

			table.insert(visitedSets, visitedSet)
			if visitedSet.nodesCount > largestSetSize then
				largestSetSize = visitedSet.nodesCount
				largestSetIndex = #visitedSets
			end
		end
	end

	-- Create new networks for each set, skipping the largest
	for i, visited in ipairs(visitedSets) do
		if i ~= largestSetIndex then
			local newNetwork = Network.new()
			for unit_number, visitedStorage in pairs(visited.nodes) do
				visitedStorage.network:remove(unit_number, visitedStorage)
				newNetwork:add(unit_number, visitedStorage)
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

	for _, refLookupTable in pairs(smallerNetwork.refs) do
		for unit_number, storage in pairs(refLookupTable) do
			largerNetwork:add(unit_number, storage)
		end
	end

	return largerNetwork
end

return Network
