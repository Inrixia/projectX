local Dict = require("storage/Dict")
local GenericEvent = require("events/GenericEvent")

--- @alias netEventFun fun(remove: fun())

--- @class Network
--- @field channels integer
--- @field refs Dict
--- @field protoRefs table<string, integer>
--- @field onNoChannels GenericEvent
--- @field onChannels GenericEvent
Network = {}
Network.__index = Network

script.register_metatable("Network", Network)

--- @param netEntity NetEntity?
function Network.from(netEntity)
	local self = setmetatable({
		channels = 0,
		refs = Dict.new(),
		onNoChannels = GenericEvent.new(),
		onChannels = GenericEvent.new()
	}, Network)
	if netEntity ~= nil then self:add(netEntity) end
	return self
end

--- @param netEntity NetEntity
function Network:add(netEntity)
	netEntity.network = self
	self.refs[netEntity.unit_number] = netEntity

	self.onNoChannels:add(netEntity.unit_number, function()
		if netEntity:base()._onNoChannels == nil then return end
		netEntity:base()._onNoChannels(netEntity)
	end)
	self.onChannels:add(netEntity.unit_number, function()
		if netEntity:base()._onChannels == nil then return end
		netEntity:base()._onChannels(netEntity)
	end)

	if netEntity:base()._onChannels ~= nil then
		netEntity:base()._onChannels(netEntity)
	end


	self:updateChannels(netEntity.channels)
end

--- @param netEntity NetEntity
function Network:remove(netEntity)
	netEntity.network = nil
	self.refs:remove(netEntity.unit_number)

	self.onChannels:remove(netEntity.unit_number)
	self.onNoChannels:remove(netEntity.unit_number)

	self:updateChannels(netEntity.channels * -1)
end

--- @param diff integer
function Network:updateChannels(diff)
	if diff == 0 then return end
	local lastState = self.channels < 0;
	self.channels = self.channels + diff
	if lastState ~= (self.channels < 0) then
		if self.channels < 0 then
			self.onNoChannels:execute()
		else
			self.onChannels:execute()
		end
	end
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


--- @param newLeafs NetEntity[]
function Network.split(newLeafs)
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
	for unit_number, adjacentNetEntity in pairs(newLeafs) do
		if not haveVisited(unit_number) then
			local visitedSet = Dict.new()
			depthFirstSearch(unit_number, adjacentNetEntity, visitedSet)

			-- If the first search returns all adjacent nodes then there is no new networks
			if #visitedSets == 0 and allKeysIn(newLeafs, visitedSet) then return end

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

--- @param otherNet Network
function Network:merge(otherNet)
	if self == otherNet then return end

	local largerNetwork
	local smallerNetwork

	if #self.refs >= #otherNet.refs then
		largerNetwork = self
		smallerNetwork = otherNet
	else
		largerNetwork = otherNet
		smallerNetwork = self
	end

	for _, netEntity in pairs(smallerNetwork.refs) do
		largerNetwork:add(netEntity)
	end

	return largerNetwork
end

return Network
