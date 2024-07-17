
local module = {
	hoe_items = {
		['farming:hoe_stone'] = 1,
		['farming:hoe_bronze'] = 1,
		['farming:hoe_steel'] = 2,
		['farming:hoe_mese'] = 2,
		['farming:hoe_diamond'] = 3,
		['moreores:hoe_mithril'] = 3,
		['moreores:hoe_silver'] = 2
	},
	plants = {},
	compost_values = {}
}

local hoe_harvest = minetest.settings: get_bool('etc.farming_tweaks_hoe_harvest', true)

local function plant_harvest (pos, plant, replace_plant, seed, guide, clicker)
	local drops = minetest.get_node_drops(plant)
	local had_seed = false
	
	for _, item in pairs(drops) do
		local item = ItemStack(item)
		if item: get_name() == seed and not had_seed then
			item: take_item(1)
			had_seed = true
		end
		
		if item: get_name() ~= guide then
			etc.give_or_drop(clicker, pos, item)
		end
	end
	
	if had_seed then
		local node = minetest.get_node(pos)
		node.name = replace_plant
		minetest.swap_node(pos, node)
	else
		minetest.set_node(pos, {name = 'air'})
	end
end

function module.register_plant (name_prefix, stages, seed, guide_node, compost_value)
	local plant = name_prefix .. stages
	local replace_plant = name_prefix .. 1
	etc.log.assert(etc.is_itemstring(plant, replace_plant, seed), 'All arguments to register_plant must resolve to valid itemstrings')
	guide_node = guide_node or ''
	
	if minetest.settings: get_bool('etc.farming_tweaks_rightclick_harvest', true) then
		minetest.override_item(plant, {
			on_rightclick = function (pos, node, clicker, itemstack)
				plant_harvest(pos, plant, replace_plant, seed, guide_node, clicker)
				
				local hoedef = hoe_harvest and module.hoe_items[itemstack: get_name()]
				if hoedef then
					local pos1 = pos + vector.new(hoedef, 0, hoedef)
					local pos2 = pos - vector.new(hoedef, 0, hoedef)
					local nodes = minetest.find_nodes_in_area(pos1, pos2, plant, true)
					
					if nodes[plant] then
						for _, newpos in pairs(nodes[plant]) do
							if pos ~= newpos then
								plant_harvest(newpos, plant, replace_plant, seed, guide_node, clicker)
							end
						end
					end
				end
				
				return clicker: get_wielded_item()
			end
		})
	end
	
	for i = 1, stages-1 do
		module.plants[name_prefix .. i] = name_prefix .. i+1
	end
	
	module.plants[name_prefix .. stages] = true
	module.plants[seed] = replace_plant
	
	compost_value = compost_value or 1
	module.compost_values[seed] = math.ceil(compost_value / 2)
	module.compost_values[name_prefix: sub(1, -2)] = compost_value
	
	for i = 1, stages do
		local nodename = name_prefix .. i
		local groups = minetest.registered_nodes[nodename].groups
		groups.crop = groups.crop or 1
		minetest.override_item(nodename, {groups = groups})
	end
end

local function boost_growth (pos)
	local node = minetest.get_node(pos)
	local plant = module.plants[node.name]
	if type(plant) == 'string' then
		node.name = plant
		local plant_def = minetest.registered_nodes[plant]
		if plant_def.place_param2 ~= nil and node.param2 ~= plant_def.place_param2 then
			node.param2 = plant_def.place_param2
		end
		minetest.swap_node(pos, node)
		
		for i = 1, 8 do
			local vel = math.random()+0.5
			minetest.add_particle {
				pos = pos + vector.new(math.random()-0.5, 0, math.random()-0.5),
				velocity = vector.new(0, vel, 0),
				acceleration = vector.new(0, -1, 0),
				expirationtime = vel,
				size = vel*1.5,
				glow = 8,
				texture = 'etc_growth_particle.png'
			}
		end
	end
end


module.register_plant('farming:wheat_', 8, 'farming:seed_wheat', nil, 15)
module.register_plant('farming:cotton_', 8, 'farming:seed_cotton', nil, 10)

