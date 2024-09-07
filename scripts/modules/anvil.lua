
local hammer_dura = minetest.settings: get('etc.anvil_hammer_num_uses') or 200
local repair_hammer = minetest.settings: get_bool('etc.anvil_circular_repair', false)
local repair_mult = minetest.settings: get('etc.anvil_repair_factor') or 4
local wrought_iron = minetest.settings: get_bool('etc.anvil_use_wrought_iron', true)
local no_break = minetest.settings: get_bool('etc.anvil_prevent_tool_break', true)
local particles = minetest.settings: get_bool('etc.anvil_particles', true)

local mithril_hammer = minetest.settings: get_bool('etc.anvil_mithril_hammer', true)
local hammer_dura_mith = minetest.settings: get('etc.anvil_mithril_hammer_num_uses') or 3000
local repair_mult_mith = minetest.settings: get('etc.anvil_mithril_repair_factor') or 50

etc.anvil_recipes = {}

if minetest.global_exists('unified_inventory') then
	unified_inventory.register_craft_type('etcetera:anvil', {
		description = 'Anvil & Hammer',
		icon = 'etc_anvil_side.png',
		width = 1,
		height = 1,
		dynamic_display_size = function(craft)
			return {width = 1, height = 1}
		end,
		uses_crafting_grid = false
	})
end

if minetest.global_exists('i3') then
	i3.register_craft_type('etcetera:anvil', {
		description = 'Anvil & Hammer',
		icon = 'etc_anvil_side.png',
	})
end

function etc.register_anvil_recipe (input, output, hits)
	etc.log.assert(etc.is_itemstring(input), 'Input item must be an itemstring pointing to an extant item')
	etc.log.assert(etc.is_itemstring(output), 'Output item must be an itemstring pointing to an extant item')
	etc.log.assert(etc.is_integer(hits), 'Number of hits must be an integer number')
	
	etc.anvil_recipes[input] = {output = output, hits = hits}
	
	if minetest.global_exists('unified_inventory') then
		unified_inventory.register_craft({
			type = 'etcetera:anvil',
			output = output,
			items = {input},
			width = 1
		})
	end
	
	if minetest.global_exists('i3') then
		i3.register_craft {
			type   = 'etcetera:anvil',
			result = output,
			items  = {input},
		}
	end
end

etc: register_tool('blacksmith_hammer', {
	displayname = 'Blacksmith\'s Hammer',
	stats = 'Use on an anvil with <LMB>',
	inventory_image = 'etc_blacksmith_hammer.png',
	tool_capabilities = {groupcaps={cracky={}}}
})

if minetest.global_exists('default') then
	minetest.register_craft {
		recipe = {
			{'etc:ct_file', 'default:steel_ingot', 'etc:ct_drill'},
			{'', 'default:stick', 'default:steel_ingot'},
			{'default:stick', '', 'etc:ct_hammer'}
		},
		output = 'etc:blacksmith_hammer'
	}
end

if minetest.global_exists('moreores') and mithril_hammer then
	etc: register_tool('blacksmith_hammer_mithril', {
		displayname = 'Legendary Blacksmith\'s Hammer',
		description = 'Far more durable and efficient.',
		stats = 'Use on an anvil with <LMB>',
		inventory_image = 'etc_blacksmith_hammer_mithril.png',
		tool_capabilities = {groupcaps={cracky={}}}
	})

	if minetest.global_exists('default') then
		minetest.register_craft {
			recipe = {
				{'etc:ct_file', 'moreores:mithril_ingot', 'etc:ct_drill'},
				{'etcetera:sandpaper_3', 'default:stick', 'moreores:mithril_ingot'},
				{'default:stick', '', 'etc:ct_hammer'}
			},
			output = 'etc:blacksmith_hammer_mithril'
		}
	end
end

local function valid_tool (stack)
	local name = stack: get_name()
	if name == 'etcetera:blacksmith_hammer' or name == 'etcetera:blacksmith_hammer_mithril' then
		return repair_hammer
	elseif minetest.registered_tools[name] then
		local def = stack: get_definition()
		return not (def.wear_represents or (def.groups and def.groups.no_repair) or (def.groups and def.groups.powertool))
	end
	return false
end

