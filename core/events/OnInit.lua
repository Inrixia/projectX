local calculateRecipiesComplexity = require("core/lib/calculateRecipeComplexity.lua")
local Requester = require("core/proto/Requester")

script.on_init(function(event)
	calculateRecipiesComplexity()
	Requester.OnInit()
end)