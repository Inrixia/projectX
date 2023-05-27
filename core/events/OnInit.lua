local calculateRecipiesComplexity = require("core/lib/calculateRecipeComplexity.lua")
local Requester = require("core/proto/Requester")

local function OnInit(event)
	calculateRecipiesComplexity()
	Requester.OnInit()
end

return OnInit;