
local cached_physics = {}
local player_sitting = {}
local player_unsit = {}

local chairphys = {
	speed = 0,
	jump = 0,
	sneak = false
}

minetest.register_entity('etcetera:chair_ent', {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = 'sprite',
		textures = {'empty.png'},
		is_visible = false,
		static_save = false
	}
})

function etc.set_sitting (player, pos)
	etc.log.assert((pos == nil or pos == false) or etc.is_vector(pos), 'Player sitting position must be a vector')
	
	local playername = player: get_player_name()
	
	if (pos == nil or pos == false) then
		if player_sitting[player: get_player_name()] then
			if cached_physics[playername] then player: set_physics_override(cached_physics[playername]) end
			if player_unsit[playername] then player: set_pos(player_unsit[playername]) end
			player_sitting[playername] = false
		end
	else
		cached_physics[playername] = player: get_physics_override()
		player: set_physics_override(chairphys)
		
		player_unsit[playername] = player: get_pos()
		
		player: set_pos(pos)
		player_sitting[playername] = pos
		
		local chair_ent = minetest.add_entity(pos, 'etcetera:chair_ent')
		player: set_attach(chair_ent, '', pos, dir)
		
		minetest.after(0.1, function (player, chair_ent, pos)
			if player and chair_ent then
				player: set_detach()
				chair_ent: remove()
				player: set_pos(pos)
			end
		end, player, chair_ent, pos)
	end
end

function etc.get_sitting(player)
	return player_sitting[player: get_player_name()]
end

minetest.register_globalstep(function()
	local players = minetest.get_connected_players()
	for i = 1, #players do
		local player = players[i]
		
		if player_api and etc.get_sitting(player) then
			player_api.set_animation(player, 'sit')
		end
		
		if player: get_player_control().sneak then
			etc.set_sitting(player, false)
		end
	end
end)

minetest.register_on_shutdown(function()
	local players = minetest.get_connected_players()
	for i = 1, #players do
		local player = players[i]
		
		etc.set_sitting(player, false)
	end
end)

minetest.register_on_dieplayer(function(player)
	etc.set_sitting(player, false)
end)

minetest.register_on_leaveplayer(function(player)
	etc.set_sitting(player, false)
end)
