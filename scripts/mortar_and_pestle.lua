etc.mortar_recipes = {}

if unified_inventory then
	unified_inventory.register_craft_type('etcetera:mortar', {
		description = 'Mortar & Pestle',
		icon = 'etc_mortar_side.png',
		width = 1,
		height = 1,
		dynamic_display_size = function(craft)
			return {width = 1, height = 1}
		end,
		uses_crafting_grid = false
	})
end

if i3 then
	i3.register_craft_type('etcetera:mortar', {
		description = 'Mortar & Pestle',
		icon = 'etc_mortar_side.png',
	})
end

function etc.register_mortar_recipe (input, output, hits, use_plant_sound)
	etc.mortar_recipes[input] = {output = output, hits = hits, plant = use_plant_sound}
	
	if unified_inventory then
		unified_inventory.register_craft({
		type = 'etcetera:mortar',
		output = output,
		items = {input},
		width = 1
	})
	end
	
	if i3 then
		i3.register_craft {
			type   = 'etcetera:mortar',
			result = output,
			items  = {input},
		}
	end
end

etc.register_item('pestle', {
	displayname = 'Pestle',
	stats = 'Use on a mortar with <LMB>',
	inventory_image = 'etc_pestle.png',
	tool_capabilities = {groupcaps={cracky={}}},
	stack_max = 1
})

if default then
	minetest.register_craft {
		recipe = {
			{'default:steel_ingot', 'etc:sandpaper_0'},
			{'default:steel_ingot', ''}
		},
		output = 'etc:pestle'
	}
end

