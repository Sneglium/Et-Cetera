
etc: register_node('tarred_wood', {
	displayname = 'Treated Wood Planks',
	paramtype2 = 'facedir',
	place_param2 = 0,
	tiles = {'etc_tarred_wood.png'},
	is_ground_content = false,
	groups = {choppy = 1, oddly_breakable_by_hand = 1, flammable = 3, wood = 1},
	sounds = minetest.global_exists('default') and default.node_sound_wood_defaults() or nil
})

etc: register_node('pitched_wood', {
	displayname = 'Pitch-Sealed Wood Planks',
	paramtype2 = 'facedir',
	place_param2 = 0,
	tiles = {'etc_pitched_wood.png'},
	is_ground_content = false,
	groups = {choppy = 1, oddly_breakable_by_hand = 1, flammable = 3, wood = 1},
	sounds = minetest.global_exists('default') and default.node_sound_wood_defaults() or nil
})

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:pine_tar', 'group:wood'},
	output = 'etc:tarred_wood'
}

minetest.register_craft {
	type = 'shapeless',
	recipe = {
		'group:wood', 'group:wood', 'group:wood',
		'group:wood', 'etc:pine_tar', 'group:wood',
		'group:wood', 'group:wood', 'group:wood'
	},
	output = 'etc:tarred_wood 8'
}

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:pine_pitch', 'group:wood'},
	output = 'etc:pitched_wood'
}

minetest.register_craft {
	type = 'shapeless',
	recipe = {
		'group:wood', 'group:wood', 'group:wood',
		'group:wood', 'etc:pine_pitch', 'group:wood',
		'group:wood', 'group:wood', 'group:wood'
	},
	output = 'etc:pitched_wood 8'
}
