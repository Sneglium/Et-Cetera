
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
	plants = {}
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

function module.register_plant (name_prefix, stages, seed, guide_node)
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
	end
end


module.register_plant('farming:wheat_', 8, 'farming:seed_wheat')
module.register_plant('farming:cotton_', 8, 'farming:seed_cotton')

if farming.mod == 'redo' then
	module.register_plant('farming:artichoke_', 5, 'farming:artichoke')
	module.register_plant('farming:asparagus_', 5, 'farming:asparagus')
	module.register_plant('farming:beanpole_', 5, 'farming:beans', 'farming:beanpole')
	module.register_plant('farming:beetroot_', 5, 'farming:beetroot')
	module.register_plant('farming:blackberry_', 4, 'farming:blackberry')
	module.register_plant('farming:blueberry_', 4, 'farming:blueberries')
	module.register_plant('farming:cabbage_', 6, 'farming:cabbage')
	module.register_plant('farming:carrot_', 8, 'farming:carrot')
	module.register_plant('farming:chili_', 8, 'farming:chili_pepper')
	module.register_plant('farming:cocoa_', 4, 'farming:cocoa_beans_raw')
	module.register_plant('farming:coffee_', 5, 'farming:coffee_beans')
	module.register_plant('farming:corn_', 8, 'farming:corn')
	module.register_plant('farming:cucumber_', 4, 'farming:cucumber')
	module.register_plant('farming:eggplant_', 4, 'farming:eggplant')
	module.register_plant('farming:garlic_', 5, 'farming:garlic')
	module.register_plant('farming:ginger_', 4, 'farming:ginger')
	module.register_plant('farming:grapes_', 8, 'farming:grapes', 'farming:trellis')
	module.register_plant('farming:hemp_', 8, 'farming:seed_hemp')
	module.register_plant('farming:lettuce_', 5, 'farming:lettuce')
	module.register_plant('farming:mint_', 4, 'farming:seed_mint')
	module.register_plant('farming:onion_', 5, 'farming:onion')
	module.register_plant('farming:parsley_', 3, 'farming:parsley')
	module.register_plant('farming:pea_', 5, 'farming:pea_pod')
	module.register_plant('farming:pepper_', 5, 'farming:pepper')
	module.register_plant('farming:pepper_', 6, 'farming:pepper_yellow')
	module.register_plant('farming:pepper_', 7, 'farming:pepper_red')
	module.register_plant('farming:pineapple_', 8, 'farming:pineapple_top')
	module.register_plant('farming:potato_', 3, 'farming:potato')
	module.register_plant('farming:potato_', 4, 'farming:potato')
	module.register_plant('farming:raspberry_', 4, 'farming:raspberries')
	module.register_plant('farming:rhubarb_', 4, 'farming:rhubarb')
	module.register_plant('farming:rice_', 8, 'farming:seed_rice')
	module.register_plant('farming:rye_', 8, 'farming:seed_rye')
	module.register_plant('farming:oat_', 8, 'farming:seed_oat')
	module.register_plant('farming:soy_', 7, 'farming:soy_pod')
	module.register_plant('farming:spinach_', 4, 'farming:spinach')
	module.register_plant('ethereal:strawberry_', 8, 'ethereal:strawberry')
	module.register_plant('farming:sunflower_', 8, 'farming:seed_sunflower')
	module.register_plant('farming:tomato_', 8, 'farming:tomato')
	module.register_plant('farming:vanilla_', 8, 'farming:vanilla')
end

if minetest.settings: get_bool('etc.farming_tweaks_compost', true) then
	local compost_tickrate = minetest.settings: get('etc.farming_tweaks_compost_tickrate') or 45
	compost_tickrate = math.max(30, compost_tickrate)
	
	local compost_exhaust_chance = minetest.settings: get('etc.farming_tweaks_compost_exhaust_chance') or 12
	local should_exhaust
	if compost_exhaust_chance == 0 then
		should_exhaust = function ()
			return false
		end
	else
		should_exhaust = function ()
			return math.random(1, compost_exhaust_chance) == 1
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
			minetest.set_node(pos, {name = 'default:dirt'})
			return
		end
		
		boost_growth(pos + vector.new(0, 1, 0))
		
		set_next_tick(pos, name == 'etcetera:compost_tilled' and 1.5 or 1)
	end
	
	etc.register_node('compost', {
		displayname = 'Compost',
		description = 'Boosts growth of plants growing in it.',
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
		interval = 1,
		catch_up = true,
		action = function(pos, node)
			set_next_tick(pos, name == 'etcetera:compost_tilled' and 1.5 or 1)
		end
	}
	
	local trowel_nodes = {
		['default:dirt'] = 'etcetera:compost',
		['farming:soil'] = 'etcetera:compost_tilled',
		['farming:soil_wet'] = 'etcetera:compost_tilled_wet',
		['default:dry_dirt'] = 'etcetera:compost',
		['farming:dry_soil'] = 'etcetera:compost_tilled',
		['farming:dry_soil_wet'] = 'etcetera:compost_tilled_wet',
		['default:desert_sand'] = 'etcetera:compost',
		['farming:desert_sand_soil'] = 'etcetera:compost_tilled',
		['farming:desert_sand_soil_wet'] = 'etcetera:compost_tilled_wet'
	}
	
	etc.register_tool('trowel', {
		displayname = 'Trowel',
		description = 'Used to swap dirt or farmland for compost without breaking the crop above.',
		stats = '<LMB> to swap nodes',
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
					etc.give_or_drop(user, user: get_pos(), ItemStack(node_base))
				end
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

return module