if farming.mod == 'redo' then
	module.register_plant('farming:artichoke_', 5, 'farming:artichoke', nil, 20)
	module.register_plant('farming:asparagus_', 5, 'farming:asparagus', nil, 10)
	module.register_plant('farming:beanpole_', 5, 'farming:beans', 'farming:beanpole', 5)
	module.register_plant('farming:beetroot_', 5, 'farming:beetroot', nil, 10)
	module.register_plant('farming:blackberry_', 4, 'farming:blackberry', nil, 8)
	module.register_plant('farming:blueberry_', 4, 'farming:blueberries', nil, 8)
	module.register_plant('farming:cabbage_', 6, 'farming:cabbage', nil, 20)
	module.register_plant('farming:carrot_', 8, 'farming:carrot', nil, 10)
	module.register_plant('farming:chili_', 8, 'farming:chili_pepper', nil, 15)
	module.register_plant('farming:cocoa_', 4, 'farming:cocoa_beans_raw', nil, 10)
	module.register_plant('farming:coffee_', 5, 'farming:coffee_beans', nil, 5)
	module.register_plant('farming:corn_', 8, 'farming:corn', nil, 15)
	module.register_plant('farming:cucumber_', 4, 'farming:cucumber', nil, 10)
	module.register_plant('farming:eggplant_', 4, 'farming:eggplant', nil, 15)
	module.register_plant('farming:garlic_', 5, 'farming:garlic', nil, 10)
	module.register_plant('farming:ginger_', 4, 'farming:ginger', nil, 7)
	module.register_plant('farming:grapes_', 8, 'farming:grapes', 'farming:trellis', 8)
	module.register_plant('farming:hemp_', 8, 'farming:seed_hemp', 6)
	module.register_plant('farming:lettuce_', 5, 'farming:lettuce', 18)
	module.register_plant('farming:mint_', 4, 'farming:seed_mint', 10)
	module.register_plant('farming:onion_', 5, 'farming:onion', 15)
	module.register_plant('farming:parsley_', 3, 'farming:parsley', 8)
	module.register_plant('farming:pea_', 5, 'farming:pea_pod', 10)
	module.register_plant('farming:pepper_', 5, 'farming:pepper', 17)
	module.register_plant('farming:pepper_', 6, 'farming:pepper_yellow', 17)
	module.register_plant('farming:pepper_', 7, 'farming:pepper_red', 17)
	module.register_plant('farming:pineapple_', 8, 'farming:pineapple_top', 18)
	module.register_plant('farming:potato_', 4, 'farming:potato', 20)
	module.register_plant('farming:raspberry_', 4, 'farming:raspberries', 8)
	module.register_plant('farming:rhubarb_', 4, 'farming:rhubarb', 10)
	module.register_plant('farming:rice_', 8, 'farming:seed_rice', 15)
	module.register_plant('farming:rye_', 8, 'farming:seed_rye', 15)
	module.register_plant('farming:oat_', 8, 'farming:seed_oat', 15)
	module.register_plant('farming:soy_', 7, 'farming:soy_pod', 12)
	module.register_plant('farming:spinach_', 4, 'farming:spinach', 10)
	module.register_plant('ethereal:strawberry_', 8, 'ethereal:strawberry', 8)
	module.register_plant('farming:sunflower_', 8, 'farming:seed_sunflower', 12)
	module.register_plant('farming:tomato_', 8, 'farming:tomato', 18)
	module.register_plant('farming:vanilla_', 8, 'farming:vanilla', 5)
end

