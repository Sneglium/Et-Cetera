
-- Limit a value between a min and max
function Etc.clamp(n, min, max)
	return math.max(min, math.min(n, max))
end
