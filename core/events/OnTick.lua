local Requester = require("core/proto/Requester")

local function OnTick(event)
	Requester.OnTick(event.tick)
end

return OnTick;