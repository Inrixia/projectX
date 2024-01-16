function rgbToHsv(r, g, b)
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v
end

function hsvToRgb(h, s, v)
	local r, g, b

	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	if i % 6 == 0 then
		r = v
		g = t
		b = p
	elseif i == 1 then
		r = q
		g = v
		b = p
	elseif i == 2 then
		r = p
		g = v
		b = t
	elseif i == 3 then
		r = p
		g = q
		b = v
	elseif i == 4 then
		r = t
		g = p
		b = v
	elseif i == 5 then
		r = v
		g = p
		b = q
	end

	return r, g, b
end

--- @param tint data.Color?
--- @param hueShift double?
--- @param satShift double?
--- @param brightShift double?
function adjust(tint, hueShift, satShift, brightShift)
	tint = tint or {}
	local red = tint[4] or tint.r or 1
	local green = tint[3] or tint.g or 1
	local blue = tint[2] or tint.b or 1
	local alpha = tint[1] or tint.a or 1
	-- Convert RGB to HSV
	local hue, saturation, brightness = rgbToHsv(red, green, blue)

	if saturation == 0 then saturation = 1 end

	-- Adjust Saturation
	if satShift ~= nil then
		saturation = math.max(-1, math.min(1, saturation + saturation * satShift))
	end

	-- Adjust Value (Brightness)
	if brightShift ~= nil then
		brightness = math.max(-1, math.min(1, brightness + brightness * brightShift))
	end

	-- Adjust Hue
	if hueShift ~= nil then
		hue = (hue + hueShift / 360.0) % 1.0
	end

	-- Convert HSV back to RGB
	red, green, blue = hsvToRgb(hue, saturation, brightness)

	return { a = alpha, b = blue, g = green, r = red }
end

return adjust
