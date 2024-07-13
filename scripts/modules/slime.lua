
etc.register_item('slimeball', {
	displayname = 'Slime Ball',
	inventory_image = 'etc_slimeball.png'
})

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:acid', 'etc:algin'},
	output = 'etc:slimeball 2'
}

etc.register_node('slime_block', {
	displayname = 'Slime Block',
	tiles = {{name = 'etc_slime_block.png', backface_culling = true}},
	drawtype = 'mesh',
	mesh = 'etc_slime_block.obj',
	paramtype = 'light',
	sunlight_propagates = true,
	use_texture_alpha = 'blend',
	groups = {
		snappy = 3,
		crumbly = 2,
		oddly_breakable_by_hand = 3,
		fall_damage_add_percent = -100,
		bouncy = 75
	},
	sounds = {
		footstep = {name = 'etc_slime_dig', pitch = 1.5, gain = 0.5},
		dig = {name = 'etc_slime_dig', pitch = 2},
		dug = {name = 'etc_slime_dug', pitch = 2},
		fall = {name = 'etc_slime_dug', pitch = 2},
		place = {name = 'etc_slime_dug', pitch = 3}
	}
})

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:slime_block',
	recipe = {
		'etc:slimeball', 'etc:slimeball', 'etc:slimeball',
		'etc:slimeball', 'etc:slimeball', 'etc:slimeball',
		'etc:slimeball', 'etc:slimeball', 'etc:slimeball'
	}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:slimeball 9',
	recipe = {'etc:slime_block'}
}
