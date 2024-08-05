
etc: register_item('pine_tar', {
	displayname = 'Pine Tar',
	inventory_image = 'etc_pine_tar.png',
	groups = {glue = 1, tar = 1}
})

if minetest.global_exists('default') then
	minetest.register_craft {
		type = 'cooking',
		recipe = 'default:pine_wood',
		output = 'etc:pine_tar'
	}
end

etc: register_item('charcoal', {
	displayname = 'Charcoal',
	inventory_image = 'etc_charcoal.png',
	groups = {coal = 1, charcoal = 1, flammable = 3}
})

if minetest.global_exists('default') then
	minetest.register_craft {
		type = 'cooking',
		recipe = 'group:tree',
		output = 'etc:charcoal 4'
	}
	
	minetest.register_craft {
		type = 'cooking',
		recipe = 'group:wood',
		output = 'etc:charcoal'
	}
end

minetest.register_craft({
	type = 'fuel',
	recipe = 'etc:charcoal',
	burntime = 32,
})

etc: register_item('pine_pitch', {
	displayname = 'Pine Pitch',
	inventory_image = 'etc_pine_pitch.png',
	groups = {glue = 1, tar = 1}
})

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:pine_tar', 'etc:charcoal', 'etc:pine_tar'},
	output = 'etc:pine_pitch 2'
}

etc: register_item('acid', {
	displayname = 'Acidic Extract',
	inventory_image = 'etc_acid.png',
	groups = {acid = 1}
})

if minetest.global_exists('default') then
	minetest.register_craft {
		type = 'cooking',
		recipe = 'default:fern_1',
		output = 'etc:acid'
	}
end

etc: register_item('algin', {
	displayname = 'Algin',
	inventory_image = 'etc_algin.png',
	groups = {glue = 1, gelatin = 1, jelly = 1, sticky = 1}
})

if minetest.global_exists('default') then
	minetest.register_craft {
		type = 'cooking',
		recipe = 'default:sand_with_kelp',
		output = 'etc:algin'
	}
end

etc: register_item('string', {
	displayname = 'Rough Twine',
	inventory_image = 'etc_string.png',
	groups= {string = 1, rope = 1}
})

etc: register_item('canvas', {
	displayname = 'Heavy Canvas',
	inventory_image = 'etc_canvas.png',
	groups = {cloth = 1, canvas = 1, fabric = 1}
})

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:string', 'etc:string', 'etc:string', 
	'etc:string', 'etc:string', 'etc:string'},
	output = 'etc:canvas 2'
}

etc: register_item('canvas_tarred', {
	displayname = 'Oilcloth',
	inventory_image = 'etc_oilcloth.png',
	groups = {cloth = 1, canvas = 1, fabric = 1}
})

minetest.register_craft {
	type = 'shapeless',
	recipe = {'etc:pine_tar', 'etc:pine_tar', 'etc:pine_tar', 'etc:canvas'},
	output = 'etc:canvas_tarred'
}

etc: register_item('flint_dust', {
	displayname = 'Powdered Flint',
	inventory_image = 'etc_flint_dust.png'
})

etc: register_item('mese_dust', {
	displayname = 'Powdered Mese',
	inventory_image = 'etc_mese_dust.png'
})

etc: register_item('diamond_dust', {
	displayname = 'Powdered Diamond',
	inventory_image = 'etc_diamond_dust.png'
})

etc: register_item('sandpaper_0', {
	displayname = 'Sandpaper\n(Poor, Ungraded)',
	inventory_image = 'etc_sandpaper_raw.png'
})

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'etc:pine_tar', 'group:sand', 'etc:pine_tar'},
			{'default:paper', 'default:paper', 'default:paper'},
			{'default:paper', 'default:paper', 'default:paper'}
		},
		output = 'etc:sandpaper_0 3'
	}
end

etc: register_item('sandpaper_1', {
	displayname = 'Sandpaper\n(Decent, Low Grit)',
	inventory_image = 'etc_sandpaper_1.png'
})

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'etc:pine_tar', 'etc:flint_dust', 'etc:pine_tar'},
			{'default:paper', 'default:paper', 'default:paper'},
			{'default:paper', 'default:paper', 'default:paper'}
		},
		output = 'etc:sandpaper_1 6'
	}
end

etc: register_item('sandpaper_2', {
	displayname = 'Sandpaper\n(Great, Medium Grit)',
	inventory_image = 'etc_sandpaper_2.png'
})

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'etc:pine_tar', 'etc:mese_dust', 'etc:pine_tar'},
			{'default:paper', 'default:paper', 'default:paper'},
			{'default:paper', 'default:paper', 'default:paper'}
		},
		output = 'etc:sandpaper_2 3'
	}
end

etc: register_item('sandpaper_3', {
	displayname = 'Sandpaper\n(Great, High Grit)',
	inventory_image = 'etc_sandpaper_3.png'
})

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'etc:pine_tar', 'etc:diamond_dust', 'etc:pine_tar'},
			{'default:paper', 'default:paper', 'default:paper'},
			{'default:paper', 'default:paper', 'default:paper'}
		},
		output = 'etc:sandpaper_3 3'
	}
end

if minetest.settings: get_bool('etc.basic_resources_easy_flint', true) then
	minetest.register_craft {
		type = 'shapeless',
		recipe = {'default:gravel', 'default:gravel', 'default:gravel'},
		output = 'default:flint 2'
	}
end