minetest.register_lbm {
	name  = 'etcetera:update_anvil_display',
	nodenames = {'etcetera:anvil'},
	run_at_every_load = true,
	action = function (pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		if not inv: is_empty('item') then
			etc.remove_item_display(pos)
			etc.add_item_display(vector.add(pos, vector.new(0, 0.35, 0)), inv: get_stack('item', 1), 1.5, 'random_flat')
		end
	end
}

local hammers = {
	['etcetera:blacksmith_hammer'] = {hammer_dura, repair_mult},
	['etcetera:blacksmith_hammer_mithril'] = {hammer_dura_mith, repair_mult_mith}
}

etc: register_node('anvil', {
	displayname = 'Anvil',
	stats = 'Add and remove items with <RMB>',
	tiles = {'etc_anvil_top.png', 'etc_anvil_bottom.png', 'etc_anvil_side.png'},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	drawtype = 'nodebox',
	groups = {cracky = 1},
	sounds = minetest.global_exists('default') and default.node_sound_metal_defaults() or nil,
	paramtype2 = '4dir',
	on_place = minetest.rotate_node,
	
	node_box = {
		type = 'fixed', 
		fixed = {
			{6/16, -6/16, 5/16, -6/16, -0.5, -5/16},
			{4/16, 0, 4/16, -4/16, -6/16, -4/16},
			{7/16, 5/16, 5/16, -7/16, 0, -5/16},
			{-7/16, 5/16, 3/16, -10/16, 2/16, -3/16},
			{7/16, 5/16, 4/16, 0.5, 1/16, -4/16}
		}
	},
	
	selection_box = {
		type = 'fixed',
		fixed = {
			{6/16, -6/16, 5/16, -6/16, -0.5, -5/16},
			{4/16, 0, 4/16, -4/16, -6/16, -4/16},
			{7/16, 5/16, 5/16, -7/16, 0, -5/16}
		}
	},
	
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		
		meta: set_int('progress', 0)
		meta: set_int('progress_needed', 0)
		
		meta: set_string('infotext', 'No Item')
		
		meta: get_inventory(): set_size('item', 1)
	end,
	
	on_dig = function (pos, node, digger)
		if minetest.is_protected(pos, digger: get_player_name()) then
			return false
		end
		
		etc.remove_item_display(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty('item') then
			etc.give_or_drop(digger, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
		end
		
		etc.give_or_drop(digger, pos, ItemStack 'etcetera:anvil')
		minetest.set_node(pos, {name='air'})
		return true
	end, 
	
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		if minetest.is_protected(pos, clicker: get_player_name()) then
			return clicker: get_wielded_item()
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		meta: set_int('progress', 0)
		etc.remove_item_display(pos)
		
		if not inv: is_empty('item') then
			etc.give_or_drop(clicker, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
			meta: set_string('infotext', 'No Item')
			return clicker: get_wielded_item()
		end
		
		local recipe = etc.anvil_recipes[itemstack: get_name()]
		if recipe or valid_tool(itemstack) then
			inv: set_stack('item', 1, itemstack)
			meta: set_int('progress_needed', math.floor((recipe and recipe.hits or 0)*(itemstack: get_count())))
			meta: set_string('infotext', itemstack: get_short_description())
			etc.add_item_display(vector.add(pos, vector.new(0, 0.35, 0)), itemstack, 1.5, 'random_flat')
			itemstack: clear()
			clicker: set_wielded_item(itemstack)
		end
		
		return clicker: get_wielded_item()
	end,
	
	on_punch = function (pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos, puncher: get_player_name()) then
			return false
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		local heldstack = puncher: get_wielded_item()
		
		local stackname = heldstack: get_name()
		
		if hammers[stackname] then
			if not inv: is_empty('item') then
				local stack = inv: get_stack('item', 1)
				local recipe = etc.anvil_recipes[stack: get_name()]
				if recipe then
					local held_wear = heldstack: get_wear() + math.floor(65535/(hammers[stackname][1] * 2))
					if held_wear >= 65535 then
						minetest.sound_play('default_tool_breaks', {to_player = puncher: get_player_name(), gain = 1}, true)
						heldstack: clear()
					else
						heldstack: set_wear(held_wear)
					end
					puncher: set_wielded_item(heldstack)
					
					meta: set_int('progress', meta: get_int('progress') + 1)
					etc.update_item_display(pos, stack, nil, 'random_flat')
					
					if default and particles then
						for i = 1, 5 do
							minetest.add_particle {
								pos = pos,
								velocity = vector.new((math.random()-0.5)*2, 3.5, (math.random()-0.5)*2),
								acceleration = vector.new(0, -9.8, 0),
								expirationtime = 2.5,
								size = 0,
								node = {name = 'default:tinblock'}
							}
						end
					end
					
					minetest.sound_play({name = 'default_dug_metal'}, {pos = pos, max_hear_distance = 16}, true)
					
					if meta: get_int('progress') >= meta: get_int('progress_needed') then
						local output = ItemStack(recipe.output)
						output: set_count(output: get_count() * stack: get_count())
						inv: set_stack('item', 1, output)
						meta: set_string('infotext', stack: get_short_description())
						etc.update_item_display(pos, output, nil, 'random_flat')
						local recipe = etc.anvil_recipes[stack: get_name()]
						if recipe then
							local itemtime = recipe.hits*10
							meta: set_int('progress', 0)
							meta: set_int('progress_needed', math.floor(itemtime+(itemtime-1)*(stack: get_count())*0.75))
						end
					end
				elseif valid_tool(stack) then
					local uses = etc.average_uses(stack: get_name())
					local wear = stack: get_wear()
					
					if wear >= 1 then
						if stack: get_meta(): get_string 'etc:tool_broken' ~= '' then
							local meta = stack: get_meta()
							meta: set_tool_capabilities()
							meta: set_string('etc:tool_broken', '')
							meta: set_string('inventory_image', minetest.registered_items[stack: get_name()].inventory_image)
						end
						
						local held_wear = heldstack: get_wear() + math.floor(65535/hammers[stackname][1])
						if held_wear >= 65535 then
							minetest.sound_play('default_tool_breaks', {to_player = puncher: get_player_name(), gain = 1}, true)
							heldstack: clear()
						else
							heldstack: set_wear(held_wear)
						end
						puncher: set_wielded_item(heldstack)
						
						minetest.sound_play({name = 'etc_anvil'}, {pos = pos, max_hear_distance = 16, gain = 1.2}, true)
						
						if particles then
							for i = 1, 5 do
								minetest.add_particle {
									pos = pos + vector.new(0, 0.35, 0),
									velocity = vector.new((math.random()-0.5)*2, 3.5, (math.random()-0.5)*2),
									acceleration = vector.new(0, -9.8, 0),
									expirationtime = 2.5,
									size = 1.5,
									texture = 'etc_anvil_spark.png',
									glow = 8,
									blend = 'add',
								}
							end
						end
						
						local repair = math.ceil((65535 / uses) * hammers[stackname][2])
						stack: set_wear(math.max(0, wear - repair))
						inv: set_stack('item', 1, stack)
					end
				end
			end
		end
	end
})

if minetest.global_exists('default') then
	if wrought_iron and etc.modules.wrought_iron then
		minetest.register_craft {
			recipe = {
				{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
				{'', 'etc:wrought_iron_block', ''}
			},
			output = 'etc:anvil'
		}
	else
		minetest.register_craft {
			recipe = {
				{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
				{'', 'default:steelblock', ''},
			},
			output = 'etc:anvil'
		}
	end
end

if no_break then
	local old_node_dig = minetest.node_dig
	
	minetest.node_dig = function (pos, node, digger)
		local wielded = digger and digger: get_wielded_item()
		local drops = minetest.get_node_drops(node, wielded and wielded: get_name())
		local node_def = core.registered_nodes[node.name]
		
		if wielded then
			local item_def = wielded: get_definition()
			local capabilities = wielded: get_tool_capabilities()
			local dig = minetest.get_dig_params(node_def and node_def.groups, capabilities, wielded: get_wear())
			if item_def and item_def.after_use then
				wielded = item_def.after_use(wielded, digger, node, dig) or wielded
			else
				if not minetest.is_creative_enabled(digger: get_player_name()) then
					wielded: set_wear(math.min(65535, wielded: get_wear() + dig.wear))
					if wielded: get_wear() >= 65534 then
						wielded: set_wear(65534)
						minetest.sound_play(item_def.sound and item_def.sound.breaks, {pos = pos, gain = 0.5}, true)
						local meta = wielded: get_meta()
						meta: set_tool_capabilities {}
						meta: set_string('etc:tool_broken', 'true')
						meta: set_string('inventory_image', item_def.inventory_image..'^[mask:etc_broken_tool.png')
						digger: set_wielded_item(wielded)
						return true
					end
				end
			end
		end
		
		return old_node_dig(pos, node, digger)
	end
end
