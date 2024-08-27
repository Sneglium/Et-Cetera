
etc: register_item('wrought_iron_ingot', {
	displayname = 'Wrought Iron Ingot',
	inventory_image = 'etc_wrought_iron_ingot.png'
})

if minetest.settings: get_bool('etc.wrought_iron_dumb_crafting', false) then
	minetest.register_craft {
		type = 'shapeless',
		output = 'etc:wrought_iron_ingot',
		recipe = {'default:steel_ingot', 'default:coal_lump'}
	}
	
	minetest.register_craft {
		type = 'shapeless',
		output = 'etc:wrought_iron_ingot 8',
		recipe = {'default:coal_lump', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'}
	}
else
	minetest.register_craft {
		type = 'cooking',
		output = 'etc:wrought_iron_ingot',
		recipe = 'default:steel_ingot',
		cooktime = 1
	}
end

etc: register_node('wrought_iron_block', {
	displayname = 'Wrought Iron Block',
	tiles = {'etc_wrought_iron_block.png'},
	groups = {cracky=2},
	sounds = default.node_sound_metal_defaults()
})

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:wrought_iron_block',
	recipe = {'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot'}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:wrought_iron_ingot 9',
	recipe = {'etc:wrought_iron_block'}
}