minetest.register_lbm {
	name  = 'etcetera:update__mortar_display',
	nodenames = {'etcetera:mortar'},
	run_at_every_load = true,
	action = function (pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		if not inv: is_empty('item') then
			etc.add_display_entity(vector.add(pos, vector.new(0, -0.25, 0)), inv: get_stack('item', 1), 1, true)
		end
	end,
}

local hardness_mult = minetest.settings: get('etc.') or 1

etc.register_node('mortar', {
	displayname = 'Mortar',
	stats = 'Add and remove items with <RMB>',
	tiles = {'etc_mortar_top.png', 'etc_mortar_bottom.png', 'etc_mortar_side.png'},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{5/16, -4/16, 5/16, -5/16, -0.5, -5/16}, -- base
			{7/16, 4/16, 7/16, 5/16, -4/16, -7/16}, -- +X
			{-5/16, 4/16, 7/16, -7/16, -4/16, -7/16}, -- -X
			{7/16, 4/16, 7/16, -7/16, -4/16, 5/16}, -- +Z
			{7/16, 4/16, -5/16, -7/16, -4/16, -7/16}  -- -Z
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-5/16, -0.5, -5/16, 5/16, -4/16, 5/16},
			{-7/16, -4/16, -7/16, 7/16, 4/16, 7/16}
		}
	},
	groups = {cracky = 3},
	
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		
		meta: set_int('progress', 0)
		meta: set_int('progress_needed', 0)
		meta: set_float('last_hit', 0)
		
		meta: set_string('infotext', 'No Item')
		
		meta: get_inventory(): set_size('item', 1)
	end,
	
	on_dig = function (pos, node, digger)
		etc.remove_display_entity(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty('item') then
			etc.give_or_drop(digger, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
		end
		
		etc.give_or_drop(digger, pos, ItemStack 'etcetera:mortar')
		minetest.set_node(pos, {name='air'})
		return true
	end, 
	 -- the wielded itemstack shenanigans at the end of this function are necessary to avoid any items being deleted or duped
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		meta: set_int('progress', 0)
		etc.remove_display_entity(pos)
		
		if not inv: is_empty('item') then
			etc.give_or_drop(clicker, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
			meta: set_string('infotext', 'No Item')
			return clicker: get_wielded_item()
		end
		
		local recipe = etc.mortar_recipes[itemstack: get_name()]
		if recipe then
			inv: set_stack('item', 1, itemstack)
			local itemtime = recipe.hits*10
			meta: set_int('progress_needed', math.floor(itemtime+(itemtime-1)*(itemstack: get_count())*0.75)*hardness_mult)
			meta: set_string('infotext', itemstack: get_short_description())
			etc.add_display_entity(vector.add(pos, vector.new(0, -0.25, 0)), itemstack, 1, true)
			itemstack: clear()
			clicker: set_wielded_item(itemstack)
		end
		
		return clicker: get_wielded_item()
	end,
	
	on_punch = function (pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if puncher: get_wielded_item(): get_name() == 'etcetera:pestle' then
			if math.abs(os.clock() - meta: get_float('last_hit')) < 0.08 then
				return
			end
			
			meta: set_float('last_hit', os.clock())
			
			if not inv: is_empty('item') then
				recipe = etc.mortar_recipes[inv: get_stack('item', 1): get_name()]
				if recipe then
					meta: set_int('progress', meta: get_int('progress') + math.random(9, 11))
					etc.update_display_entity(pos, inv: get_stack('item', 1): get_name(), true)
					
					minetest.sound_play({name = recipe.plant and 'etc_mortar_plant' or 'etc_mortar'}, {pos = pos, max_hear_distance = 16}, true)
					if default then
						for i = 1, 5 do
							minetest.add_particle {
								pos = pos,
								velocity = vector.new((math.random()-0.5)*2, 3.5, (math.random()-0.5)*2),
								acceleration = vector.new(0, -9.8, 0),
								expirationtime = 2.5,
								size = 0,
								node = {name = 'default:permafrost'}
							}
						end
					end
					
					if meta: get_int('progress') > meta: get_int('progress_needed') then
						local stack = inv: get_stack('item', 1)
						local output = ItemStack(recipe.output)
						output: set_count(output: get_count() * stack: get_count())
						inv: set_stack('item', 1, output)
						meta: set_string('infotext', stack: get_short_description())
						etc.update_display_entity(pos, recipe.output, true)
						local recipe = etc.mortar_recipes[stack: get_name()]
						if recipe then
							local itemtime = recipe.hits*10
							meta: set_int('progress', 0)
							meta: set_int('progress_needed', math.floor(itemtime+(itemtime-1)*(stack: get_count())*0.75))
						end
					end
				end
			end
		end
	end
})


if default then
	minetest.register_craft {
		recipe = {
			{'', 'etc:sandpaper_0', ''},
			{'default:cobble', 'etc:sandpaper_0', 'default:cobble'},
			{'default:steel_ingot', 'default:cobble', 'default:steel_ingot'}
		},
		output = 'etc:mortar'
	}

	etc.register_mortar_recipe('default:cobble', 'default:gravel', 4)
	etc.register_mortar_recipe('default:gravel', 'default:silver_sand', 2)
	etc.register_mortar_recipe('default:sand_with_kelp', 'default:paper', 2, true)

	etc.register_mortar_recipe('default:grass_1', 'etc:string', 2, true)
	etc.register_mortar_recipe('default:junglegrass', 'etc:string 2', 2, true)
	etc.register_mortar_recipe('default:flint', 'etc:flint_dust', 3)
	etc.register_mortar_recipe('default:mese_crystal', 'etc:mese_dust', 6)
	etc.register_mortar_recipe('default:diamond', 'etc:diamond_dust', 4)

	if minetest.get_modpath 'dye' then
		etc.register_mortar_recipe('default:coal_lump', 'dye:black 8', 2, true)
		etc.register_mortar_recipe('default:blueberries', 'dye:violet 5', 2, true)
		etc.register_mortar_recipe('default:coral_cyan', 'dye:cyan 4', 2, true)
		etc.register_mortar_recipe('default:coral_green', 'dye:green 4', 2, true)
		etc.register_mortar_recipe('default:coral_pink', 'dye:magenta 4', 2, true)
		etc.register_mortar_recipe('default:coral_skeleton', 'dye:white 8', 2, true)
	end
end

if farming then
	etc.register_mortar_recipe('farming:wheat', 'farming:flour', 10, true)
end

if minetest.get_modpath 'flowers' and minetest.get_modpath 'dye' then
	etc.register_mortar_recipe('flowers:chrysanthemum_green', 'dye:green 8', 2, true)
	etc.register_mortar_recipe('flowers:dandelion_white', 'dye:white 8', 2, true)
	etc.register_mortar_recipe('flowers:dandelion_yellow', 'dye:yellow 8', 2, true)
	etc.register_mortar_recipe('flowers:geranium', 'dye:blue 8', 2, true)
	etc.register_mortar_recipe('flowers:rose', 'dye:red 8', 2, true)
	etc.register_mortar_recipe('flowers:tulip', 'dye:orange 8', 2, true)
	etc.register_mortar_recipe('flowers:tulip_black', 'dye:black 8', 2, true)
	etc.register_mortar_recipe('flowers:viola', 'dye:violet 8', 2, true)
end


if minetest.settings: get_bool('etc.mortar_and_pestle_technic_support', true) then
	minetest.after(0.05, function()
		if technic then
			for _, recipe in pairs(technic.recipes.grinding.recipes) do
				if type(recipe.output) == 'string' then
					for input, __ in pairs(recipe.input) do
						if not etc.mortar_recipes[input] then
							etc.register_mortar_recipe(input, recipe.output, 5)
						end
					end
				end
			end
		end
	end)
end