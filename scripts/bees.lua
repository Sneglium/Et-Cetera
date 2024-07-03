
local fireflies = minetest.get_modpath 'fireflies'

local honey_rate = minetest.settings: get 'etc.bees_honey_rate' or 1
local wax_rate = minetest.settings: get 'etc.bees_wax_rate' or 1

local memory_length = minetest.settings: get 'etc.bees_memory_length' or 2

etc.register_node('bee', {
	displayname = 'Honey Bee',
	stats = fireflies and 'Use a bug net with <LMB> to collect',
	drawtype = 'plantlike',
	tiles = {{
		name = 'etc_bee_animated.png',
		animation = {
			type = 'vertical_frames',
			aspect_w = 16,
			aspect_h = 16,
			length = 1.5
		}
	}},
	inventory_image = 'etc_bee.png',
	wield_image =  'etc_bee.png',
	waving = 1,
	paramtype = 'light',
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	pointable = not minetest.features.item_specific_pointabilities,
	groups = {catchable = 1},
	selection_box = {
		type = 'fixed',
		fixed = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	},
	floodable = true,
	on_place = function(itemstack, placer, pointed_thing)
		local player_name = placer and placer:get_player_name() or ''
		local pos = pointed_thing.above

		if not minetest.is_protected(pos, player_name) and minetest.get_node(pos).name == 'air' then
			minetest.set_node(pos, {name = 'etcetera:bee'})
			minetest.get_node_timer(pos): start(1)
			itemstack: take_item()
		end
		return itemstack
	end,
	on_timer = function(pos, elapsed)
		if minetest.get_node_light(pos) < 11 then
			minetest.set_node(pos, {name = 'etcetera:hidden_bee'})
		end
		minetest.get_node_timer(pos): start(60)
	end
})

etc.register_node('hidden_bee', {
	drawtype = 'airlike',
	inventory_image = 'empty.png',
	wield_image =  'empty.png',
	paramtype = 'light',
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	pointable = false,
	diggable = false,
	drop = '',
	groups = {not_in_creative_inventory = 1},
	floodable = true,
	on_timer = function(pos, elapsed)
		if minetest.get_node_light(pos) >= 11 then
			minetest.set_node(pos, {name = 'etcetera:bee'})
		end
		minetest.get_node_timer(pos): start(60)
	end
})

minetest.register_decoration({
	name = 'etcetera:bee',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	place_offset_y = 2,
	sidelen = 80,
	fill_ratio = 0.0025,
	y_max = 31000,
	y_min = 1,
	decoration = {'etcetera:bee'},
	spawn_by = 'group:flower',
	num_spawn_by = 1
})

minetest.register_decoration({
	name = 'etcetera:bee_high',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	place_offset_y = 4,
	sidelen = 80,
	fill_ratio = 0.0025,
	y_max = 31000,
	y_min = 1,
	decoration = {'etcetera:bee'},
	spawn_by = 'group:flower',
	num_spawn_by = 1
})

minetest.set_gen_notify({decoration = true}, {
	minetest.get_decoration_id 'etcetera:bee',
	minetest.get_decoration_id 'etcetera:bee_high'
})

minetest.register_on_generated(function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object 'gennotify'
	local generated_bees = {}
	
	local bee_deco_1 = gennotify['decoration#'..minetest.get_decoration_id 'etcetera:bee']
	local bee_deco_2 = gennotify['decoration#'..minetest.get_decoration_id 'etcetera:bee_high']

	for _, pos in pairs(bee_deco_1 or {}) do
		table.insert(generated_bees, pos + vector.new(0, 3, 0))
	end
	
	for _, pos in pairs(bee_deco_2 or {}) do
		table.insert(generated_bees, pos + vector.new(0, 5, 0))
	end

	if #generated_bees ~= 0 then
		for i = 1, #generated_bees do
			local pos = generated_bees[i]
			minetest.get_node_timer(pos): start(1)
		end
	end
end)

local retexture = minetest.settings: get_bool('etc.load_module_fluid_bottles', true) and minetest.settings: get_bool('etc.fluid_bottles_retexture', true)

