function isSequentialArray(tbl)
	local i = 0
	for _ in pairs(tbl) do
		i = i + 1
		if tbl[i] == nil then return false end
	end
	return true
end

function objToStr(obj, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("  ", indentLevel) -- 2 spaces per indent level

	if type(obj) == "string" then
		return string.format("%q", obj)
	elseif type(obj) ~= "table" then
		return tostring(obj)
	end

	local result = "{\n"
	for k, v in pairs(obj) do
		local formattedKey = objToStr(k, indentLevel + 1) .. ": "
		result = result .. indent .. "  " .. formattedKey .. objToStr(v, indentLevel + 1) .. ",\n"
	end
	result = result:sub(1, -3) .. "\n" .. indent .. "}"
	return result
end

return objToStr
