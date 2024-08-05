
etc: register_node('duststone', {
	displayname = 'Duststone',
	tiles = {'etc_duststone.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft {
	output = 'etc:duststone 4',
	recipe = {
		{'etc:dust', 'etc:dust', ''},
		{'etc:dust', 'etc:dust', ''},
		{'', '', ''}
	}
}

etc: register_node('duststone_bricks', {
	displayname = 'Duststone Bricks',
	tiles = {'etc_duststone_bricks.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft {
	output = 'etc:duststone_bricks 4',
	recipe = {
		{'etc:duststone', 'etc:duststone', ''},
		{'etc:duststone', 'etc:duststone', ''},
		{'', '', ''}
	}
}

etc: register_node('duststone_block', {
	displayname = 'Duststone Tile',
	tiles = {'etc_duststone_block.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft {
	output = 'etc:duststone_block 9',
	recipe = {
		{'etc:duststone', 'etc:duststone', 'etc:duststone'},
		{'etc:duststone', 'etc:duststone', 'etc:duststone'},
		{'etc:duststone', 'etc:duststone', 'etc:duststone'}
	}
}

etc: register_node('duststone_block_chiselled', {
	displayname = 'Ornate Duststone Tile',
	tiles = {'etc_duststone_block_chiselled.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft {
	output = 'etc:duststone_block_chiselled 4',
	recipe = {
		{'etc:duststone_block', 'etc:duststone_block', ''},
		{'etc:duststone_block', 'etc:duststone_block', ''},
		{'', '', ''}
	}
}

etc: register_node('duststone_tiles', {
	displayname = 'Duststone Quartertiles',
	tiles = {'etc_duststone_tiles.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft {
	output = 'etc:duststone_tiles 4',
	recipe = {
		{'etc:duststone_bricks', 'etc:duststone_bricks', ''},
		{'etc:duststone_bricks', 'etc:duststone_bricks', ''},
		{'', '', ''}
	}
}

etc: register_node('duststone_column', {
	displayname = 'Duststone Column',
	tiles = {'etc_duststone_column.png'},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	paramtype2 = 'facedir',
	on_place = minetest.rotate_node
})

minetest.register_craft {
	output = 'etc:duststone_column 3',
	recipe = {
		{'', 'etc:duststone', ''},
		{'', 'etc:duststone', ''},
		{'', 'etc:duststone', ''}
	}
}

if stairs then
	stairs.register_stair_and_slab(
		'etcetera_duststone',
		'etcetera:duststone',
		{cracky=3},
		{'etc_duststone.png'},
		etc.gettext('Duststone Stairs'),
		etc.gettext('Duststone Slab'),
		default.node_sound_stone_defaults(),
		false,
		etc.gettext('Duststone Stairs (Inner Corner)'),
		etc.gettext('Duststone Stairs (Outer Corner)')
	)
	
	stairs.register_stair_and_slab(
		'etcetera_duststone_bricks',
		'etcetera:duststone_bricks',
		{cracky=3},
		{'etc_duststone_bricks.png'},
		etc.gettext('Duststone Brick Stairs'),
		etc.gettext('Duststone Brick Slab'),
		default.node_sound_stone_defaults(),
		false,
		etc.gettext('Duststone Brick Stairs (Inner Corner)'),
		etc.gettext('Duststone Brick Stairs (Outer Corner)')
	)
	
	stairs.register_stair_and_slab(
		'etcetera_duststone_tiles',
		'etcetera:duststone_tiles',
		{cracky=3},
		{'etc_duststone_tiles.png'},
		etc.gettext('Duststone Quartertile Stairs'),
		etc.gettext('Duststone Quartertile Slab'),
		default.node_sound_stone_defaults(),
		false,
		etc.gettext('Duststone Quartertile Stairs (Inner Corner)'),
		etc.gettext('Duststone Quartertile Stairs (Outer Corner)')
	)
	
end
