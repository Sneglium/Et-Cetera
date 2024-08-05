
etc: register_tool('ct_file', {
	displayname = 'Metal File',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_file.png',
})

etc: register_tool('ct_cutters', {
	displayname = 'Metal Snips',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_cutters.png',
})

etc: register_tool('ct_drill', {
	displayname = 'Hand Drill',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_drill.png',
})

etc: register_tool('ct_hammer', {
	displayname = 'Sheeting Hammer',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_hammer.png',
})

etc: register_tool('ct_knife', {
	displayname = 'Carving Knife',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_knife.png'
})

etc: register_tool('ct_saw', {
	displayname = 'Framing Saw',
	description = 'Will not be consumed in recipes until durability runs out.',
	inventory_image = 'etc_saw.png'
})

local uses = minetest.settings: get 'etc.craft_tools_num_uses' or 150

local ct_tools = {
	['etcetera:ct_file'] = uses,
	['etcetera:ct_cutters'] = uses,
	['etcetera:ct_drill'] = uses,
	['etcetera:ct_knife'] = uses,
	['etcetera:ct_hammer'] = minetest.settings: get 'etc.craft_tools_hammer_ num_uses' or 300
}

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	for index, item in ipairs(old_craft_grid) do
		if ct_tools[ItemStack(item): get_name()] then
			item: set_wear(item: get_wear() + math.ceil(65536 / ct_tools[ItemStack(item): get_name()]))
			if item: get_wear() >= 65535 then
				craft_inv: set_stack('craft', index, ItemStack())
				minetest.sound_play({name = 'default_tool_breaks'}, {to_player = player: get_player_name()}, true)
			else
				craft_inv: set_stack('craft', index, item)
			end
		end
	end
end)

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'', 'default:steel_ingot'},
			{'default:stick', ''}
		},
		output = 'etc:ct_file'
	}
	
	minetest.register_craft {
		recipe = {
			{'', 'default:steel_ingot', 'etc:ct_file'},
			{'default:stick', '', 'default:steel_ingot'},
			{'', 'default:stick', ''}
		},
		output = 'etc:ct_cutters',
	}
	
	minetest.register_craft {
		recipe = {
			{'', 'group:wood', 'default:bronze_ingot'},
			{'default:stick', 'default:steel_ingot', 'etc:ct_file'},
			{'', 'default:steel_ingot', ''}
		},
		output = 'etc:ct_drill',
	}
	
	minetest.register_craft {
		recipe = {
			{'etc:ct_file', 'default:steel_ingot', 'etc:ct_drill'},
			{'', 'default:bronze_ingot', 'default:steel_ingot'},
			{'default:stick', '', ''}
		},
		output = 'etc:ct_hammer',
	}
	
	minetest.register_craft {
		recipe = {
			{'etc:ct_file', 'default:steel_ingot', 'etc:ct_drill'},
			{'', 'default:steel_ingot', ''},
			{'', 'default:stick', ''}
		},
		output = 'etc:ct_knife',
	}
	
	minetest.register_craft {
		recipe = {
			{'', 'etc:ct_hammer', 'default:steel_ingot'},
			{'default:stick', 'default:steel_ingot', 'etc:ct_file'},
			{'', 'default:stick', ''}
		},
		output = 'etc:ct_saw',
	}
end
