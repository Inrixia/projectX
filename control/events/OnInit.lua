local CalculateRecipiesComplexity = require("control/lib/CalculateRecipeComplexity.lua")
local Requester = require("prototypes/Requester")

local function OnInit()
	CalculateRecipiesComplexity()
	Requester:OnInit()
end

return OnInit;