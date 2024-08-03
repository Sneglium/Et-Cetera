
if minetest.settings: get_bool('etc.door_tweaks_climb_trapdoors', true) then
	for name, _ in pairs(doors.registered_trapdoors) do
		if name: find '_open' then
			minetest.override_item(name, {
				walkable = false, climbable = true
			})
		end
	end
end

local door_dir_map = {
	[0] = {
		a = {'x', 1},
		b = {'x', -1}
	},
	[1] = {
		a = {'z', -1},
		b = {'z', 1}
	},
	[2] = {
		a = {'x', -1},
		b = {'x', 1}
	},
	[3] = {
		a = {'z', 1},
		b = {'z', -1}
	}
}

if minetest.settings: get_bool('etc.door_tweaks_double_doors', true) then
	local old_door_toggle = doors.door_toggle
	function doors.door_toggle (pos, node, clicker)
		local first_toggle = old_door_toggle(pos, node, clicker)
		
		if (not pos) or (not node) or (not clicker) then return false end
		
		if first_toggle and door_dir_map[node.param2] then
			local meta = minetest.get_meta(pos)
			local newpos
			
			if meta: get_string 'last_door_pos' ~= '' then
				newpos = minetest.deserialize(meta: get_string 'last_door_pos')
			else
				local side = node.name: sub(-2, -1) == '_a' and 'a' or 'b'
				newpos = vector.copy(pos)
				
				local index = door_dir_map[node.param2][side][1]
				local add = door_dir_map[node.param2][side][2]
				
				newpos[index] = newpos[index] + add
				meta: set_string('last_door_pos', minetest.serialize(newpos))
			end
			
			local newnode = minetest.get_node(newpos)
			
			if doors.registered_doors[newnode.name] and newnode.name ~= node.name and node.param2 % 2 == newnode.param2 % 2 then
				old_door_toggle(newpos, newnode, clicker)
				
				local meta = minetest.get_meta(newpos)
				meta: set_string('last_door_pos', minetest.serialize(pos))
			end
		end
		
		return first_toggle
	end
end

if minetest.settings: get_bool('etc.door_tweaks_connected_trapdoors', true) then
	local trapdoor_radius = minetest.settings: get 'etc.door_tweaks_connected_trapdoors_spread' or 2
	
	local old_trapdoor_toggle = doors.trapdoor_toggle
	function doors.trapdoor_toggle (pos, node, clicker)
		local first_toggle = old_trapdoor_toggle(pos, node, clicker)
		
		if (not pos) or (not node) or (not clicker) then return false end
		
		if first_toggle ~= false then
			local pos_add = pos + vector.new(trapdoor_radius, 0, trapdoor_radius)
			local pos_sub = pos - vector.new(trapdoor_radius, 0, trapdoor_radius)
			
			local trapdoors = minetest.find_nodes_in_area(pos_add, pos_sub, node.name, true)
			
			if trapdoors[node.name] then
				for _, v in pairs(trapdoors[node.name]) do
					if v ~= pos then
						old_trapdoor_toggle(v, minetest.get_node(v), clicker)
					end
				end
			end
		end
		
		return first_toggle
	end
end
