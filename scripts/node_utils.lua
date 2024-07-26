
-- rotates a SINGLE box in 90 degree increments around an axis
-- <axis> is either 'x', 'y', or 'z'
-- <amount> is an integer, positive or negative. negative values represent anticlockwise rotation.
-- rotations take place as if the positive direction of the rotating axis is pointing toward the viewpoint
function etc.rotate_nodebox (box, axis, amount)
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

-- Same as above but can handle either a single box or a list of boxes
function etc.rotate_nodeboxes (boxes, axis, amount)
	if type(boxes[1]) == 'number' then
		return etc.rotate_nodebox(boxes, axis, amount)
	end
	
	local new_boxes = {}
	
	for k, v in ipairs(boxes) do
		new_boxes[k] = etc.rotate_nodebox(v, axis, amount)
	end
	
	return new_boxes
end

-- flips a single box along an axis
-- <axis> is either 'x', 'y', or 'z'
function etc.flip_nodebox (box, axis)
	local box2 = table.copy(box)
	
	if axis == 'x' then
		box2[1] = -box[4]
		box2[4] = -box[1]
	elseif axis == 'y' then
		box2[2] = -box[5]
		box2[5] = -box[2]
	else
		box2[3] = -box[6]
		box2[6] = -box[3]
	end
	
	return box2
end

-- Same as above but can handle either a single box or a list of boxes
function etc.flip_nodeboxes (boxes, axis)
	if type(boxes[1]) == 'number' then
		return etc.flip_nodebox(boxes, axis)
	end
	
	local new_boxes = {}
	
	for k, v in ipairs(boxes) do
		new_boxes[k] = etc.flip_nodebox(v, axis)
	end
	
	return new_boxes
end

-- Place a node; if pointing at a node of the same type, copy its' rotation, else rotate as normal
-- Can be used directly as a replacement for a node's on_place method
function etc.copy_or_calculate_rotation (itemstack, placer, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	
	if node.name == itemstack: get_name() and not placer: get_player_control().sneak then
		return minetest.item_place_node(itemstack, placer, pointed_thing, node.param2, true)
	else
		return minetest.rotate_node(itemstack, placer, pointed_thing)
	end
end
