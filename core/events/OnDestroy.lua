local Requester = require("core/proto/Requester")

local function OnDestroy(event)
    Requester.OnDestroy(event)
end

return OnDestroy