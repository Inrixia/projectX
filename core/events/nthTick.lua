--- @type table<integer, onNthTick[]>
local nthTickHandlers = {}

--- @alias onNthTick fun(event: NthTickEventData, remove: fun())

--- @type fun(tick: integer, method: onNthTick)
function add(tick, method)
	if (nthTickHandlers[tick] == nil) then
		nthTickHandlers[tick] = {}
		script.on_nth_tick(tick, function(eventData)
			for _, handler in pairs(nthTickHandlers[tick]) do handler(eventData, function() remove(tick, handler) end) end
		end)
	end
	table.insert(nthTickHandlers[tick], method)
end

--- @type fun(tick: integer, method: onNthTick)
function remove(tick, method)
	local handlers = nthTickHandlers[tick]
	if handlers then
		for i, handler in ipairs(handlers) do
			if handler == method then
				table.remove(handlers, i)
				break
			end
		end
		if next(handlers) == nil then script.on_nth_tick(tick, nil) end
	end
end

return {
	add = add,
	remove = remove
}
