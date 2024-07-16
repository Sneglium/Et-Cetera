
local function combine (t, points)
	if #points == 1 then return points end
	
	local new_points = {}
	
	table.insert(new_points, etc.lerp3d(points[1], points[2], t))
	
	if #points > 2 then
		for i = 2, #points-1 do
			table.insert(new_points, etc.lerp3d(points[i], points[i+1], t))
		end
		return combine(t, new_points)
	end
	
	return new_points
end

local bezier_meta = {}

function bezier_meta.__call (self, ...)
	etc.log.assert(select('#', ...) > 1, 'Bezier must have 2 or more initial control points')
	etc.log.assert(etc.is_vector(...), 'Bezier control points must be vectors')
	
	local obj = setmetatable({
		control_points = {},
		first_point = {},
		last_point = {},
	}, etc.bezier_obj_meta)
	
	for i = 1, select('#', ...) do
		if i == 1 then
			obj.first_point = select(i, ...)
		elseif i == select('#', ...) then
			obj.last_point = select(i, ...)
		else
			obj: add_control_point(select(i, ...))
		end
	end
	
	return obj
end

local bezier = {
	add_control_point = function (self, point)
		etc.log.assert(etc.is_vector(point), 'Bezier control point must be a vector')
		table.insert(self.control_points, point)
	end,
	
	get_first_point = function (self)
		return self.first_point
	end,
	
	get_last_point = function (self)
		return self.last_point
	end,
	
	get_point_on_curve = function (self, interval)
		etc.log.assert(etc.is_number(interval) and math.abs(interval) == interval, 'Point on curve position must be a non-negative number')
		
		if interval == 0 then
			return self: get_first_point()
		elseif interval >= 1 then
			return self: get_last_point()
		end
		
		local interval = -interval
		
		local all_points = table.copy(self.control_points)
		table.insert(all_points, 1, self.first_point)
		table.insert(all_points, self.last_point)
		
		if #all_points < 3 then
			return etc.lerp3d(self: get_first_point(), self: get_last_point(), interval)
		else
			return combine(interval, all_points)[1]
		end
	end
}

etc.bezier = setmetatable(bezier, bezier_meta)
etc.bezier_obj_meta = {__index = etc.bezier}
_G['Bezier'] = etc.bezier

local function single_is_bezier (b)
	return getmetatable(b) and getmetatable(b).__index == etc.bezier
end

function etc.is_bezier (...)
	if select('#', ...) == 1 and single_is_bezier(...) then return true end
	
	for i = 1, select('#', ...) do
		if not single_is_bezier(select(i, ...)) then return false end
	end
	
	return true
end
