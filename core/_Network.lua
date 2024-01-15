local Dict = require("storage/Dict")
local NetworkEvent = require("events/NetworkEvent")

--- @alias netEventFun fun(remove: fun())

--- @class Network
--- @field channels integer
--- @field energy double
--- @field refs Dict
--- @field onNoChannels GenericEvent
--- @field onChannels GenericEvent
--- @field onNoEnergy GenericEvent
--- @field onEnergy GenericEvent
Network = {}
Network.__index = Network

script.register_metatable("Network", Network)

--- @param netEnt NetEntity?
function Network.from(netEnt)
	local self = setmetatable({
		channels = 0,
		energy = 0,
		refs = Dict.new(),
		onNoChannels = NetworkEvent.new("onNoChannels"),
		onChannels = NetworkEvent.new("onChannels"),
		onNoEnergy = NetworkEvent.new("onNoEnergy"),
		onEnergy = NetworkEvent.new("onEnergy")
	}, Network)
	if netEnt ~= nil then self:add(netEnt) end
	return self
end

--- @param netEnt NetEntity
function Network:add(netEnt)
	netEnt.network = self
	self.refs[netEnt.unit_number] = netEnt

	self.onChannels:add(netEnt)
	self.onNoChannels:add(netEnt)
	self.onEnergy:add(netEnt)
	self.onNoEnergy:add(netEnt)

	if (self:updateChannels(netEnt.channels)) then
		if self.channels < 0 then
			if netEnt.onNoChannels then netEnt:onNoChannels() end
		else
			if netEnt.onChannels then netEnt:onChannels() end
		end
	end

	if (self:updateEnergy(netEnt.energy)) then
		if self.energy < 0 then
			if netEnt.onNoEnergy then netEnt:onNoEnergy() end
		else
			if netEnt.onEnergy then netEnt:onEnergy() end
		end
	end
end

--- @param netEnt NetEntity
function Network:remove(netEnt)
	netEnt.network = nil
	self.refs:remove(netEnt.unit_number)

	self.onChannels:remove(netEnt.unit_number)
	self.onNoChannels:remove(netEnt.unit_number)
	self.onEnergy:remove(netEnt.unit_number)
	self.onNoEnergy:remove(netEnt.unit_number)

	self:updateChannels(netEnt.channels * -1)
	self:updateEnergy(netEnt.energy * -1)
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
		return false
	end
	return true
end

--- @param diff double
function Network:updateEnergy(diff)
	if diff == 0 then return end
	local lastState = self.energy < 0;
	self.energy = self.energy + diff
	if lastState ~= (self.energy < 0) then
		if self.energy < 0 then
			self.onNoEnergy:execute()
		else
			self.onEnergy:execute()
		end
		return false
	end
	return true
end

--- @param unit_number integer
--- @param netEnt NetEntity
--- @param visitedSet Dict
local function depthFirstSearch(unit_number, netEnt, visitedSet)
	visitedSet[unit_number] = netEnt
	for unit_number, neighbor in pairs(netEnt.adjacent) do
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

	for _, netEnt in pairs(smallerNetwork.refs) do
		largerNetwork:add(netEnt)
	end

	return largerNetwork
end

return Network
