local loadHandlers = nil

--- @param method fun()
function load(method)
	if (loadHandlers == nil) then
		loadHandlers = {}
		script.on_load(function()
			for _, handler in pairs(loadHandlers) do
				handler()
			end
		end)
	end
	table.insert(loadHandlers, method)
end

return load
