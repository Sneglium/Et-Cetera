
-- Null coalescing function
function Etc.NLC (value, default)
	if value == nil then
		return default
	else
		return value
	end
end
