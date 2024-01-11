local Dict = require("storage/Dict")

--- @class Network
--- @field channels integer
--- @field refs Dict
Network = {}
Network.__index = Network

script.register_metatable("Network", Network)

--- @param netEntity NetEntity?
function Network.from(netEntity)
	local self = setmetatable({}, Network)
	self.channels = 0
	self.refs = Dict.new()
	if netEntity ~= nil then self:add(netEntity) end
	return self
end

--- @param netEntity NetEntity
function Network:add(netEntity)
	netEntity.network = self
	self.refs[netEntity.unit_number] = netEntity
	print(#self.refs)
end

--- @param netEntity NetEntity
function Network:remove(netEntity)
	netEntity.network = nil
	self.refs:remove(netEntity.unit_number)
	print(#self.refs)
end

--- @param previous integer
--- @param new integer
function Network:updateChannels(previous, new)
	self.channels = self.channels + (new - previous)
	print(self.channels)
end

--- @param unit_number integer
--- @param netEntity NetEntity
--- @param visitedSet Dict
local function depthFirstSearch(unit_number, netEntity, visitedSet)
	visitedSet[unit_number] = netEntity
	for unit_number, neighbor in pairs(netEntity.adjacent) do
		if visitedSet[unit_number] == nil then
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


--- @param netEntity NetEntity
function Network.split(netEntity)
	--- @type Dict[]
	local visitedSets = {}
	local largestSetSize = 0
	local largestSetIndex = nil

	--- @type fun(unit_number: number): boolean
	local function haveVisited(unit_number)
		for _, visitedSet in ipairs(visitedSets) do
			if (visitedSet[unit_number] ~= nil) then return true end
		end
		return false
	end

	-- Visit all nodes and track sets
	for unit_number, adjacentNetEntity in pairs(netEntity.adjacent) do
		if not haveVisited(unit_number) then
			local visitedSet = Dict.new()
			depthFirstSearch(unit_number, adjacentNetEntity, visitedSet)

			-- If the first search returns all adjacent nodes then there is no new networks
			if #visitedSets == 0 and allKeysIn(netEntity.adjacent, visitedSet) then return end

			table.insert(visitedSets, visitedSet)
			if #visitedSet > largestSetSize then
				largestSetSize = #visitedSet
				largestSetIndex = #visitedSets
			end
		end
	end

	-- Create new networks for each set, skipping the largest
	for i, visited in ipairs(visitedSets) do
		if i ~= largestSetIndex then
			local newNetwork = Network.from()
			for _, visitedNetEntity in pairs(visited) do
				visitedNetEntity.network:remove(visitedNetEntity)
				newNetwork:add(visitedNetEntity)
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

	if #networkA.refs >= #networkB.refs then
		largerNetwork = networkA
		smallerNetwork = networkB
	else
		largerNetwork = networkB
		smallerNetwork = networkA
	end

	for _, netEntity in pairs(smallerNetwork.refs) do
		largerNetwork:add(netEntity)
	end

	return largerNetwork
end

return Network
