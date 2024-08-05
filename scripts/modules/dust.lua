
etc: register_node('dust', {
	displayname = 'Dust',
	tiles = {'etc_dust.png'},
	groups = {crumbly = 3, falling_node = 1},
	sounds = default.node_sound_sand_defaults()
})

etc.register_mortar_recipe('default:sand', 'etcetera:dust', 2)
etc.register_mortar_recipe('default:desert_sand', 'etcetera:dust', 2)
etc.register_mortar_recipe('default:silver_sand', 'etcetera:dust', 2)

minetest.register_craft {
	type ='shapeless',
	output = 'default:clay',
	recipe = {'bucket:bucket_water', 'etc:dust'},
	replacements = {{'bucket:bucket_water', 'bucket:bucket_empty'}}
}

minetest.register_craft {
	type ='shapeless',
	output = 'default:clay 8',
	recipe = {'bucket:bucket_water', 'etc:dust', 'etc:dust', 'etc:dust', 'etc:dust', 'etc:dust', 'etc:dust', 'etc:dust', 'etc:dust'},
	replacements = {{'bucket:bucket_water', 'bucket:bucket_empty'}}
}
