
local bench_form = function(pos, name, desc)
	return [[
		formspec_version[7]
		size[10.25,8]
		background9[0,0;0,0;etc_formbg.png;true;8]
		field[-1,-1;0,0;pos;;]]..minetest.serialize(pos)..[[]
		list[current_player;main;0.25,3;8,4]
		list[nodemeta:]]..pos.x..[[,]]..pos.y..[[,]]..pos.z..[[;item;1,1;1,1]
		listring[]
		scrollbaroptions[min=0;max=100;thumbsize=2;arrows=hide]
		scrollbar[3,0.5;6.25,0.5;horizontal;slider_r;0]
		scrollbar[3,1.25;6.25,0.5;horizontal;slider_g;0]
		scrollbar[3,2;6.25,0.5;horizontal;slider_b;0]
		label[2.25,0.75;Red]
		label[2.25,1.5;Green]
		label[2.25,2.25;Blue]
		tooltip[commit;Recolor Item]
	]]
end

etc: register_node('table_coloring', {
	displayname = 'Dyeing Table',
	description = 'Used to change the colors of items.',
	tiles = {'etc_coloring_bench_top.png', 'etc_labelling_bench_bottom.png', 'etc_labelling_bench_side.png'},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	paramtype2 = '4dir',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{0.5, 0.5, 0.5, -0.5, 5/16, -0.5},
			{7/16, 5/16, 7/16, 4/16, -0.5, 4/16},
			{7/16, 5/16, -7/16, 4/16, -0.5, -4/16},
			{-7/16, 5/16, 7/16, -4/16, -0.5, 4/16},
			{-7/16, 5/16, -7/16, -4/16, -0.5, -4/16},
			{6/16, 1/16, 6/16, 5/16, -1/16, -5/16},
			etc.rotate_nodebox({6/16, 1/16, 6/16, 5/16, -1/16, -5/16}, 'y', 1),
			etc.rotate_nodebox({6/16, 1/16, 6/16, 5/16, -1/16, -5/16}, 'y', 2),
			etc.rotate_nodebox({6/16, 1/16, 6/16, 5/16, -1/16, -5/16}, 'y', 3)
		}
	},
	on_place = minetest.rotate_node,
	groups = {choppy = 2, oddly_breakable_by_hand = 1},
	sounds = minetest.global_exists('default') and default.node_sound_wood_defaults() or nil,
	
	on_construct = function(pos)
		minetest.get_meta(pos): get_inventory(): set_size('item', 1)
	end,
	
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local item = minetest.get_meta(pos): get_inventory(): get_stack('item', 1)
		if item: get_count() < 1 then item = nil end
		minetest.show_formspec(clicker: get_player_name(), 'etcetera:coloring_bench', bench_form(pos))
	end,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack: get_count() < 1 then stack = nil end
		minetest.show_formspec(player: get_player_name(), 'etcetera:coloring_bench', bench_form(pos))
	end,
	
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local item = minetest.get_meta(pos): get_inventory(): get_stack('item', 1)
		if item: get_count() < 1 then item = nil end
		minetest.show_formspec(player: get_player_name(), 'etcetera:coloring_bench', bench_form(pos))
	end,
	
	on_dig = function (pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty('item') then
			etc.give_or_drop(digger, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
		end
		
		etc.give_or_drop(digger, pos, ItemStack 'etcetera:table_coloring')
		minetest.set_node(pos, {name='air'})
		return true
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == 'etcetera:coloring_bench' and fields.pos then
		local success, pos = pcall(minetest.deserialize, fields.pos)
		if success and minetest.get_node(pos).name == 'etcetera:table_coloring' then
			local inv = minetest.get_meta(pos): get_inventory()
			local stack = inv: get_stack('item', 1)
			if stack and stack: get_count() > 0 then
				local r = minetest.explode_scrollbar_event(fields.slider_r).value * 0.01
				local g = minetest.explode_scrollbar_event(fields.slider_g).value * 0.01
				local b = minetest.explode_scrollbar_event(fields.slider_b).value * 0.01
				
				stack: get_meta(): set_string('color', etc.rgb_to_hex(r, g, b))
				inv: set_stack('item', 1, stack)
			end
		end
	end
end)

if minetest.get_modpath 'default' and minetest.get_modpath 'dye' then
	if minetest.get_modpath 'chunkydeco' and minetest.settings: get_bool('etc.coloring_bench_use_chunkydeco', true) then
		minetest.register_craft {
			output = 'etc:table_coloring',
			recipe = {
				{'dye:red', 'dye:green', 'dye:blue'},
				{'', 'group:workbench', ''}
			}
		}
	else
		minetest.register_craft {
			output = 'etc:table_coloring',
			recipe = {
				{'dye:red', 'dye:green', 'dye:blue'},
				{'default:stick', 'group:wood', 'default:stick'},
				{'group:wood', '', 'group:wood'}
			}
		}
	end
end
