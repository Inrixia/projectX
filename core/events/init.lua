local initHandlers = nil

--- @param method fun()
function init(method)
	if (initHandlers == nil) then
		initHandlers = {}
		script.on_init(function()
			for _, handler in pairs(initHandlers) do
				handler()
			end
		end)
	end
	table.insert(initHandlers, method)
end

return init