etc.register_node('bottle_honey', {
	displayname = 'Glass Bottle (Honey)',
	inventory_image = (retexture and 'etc_bottle_honey.png' or 'etc_bottle_honey_old.png') .. '^' .. (retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png'),
	tiles = {(retexture and 'etc_bottle_honey.png' or 'etc_bottle_honey_old.png') .. '^' .. (retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png')},
	use_texture_alpha = 'blend',
	drawtype = 'plantlike',
	paramtype = 'light',
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {dig_immediate = 3, attached_node = 1, sugar = 1, honey = 1},
	sounds = default.node_sound_glass_defaults(),
	on_use = minetest.item_eat(6, minetest.get_modpath 'vessels' and 'vessels:glass_bottle')
})

etc.register_node('honey_block', {
	displayname = 'Honey Block',
	tiles = {{name = 'etc_honey_block.png', backface_culling = true}},
	drawtype = 'mesh',
	mesh = 'etc_slime_block.obj',
	paramtype = 'light',
	sunlight_propagates = true,
	use_texture_alpha = 'blend',
	groups = {snappy = 3, crumbly = 2, oddly_breakable_by_hand = 3, fall_damage_add_percent = -100, bouncy = 50},
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
	output = 'etc:honey_block',
	recipe = {'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey', 'etc:bottle_honey'},
	replacements = minetest.get_modpath 'vessels' and {{'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}, {'etcetera:bottle_honey', 'vessels:glass_bottle'}}
}

etc.register_item('beeswax', {
	displayname = 'Beeswax Nugget',
	stats = etc.modules.corrosion and '<LMB> on a metal block to seal it against corrosion',
	inventory_image = 'etc_beeswax.png',
	on_use = etc.modules.corrosion and function (itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		
		if etc.modules.corrosion.corrosion_nodes[node.name] then
			local meta = minetest.get_meta(pos)
			meta: set_string('sealed', 'true')
			minetest.sound_play({name = 'default_place_node_hard'}, {pos = pos})
			
			itemstack: take_item(1)
			return itemstack
		end
	end
})

etc.register_node('beeswax_block', {
	displayname = 'Beeswax Block',
	tiles = {{name = 'etc_beeswax_block.png', backface_culling = true}},
	groups = {snappy = 3, crumbly = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:beeswax_block',
	recipe = {'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax', 'etc:beeswax'}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:beeswax 9',
	recipe = {'etc:beeswax_block'}
}

local function apiary_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	if itemstack: get_name() == node.name then
		local new_node = table.copy(node)
		new_node.name = 'etcetera:apiary_full'
		minetest.swap_node(pos, new_node)
		
		minetest.sound_play({name = 'default_place_node_hard'}, {pos = pos})
		
		itemstack: take_item(1)
		return itemstack
	end
end

local function get_apiary_infotext (pos)
	local meta = minetest.get_meta(pos)
	
	meta: set_string('infotext', table.concat {
		'Honey: '..meta: get_int 'honey' or 0,
		'/1000ml\n',
		'Wax: '..meta: get_int 'wax' or 0,
		'/1000g',
	})
end

local function apiary_on_punch (pos, node, puncher, pointed_thing)
	local itemstack = puncher: get_wielded_item()
	local meta = minetest.get_meta(pos)

	if itemstack: get_name() == 'etcetera:ct_knife' then
		local wax = meta: get_int 'wax'
		if wax >= 100 then
			local wax_available = math.floor(wax/100)
			local wax_item = ItemStack 'etc:beeswax'
			wax_item: set_count(wax_available)
			etc.give_or_drop(puncher, puncher: get_pos() + puncher: get_look_dir(), wax_item)
			meta: set_int('wax', math.max(wax - (wax_available * 100), 0))
		end
	elseif itemstack: get_name() == 'vessels:glass_bottle' then
		local honey = meta: get_int 'honey'
		if honey >= 100 then
			local honey_available = math.floor(honey/100)
			local bottles_available = itemstack: get_count()
			local total_take = math.min(honey_available, bottles_available)
			
			local honey_item = ItemStack 'etc:bottle_honey'
			honey_item: set_count(total_take)
			etc.give_or_drop(puncher, puncher: get_pos() + puncher: get_look_dir(), honey_item)
			meta: set_int('honey', math.max(honey - (total_take * 100), 0))
			
			get_apiary_infotext(pos)
			
			itemstack: take_item(total_take)
			return itemstack
		end
	end
	
	get_apiary_infotext(pos)
end

local apiary_flower_memory = {}

local function apiary_on_timer (pos, elapsed)
	local pos_serialized = minetest.serialize(pos)
	apiary_flower_memory[pos_serialized] = apiary_flower_memory[pos_serialized] or {}
	
	local node = minetest.get_node(pos).name
	local meta = minetest.get_meta(pos)
	
	if minetest.get_node_light(pos) >= 11 and minetest.get_timeofday() > 0.2 and minetest.get_timeofday() < 0.8 then
		minetest.sound_play({name = 'etc_bees'}, {pos = pos})
		local offset_vec = vector.new(5, 5, 5)
		local flower_positions = minetest.find_nodes_in_area_under_air(pos + offset_vec, pos - offset_vec, 'group:flower')
		
		local selected_flower_pos
		
		local flower_pos = flower_positions[math.random(1, #flower_positions)]
		local flower_pos_serialized = minetest.serialize(flower_pos)
		
		if not etc.array_find(apiary_flower_memory[pos_serialized], flower_pos_serialized) then
			selected_flower_pos = flower_pos
		end
		
		table.insert(apiary_flower_memory[pos_serialized], 1, flower_pos_serialized)
		table.remove(apiary_flower_memory[pos_serialized], memory_length+1)
		
		if selected_flower_pos then
			local new_honey = node == 'etcetera:apiary_full' and math.random(12, 24) or math.random(6, 12)
			meta: set_int('honey', math.min((meta: get_int 'honey' or 0) + math.ceil(new_honey * honey_rate), 1000))
		end
	end
	
	local new_wax = node == 'etcetera:apiary_full' and math.random(12, 24) or math.random(6, 12)
	meta: set_int('wax', math.min((meta: get_int 'wax' or 0) + math.ceil(new_wax * wax_rate), 1000))
	
	get_apiary_infotext(pos)
	
	minetest.get_node_timer(pos): start(10)
end

local function apiary_on_construct (pos)
	local meta = minetest.get_meta(pos)
	
	meta: set_int('honey', meta: get_int 'honey' or 0)
	meta: set_int('wax', meta: get_int 'wax' or 0)
	
	meta: set_string('last_flower_1', meta: get_string 'last_flower_1' ~= '' and meta: get_string 'last_flower_1' or 'none')
	meta: set_string('last_flower_2', meta: get_string 'last_flower_2' ~= '' and meta: get_string 'last_flower_2' or 'none')
	
	get_apiary_infotext(pos)
	minetest.get_node_timer(pos): start(1)
end

etc.register_node('apiary_half', {
	displayname = 'Apiary Box',
	description = 'A single apiary box. Can be stacked to make taller apiaries.',
	stats = {
		'<RMB> with another apiary box to make it taller',
		'<LMB> with an empty bottle to collect honey',
		'<LMB> with a carving knife to collect wax'
	},
	tiles = {
		'etc_apiary_top.png',
		'etc_apiary_top.png',
		'etc_apiary_side.png',
		'etc_apiary_side.png',
		'etc_apiary_side.png',
		'etc_apiary_front.png'
	},
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = '4dir',
	node_box = {
		type = 'fixed',
		fixed = {
			{6/16, -1/16, 6/16, -6/16, -0.5, -6/16},
			{7/16, 0, 7/16, -7/16, -1/16, -7/16}
		}
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	on_punch = apiary_on_punch,
	on_rightclick = apiary_on_rightclick,
	on_construct = apiary_on_construct,
	on_place = minetest.rotate_node,
	on_timer = apiary_on_timer
})

etc.register_node('apiary_full', {
	tiles = {
		'etc_apiary_top.png',
		'etc_apiary_top.png',
		'etc_apiary_side.png',
		'etc_apiary_side.png',
		'etc_apiary_side.png',
		'etc_apiary_front.png'
	},
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = '4dir',
	node_box = {
		type = 'fixed',
		fixed = {
			{6/16, -1/16, 6/16, -6/16, -0.5, -6/16},
			{7/16, 0, 7/16, -7/16, -1/16, -7/16},
			{6/16, 7/16, 6/16, -6/16, 0, -6/16},
			{7/16, 0.5, 7/16, -7/16, 7/16, -7/16}
		}
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
	on_punch = apiary_on_punch,
	on_construct = apiary_on_construct,
	on_place = minetest.rotate_node,
	on_timer = apiary_on_timer,
	drop = 'etcetera:apiary_half 2'
})

if etc.modules.treated_wood then
	minetest.register_craft {
		output = 'etcetera:apiary_half',
		recipe = {
			{'group:slab', 'group:slab', 'group:slab'},
			{'etc:bee', 'etc:bee', 'etc:bee'},
			{'etc:tarred_wood', 'etc:tarred_wood', 'etc:tarred_wood'}
		}
	}
else
	minetest.register_craft {
		output = 'etcetera:apiary_half',
		recipe = {
			{'group:slab', 'group:slab', 'group:slab'},
			{'etc:bee', 'etc:bee', 'etc:bee'},
			{'group:wood', 'group:wood', 'group:wood'}
		}
	}
end
