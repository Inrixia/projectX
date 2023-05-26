local calculateRecipiesComplexity = require("control/lib/calculateRecipeComplexity.lua")
local Requester = require("prototypes/Requester")

local function OnInit(event)
	calculateRecipiesComplexity()
	Requester:OnInit(event)
end

return OnInit;