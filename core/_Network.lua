local Dict = require("storage/Dict")
local NetworkEvent = require("events/NetworkEvent")

--- @alias netEventFun fun(remove: fun())

--- @class Network
--- @field channels integer
--- @field energy double
--- @field refs Dict
--- @field onNoChannels NetworkEvent
--- @field onChannels NetworkEvent
--- @field onNoEnergy NetworkEvent
--- @field onEnergy NetworkEvent
--- @field onRequestEnergy NetworkEvent
--- @field onEnable NetworkEvent
--- @field onDisable NetworkEvent
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
		onEnergy = NetworkEvent.new("onEnergy"),
		onRequestEnergy = NetworkEvent.new("onRequestEnergy"),
		onEnable = NetworkEvent.new("enable"),
		onDisable = NetworkEvent.new("disable")
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

	self.onRequestEnergy:add(netEnt)

	self.onDisable:add(netEnt)
	self.onEnable:add(netEnt)

	if (not self:updateChannels(netEnt.channels)) then
		if self:hasChannels() then
			if netEnt.onChannels then netEnt:onChannels() end
		else
			if netEnt.onNoChannels then netEnt:onNoChannels() end
		end
	end


	if ((not self:requestEnergy(netEnt.energy)) and (not self:updateEnergy(netEnt.energy))) then
		if self:hasEnergy() then
			if netEnt.onEnergy then netEnt:onEnergy() end
		else
			if netEnt.onNoEnergy then netEnt:onNoEnergy() end
		end
	end

	if self:enabled() then
		if netEnt.enable then netEnt:enable() end
	else
		if netEnt.disable then netEnt:disable() end
	end
end

--- @param netEnt NetEntity
function Network:remove(netEnt)
	netEnt.network = nil
	self.refs:remove(netEnt.unit_number)

	self.onChannels:remove(netEnt)
	self.onNoChannels:remove(netEnt)
	self.onEnergy:remove(netEnt)
	self.onNoEnergy:remove(netEnt)


	self.onEnable:remove(netEnt)
	self.onDisable:remove(netEnt)

	self:updateChannels(netEnt.channels * -1)
	self:updateEnergy(netEnt.energy * -1)
end

function Network:enabled() return self:hasChannels() and self:hasEnergy() end

--- @param method fun()
function Network:updateState(method)
	local previousState = self:enabled()
	method()
	if previousState ~= self:enabled() then
		if self:enabled() then
			self.onEnable:execute()
		else
			self.onDisable:execute()
		end
	end
end

function Network:hasChannels() return self.channels >= 0 end

--- @param diff integer
function Network:updateChannels(diff)
	if diff == 0 then return end
	local lastState = self:hasChannels();
	self:updateState(function() self.channels = self.channels + diff end)
	if lastState ~= self:hasChannels() then
		if self:hasChannels() then
			self.onChannels:execute()
		else
			self.onNoChannels:execute()
		end
		return true
	end
	return false
end

--- @param energyRequired integer
function Network:requestEnergy(energyRequired)
	if energyRequired >= 0 then return false end
	local energyChanged = self.energy + energyRequired
	self.energy = energyChanged
	self.onRequestEnergy:execute()
	if self.energy == energyChanged then
		self.energy = self.energy - energyRequired
		return false
	end
	return true
end

function Network:hasEnergy() return self.energy >= 0 end

--- @param diff double
function Network:updateEnergy(diff)
	if diff == 0 then return end
	local lastState = self:hasEnergy();
	self:updateState(function() self.energy = self.energy + diff end)
	if lastState ~= self:hasEnergy() then
		if self:hasEnergy() then
			self.onEnergy:execute()
		else
			self.onNoEnergy:execute()
		end
		return true
	end
	return false
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
