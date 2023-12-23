local handlers = nil

--- @param method fun()
function init(method)
	if (handlers == nil) then
		handlers = {}
		script.on_init(function()
			for _, handler in pairs(handlers) do
				handler()
			end
		end)
	end
	table.insert(handlers, method)
end

return init
