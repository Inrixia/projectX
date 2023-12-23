local handlers = nil

--- @param method fun()
function load(method)
	if (handlers == nil) then
		handlers = {}
		script.on_load(function()
			for _, handler in pairs(handlers) do
				handler()
			end
		end)
	end
	table.insert(handlers, method)
end

return load