if minetest.settings: get_bool('etc.farming_tweaks_compost', true) then
	local compost_tickrate = minetest.settings: get('etc.farming_tweaks_compost_tickrate') or 120
	compost_tickrate = math.max(30, compost_tickrate - 30)
	
	local compost_exhaust_chance = minetest.settings: get('etc.farming_tweaks_compost_exhaust_chance') or 60
	local should_exhaust
	if compost_exhaust_chance == 0 then
		should_exhaust = function ()
			return false
		end
	else
		should_exhaust = function ()
			return math.random(1, compost_exhaust_chance) == math.floor(compost_exhaust_chance/2)
		end
	end
	
	local function set_next_tick (pos, mult)
		local timer = minetest.get_node_timer(pos)
		timer: start(math.random(30, 30 + math.floor(compost_tickrate * 2 * mult)))
	end
	
	local function compost_on_construct (pos)
		local name = minetest.get_node(pos).name
		set_next_tick(pos, name == 'etcetera:compost_tilled' and 1.5 or 1)
	end
	
	local function compost_on_timer (pos)
		local name = minetest.get_node(pos).name
		
		if should_exhaust() then
			local new_name = name == 'etcetera:compost_tilled' and 'farming:soil' or 'farming:soil_wet'
			minetest.set_node(pos, {name = new_name})
			return
		end
		
		boost_growth(pos + vector.new(0, 1, 0))
		set_next_tick(pos, name == 'etcetera:compost_tilled' and 1.5 or 1)
	end
	
	etc.register_node('compost', {
		displayname = 'Compost',
		description = 'Boosts growth of plants growing in it. '.. (compost_exhaust_chance ~=0 and 'Will eventually convert to regular soil.' or ''),
		tiles = {'etc_compost.png'},
		groups = {crumbly=3, soil = 1},
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = 'etcetera:compost',
			dry = 'etcetera:compost_tilled',
			wet = 'etcetera:compost_tilled_wet'
		}
	})
	
	etc.register_node('compost_tilled', {
		tiles = {'etc_compost.png^(farming_soil.png^[multiply:#746423)', 'etc_compost.png'},
		drop = 'etcetera:compost',
		groups = {crumbly=3, not_in_creative_inventory = 1, soil = 3, grassland = 1, field = 1},
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = 'etcetera:compost',
			dry = 'etcetera:compost_tilled',
			wet = 'etcetera:compost_tilled_wet'
		},
		on_construct = compost_on_construct,
		on_timer = compost_on_timer
	})

	etc.register_node('compost_tilled_wet', {
		tiles = {'etc_compost.png^(farming_soil_wet.png^[multiply:#746423)', 'etc_compost.png^farming_soil_wet_side.png'},
		drop = 'etcetera:compost',
		groups = {crumbly=3, not_in_creative_inventory = 1, soil = 3, wet = 1, grassland = 1, field = 1},
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = 'etcetera:compost',
			dry = 'etcetera:compost_tilled',
			wet = 'etcetera:compost_tilled_wet'
		},
		on_construct = compost_on_construct,
		on_timer = compost_on_timer
	})
	
	minetest.register_abm {
		nodenames = {'etcetera:compost_tilled', 'etcetera:compost_tilled_wet'},
		chance = 1,
		interval = compost_tickrate + 30,
		catch_up = true,
		action = function(pos, node)
			set_next_tick(pos, name == 'etcetera:compost_tilled' and 1.5 or 1)
		end
	}
	
	if minetest.settings: get_bool('etc.farming_tweaks_trowel', true) then
		local trowel_uses = minetest.settings: get('etc.farming_tweaks_trowel_uses') or 180
		
		local trowel_nodes = {
			['default:dirt'] = 'etcetera:compost_tilled',
			['farming:soil'] = 'etcetera:compost_tilled',
			['farming:soil_wet'] = 'etcetera:compost_tilled_wet',
			['default:dry_dirt'] = 'etcetera:compost_tilled',
			['farming:dry_soil'] = 'etcetera:compost_tilled',
			['farming:dry_soil_wet'] = 'etcetera:compost_tilled_wet',
			['default:desert_sand'] = 'etcetera:compost_tilled',
			['farming:desert_sand_soil'] = 'etcetera:compost_tilled',
			['farming:desert_sand_soil_wet'] = 'etcetera:compost_tilled_wet'
		}
		
		etc.register_tool('trowel', {
			displayname = 'Trowel',
			description = 'Used to swap dirt or farmland for compost without breaking the crop above.',
			stats = '<LMB> on soil or the plant above it to swap for compost',
			inventory_image = 'etc_trowel.png',
			wield_image = 'etc_trowel.png^[transformFX',
			on_use = function (itemstack, user, pointed_thing)
				local pos = pointed_thing.under
				local node = minetest.get_node(pos)
				
				local inv = user: get_inventory()
				
				if module.plants[node.name] then
					pos = pos - vector.new(0, 1, 0)
					node = minetest.get_node(pos)
				end
				
				if trowel_nodes[node.name] then
					if inv: contains_item('main', 'etcetera:compost') then
						inv: remove_item('main', 'etcetera:compost')
						
						local node_base = minetest.registered_items[node.name].soil.base
						
						node.name = trowel_nodes[node.name]
						minetest.swap_node(pos, node)
						set_next_tick(pos, node.name == 'etcetera:compost_tilled' and 1.5 or 1)
						
						minetest.sound_play('default_dig_crumbly', {to_player = user: get_player_name(), gain = 1}, true)
						
						etc.give_or_drop(user, user: get_pos(), ItemStack(node_base))
					end
					
					local wear = itemstack: get_wear()
					wear = wear + 65536/trowel_uses
					if wear >= 65535 then
						minetest.sound_play('default_tool_breaks', {to_player = user: get_player_name(), gain = 1}, true)
						return ItemStack()
					end
					itemstack: set_wear(wear)
					return itemstack
				end
			end
		})
		
		minetest.register_craft {
			recipe = {
				{'etc:ct_hammer', 'default:steel_ingot'},
				{'default:stick', ''}
			},
			output = 'etc:trowel'
		}
	end
	
	local function get_composter_infotext (pos)
		local meta = minetest.get_meta(pos)
		
		meta: set_string('infotext', table.concat {
			'Greenwaste: ' .. meta: get_int 'waste' or 0,
			'/100\n',
			'Compost: ' .. meta: get_int 'compost' or 0,
			'/100',
		})
	end
	
	local function update_composter_display (pos)
		local meta = minetest.get_meta(pos)
		local waste = meta: get_int('waste') / 100
		local compost = meta: get_int('compost') / 100
		
		local found = etc.update_node_display(pos, compost > waste and compost or waste, compost > waste and 'etc_compost.png' or 'etc_greenwaste.png')
		
		if (not found) and (waste+compost) ~= 0 then
			etc.add_node_display(pos, compost > waste and 'etc_compost.png' or 'etc_greenwaste.png', 15.25/16, compost > waste and compost or waste)
		end
	end
	
	minetest.register_lbm {
		name  = 'etcetera:update_composter_display',
		nodenames = {'etcetera:composter'},
		run_at_every_load = true,
		action = function (pos, node)
			update_composter_display(pos)
		end,
	}
	
	local compost_process_rate = minetest.settings: get('etc.farming_tweaks_compost_process_rate') or 0.5
	
	etc.register_node('composter', {
		displayname = 'Compost Bin',
		description = 'Converts plant material into compost over time.',
		stats = {
			'<RMB> to add items',
			'<LMB> with a shovel to remove compost'
		},
		tiles = {'etc_tarred_wood.png', 'etc_tarred_wood.png', 'etc_composter_side.png'},
		paramtype = 'light',
		sunlight_propagates = true,
		drawtype = 'nodebox',
		node_box = {
			type = 'fixed',
			fixed = {
				{0.5, -7/16, 0.5, -0.5, -0.5, -0.5},
				{7/16, 7/16, 7/16, 5/16, -7/16, 5/16},
				etc.rotate_nodebox({7/16, 7/16, 7/16, 5/16, -7/16, 5/16}, 'y', 1),
				etc.rotate_nodebox({7/16, 7/16, 7/16, 5/16, -7/16, 5/16}, 'y', 2),
				etc.rotate_nodebox({7/16, 7/16, 7/16, 5/16, -7/16, 5/16}, 'y', 3),
				{0.5, -2/16, 0.5, 7/16, -6/16, -0.5},
				{0.5, 3/16, 0.5, 7/16, -1/16, -0.5},
				{0.5, 0.5, 0.5, 7/16, 4/16, -0.5},
				etc.rotate_nodebox({0.5, -2/16, 0.5, 7/16, -6/16, -0.5}, 'y', 1),
				etc.rotate_nodebox({0.5, 3/16, 0.5, 7/16, -1/16, -0.5}, 'y', 1),
				etc.rotate_nodebox({0.5, 0.5, 0.5, 7/16, 4/16, -0.5}, 'y', 1),
				etc.rotate_nodebox({0.5, -2/16, 0.5, 7/16, -6/16, -0.5}, 'y', 2),
				etc.rotate_nodebox({0.5, 3/16, 0.5, 7/16, -1/16, -0.5}, 'y', 2),
				etc.rotate_nodebox({0.5, 0.5, 0.5, 7/16, 4/16, -0.5}, 'y', 2),
				etc.rotate_nodebox({0.5, -2/16, 0.5, 7/16, -6/16, -0.5}, 'y', 3),
				etc.rotate_nodebox({0.5, 3/16, 0.5, 7/16, -1/16, -0.5}, 'y', 3),
				etc.rotate_nodebox({0.5, 0.5, 0.5, 7/16, 4/16, -0.5}, 'y', 3),
			}
		},
		selection_box = {
			type = 'fixed',
			fixed = {0.5, 0.5, 0.5, -0.5, -0.5, -0.5}
		},
		groups = {cracky = 3, oddly_breakable_by_hand = 1},
		sounds = default.node_sound_wood_defaults(),
		on_construct = function (pos)
			local meta = minetest.get_meta(pos)
			
			meta: set_int('waste', 0)
			meta: set_int('compost', 0)
			
			get_composter_infotext(pos)
			
			local timer = minetest.get_node_timer(pos)
			timer: start(compost_process_rate)
		end,
		
		on_destruct = function (pos)
			etc.remove_node_display(pos)
		end,
		
		on_timer = function (pos)
			local meta = minetest.get_meta(pos)
			
			local waste = meta: get_int 'waste'
			local compost = meta: get_int 'compost'
			
			if compost < 100 and waste >= 1 then
				waste = waste - 1
				compost = compost + 1
				
				meta: set_int('waste', waste)
				meta: set_int('compost', compost)
			end
			
			get_composter_infotext(pos)
			update_composter_display(pos)
			
			local timer = minetest.get_node_timer(pos)
			timer: start(compost_process_rate)
		end,
		
		on_rightclick = function (pos, node, clicker, itemstack)
			local compost = module.compost_values[itemstack: get_name()]
			
			local meta = minetest.get_meta(pos)
			local waste = meta: get_int 'waste'
			
			if compost and waste + (compost/2) <= 100 then
				itemstack: take_item(1)
				
				meta: set_int('waste', math.min(100, waste + compost))
				
				get_composter_infotext(pos)
				update_composter_display(pos)
				
				return itemstack
			end
		end,
		
		on_punch = function (pos, node, puncher, pointed_thing)
			local itemstack = puncher: get_wielded_item()
			
			if minetest.get_item_group(itemstack: get_name(), 'shovel') then
				local meta = minetest.get_meta(pos)
				local compost = meta: get_int 'compost'
				local compost_available = math.floor(compost/10)
				
				if compost_available >= 1 then
					meta: set_int('compost', compost - 10)
					etc.give_or_drop(puncher, puncher: get_pos(), ItemStack('etcetera:compost'))
				end
				
				get_composter_infotext(pos)
				update_composter_display(pos)
			end
		end
	})
	
	if etc.modules.treated_wood then
		minetest.register_craft {
			recipe = {
				{'etc:tarred_wood', '', 'etc:tarred_wood'},
				{'etc:tarred_wood', 'default:dirt', 'etc:tarred_wood'},
				{'etc:tarred_wood', 'etc:tarred_wood', 'etc:tarred_wood'}
			},
			output = 'etc:composter'
		}
	else
		minetest.register_craft {
			recipe = {
				{'group:wood', '', 'group:wood'},
				{'group:wood', 'default:dirt', 'group:wood'},
				{'group:wood', 'group:wood', 'group:wood'}
			},
			output = 'etc:composter'
		}
	end
	
	module.compost_values['default:acacia_bush_sapling'] = 15
	module.compost_values['default:blueberry_bush_sapling'] = 15
	module.compost_values['default:bush_sapling'] = 15
	module.compost_values['default:pine_bush_sapling'] = 15
	
	module.compost_values['default:acacia_sapling'] = 20
	module.compost_values['default:aspen_sapling'] = 20
	module.compost_values['default:emergent_jungle_sapling'] = 20
	module.compost_values['default:junglesapling'] = 20
	module.compost_values['default:pine_sapling'] = 20
	module.compost_values['default:sapling'] = 20
	
	module.compost_values['default:acacia_bush_leaves'] = 6
	module.compost_values['default:blueberry_bush_leaves'] = 6
	module.compost_values['default:bush_leaves'] = 6
	module.compost_values['default:pine_bush_leaves'] = 6
	module.compost_values['default:acacia_leaves'] = 6
	module.compost_values['default:aspen_leaves'] = 6
	module.compost_values['default:jungleleaves'] = 6
	module.compost_values['default:pine_leaves'] = 6
	module.compost_values['default:leaves'] = 6
	
	module.compost_values['default:grass_1'] = 6
	module.compost_values['default:dry_grass_1'] = 3
	module.compost_values['default:marram_grass_1'] = 8
	module.compost_values['default:junglegrass'] = 9
	
	module.compost_values['default:large_cactus_seedling'] = 24
	module.compost_values['default:fern_1'] = 12
	module.compost_values['default:papyrus'] = 15
	module.compost_values['default:sand_with_kelp'] = 19
	
	module.compost_values['default:blueberries'] = 18
	module.compost_values['default:apple'] = 22
	
	if minetest.get_modpath 'flowers' then
		module.compost_values['flowers:mushroom_red'] = 15
		module.compost_values['flowers:mushroom_brown'] = 15
		
		module.compost_values['flowers:chrysanthemum_green'] = 12
		module.compost_values['flowers:dandelion_white'] = 12
		module.compost_values['flowers:dandelion_yellow'] = 12
		module.compost_values['flowers:geranium'] = 12
		module.compost_values['flowers:rose'] = 12
		module.compost_values['flowers:tulip'] = 12
		module.compost_values['flowers:tulip_black'] = 12
		module.compost_values['flowers:viola'] = 12
	end
end

return module
