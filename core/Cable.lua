local NetworkedEntity = require("_NetworkedEntity")

NetworkedEntity.new(require("proto/Cable"))
	:onChannels(function(netEnt)
		netEnt.entity.temperature = 1
	end)
	:onNoChannels(function(netEnt)
		netEnt.entity.temperature = 0
	end)
	:onJoinedNetwork(function(netEnt)
		netEnt.entity.temperature = netEnt.network.channels
	end)
