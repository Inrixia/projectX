local Requester = require("prototypes/Requester")

local function OnDestroy(event)
    Requester:OnDestroy(event)
end

return OnDestroy