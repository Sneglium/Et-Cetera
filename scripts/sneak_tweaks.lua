
local hide_nametag = minetest.settings: get_bool('etc.sneak_tweaks_hide_nametag', true)
local silent_sneak = minetest.settings: get_bool('etc.sneak_tweaks_silent_sneak', true)
local lower_cam = minetest.settings: get_bool('etc.sneak_tweaks_lower_cam', true)
local anti_slip = minetest.settings: get_bool('etc.sneak_tweaks_anti_slip', true)
local reduced_hitbox = minetest.settings: get_bool('etc.sneak_tweaks_reduced_hitbox', true)

local player_stored_physics = {}
local player_stored_eye_height = {}
local player_stored_hitbox = {}

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	
	for i = 1, #players do
		local player = players[i]
		local playername = player: get_player_name()
		local properties = player: get_properties()
		
		local controls = player: get_player_control()
		
		local head_node = minetest.get_node(player: get_pos() + vector.new(0, 1.5, 0))
		local head_node_def = minetest.registered_nodes[head_node.name]
		
		if controls.sneak or head_node_def.walkable then
			if silent_sneak then
				properties.makes_footstep_sound = false
			end
			
			if hide_nametag then
				properties.nametag_color.a = 0
			end
			
			if lower_cam and not player_stored_eye_height[playername] then
				player_stored_eye_height[playername] = properties.eye_height
				properties.eye_height = properties.eye_height - (properties.eye_height * 0.15)
			end
			
			if reduced_hitbox ~= 0 and not player_stored_hitbox[playername] then
				player_stored_hitbox[playername] = properties.collisionbox[5]
				properties.collisionbox[5] = properties.collisionbox[5] - 0.7
			end
			
			if not controls.sneak then
				local physics = player: get_physics_override()
				player_stored_physics[playername] = player_stored_physics[playername] or table.copy(physics)
				
				physics.speed = player_stored_physics[playername].speed / ((minetest.settings: get 'movement_speed_walk' or 4) /  minetest.settings: get 'movement_speed_crouch' or 1.35)
				physics.jump = 0
				
				player: set_physics_override(physics)
			else
				if player_stored_physics[playername] then
					player_stored_physics[playername].jump = head_node_def.walkable and 0 or 1
					player: set_physics_override(player_stored_physics[playername])
					player_stored_physics[playername] = nil
				end
			end
			
			local moving = controls.left or controls.right or controls.up or controls.down or controls.jump
			
			if anti_slip and player: get_velocity().y < 0.0001 and not moving then
				player: add_velocity(-player: get_velocity()*0.1)
			end
		else
			if player_stored_physics[playername] then
				player: set_physics_override(player_stored_physics[playername])
				player_stored_physics[playername] = nil
			end
			
			if silent_sneak then
				properties.makes_footstep_sound = true
			end
			
			if hide_nametag then
				properties.nametag_color.a = 255
			end
			
			if lower_cam and player_stored_eye_height[playername] then
				properties.eye_height = player_stored_eye_height[playername]
				player_stored_eye_height[playername] = nil
			end
			
			if reduced_hitbox ~= 0 and player_stored_hitbox[playername] then
				properties.collisionbox[5] = player_stored_hitbox[playername]
				player_stored_hitbox[playername] = nil
			end
		end
		
		player: set_properties(properties)
	end
end)
