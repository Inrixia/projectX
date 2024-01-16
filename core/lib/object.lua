--- @alias callOn fun(obj: any, key: string, method: fun(obj: any))

--- @type callOn
function callOn(obj, key, method)
	-- Check if obj is a table
	if type(obj) == 'table' then
		-- Iterate through all key-value pairs in the table
		for _key, value in pairs(obj) do
			-- If the value is a table, call replaceFilename recursively
			if type(value) == 'table' then
				callOn(value, key, method)
			end
			if _key == key then method(obj) end
		end
	end
end

return callOn
