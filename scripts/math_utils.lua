
-- interpolates between two 3d vectors by <interval> amount
-- if <interval> is negative, it will be treated as an 0-1 percentage
-- note: 3d vectors are usually assumed to be in world space (i.e. units of nodes)
function etc.lerp3d (v1, v2, interval)
	if interval < 0 then
		return v1 + ((v2 - v1) * -interval)
	else
		local dir = vector.direction(v1, v2): normalize()
		return v1 + (dir * interval)
	end
end

-- same as above, but takes two sets of 2d points and returns a similar set
function etc.lerp2d (x1, y1, x2, y2, interval)
	if interval < 0 then
		interval = -interval
		return x1 + ((x2 - x1) * interval), y1 + ((y2 - y1) * interval)
	else
		local v1 = vector.new(x1, y1, 0)
		local v2 = vector.new(x1, y1, 0)
		local dir = vector.direction(v1, v2): normalize()
		local v3 = v1 + (dir * interval)
		return v3.x, v3.y
	end
end
