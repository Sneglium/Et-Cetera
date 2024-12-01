
-- Rotate a SINGLE box in 90 degree increments around an axis.
-- <axis> is either 'x', 'y', or 'z'.
-- <amount> is an integer, positive or negative. Negative values represent anticlockwise rotation.
-- Rotations take place as if the positive direction of the rotating axis is pointing toward the
--> viewpoint, i.e. looking along the axis towards negative.
function Etc.rotateNodebox (box, axis, amount)
	local box = table.copy(box)
	
	local sign = amount > 0 and 1 or amount < 0 and -1 or 0
	if axis == 'y' then
		for i = 1, math.abs(amount) do
			local temp1 = box[1]
			box[1] = box[3] * sign       -- x = z
			box[3] = temp1  * (0 - sign) -- z = -x
			local temp4 = box[4]
			box[4] = box[6] * sign       -- x2 = z2
			box[6] = temp4  * (0 - sign) -- z2 = -x2
		end
	elseif axis == 'z' then
		for i = 1, math.abs(amount) do
			local temp1 = box[1]
			box[1] = box[2] * (0 - sign) -- x = -y
			box[2] = temp1  * sign       -- y = x
			local temp4 = box[4]
			box[4] = box[5] * (0 - sign) -- x2 = -y2
			box[5] = temp4  * sign       -- y2 = x2
		end
	elseif axis == 'x' then
		for i = 1, math.abs(amount) do
			local temp2 = box[2]
			box[2] = box[3] * (0 - sign) -- y = -z
			box[3] = temp2  * sign       -- z = y
			local temp5 = box[5]
			box[5] = box[6] * (0 - sign) -- y2 = -z2
			box[6] = temp5  * sign       -- z2 = y2
		end
	end
	
	return box
end

-- Same as above but can handle either a single box or a list of boxes.
function Etc.rotateNodeboxes (boxes, axis, amount)
	if type(boxes[1]) == 'number' then
		return Etc.rotateNodebox(boxes, axis, amount)
	end
	
	local new_boxes = {}
	
	for k, v in ipairs(boxes) do
		new_boxes[k] = Etc.rotateNodebox(v, axis, amount)
	end
	
	return new_boxes
end
