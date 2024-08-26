
local bench_form = function(pos, name, desc)
	return [[
		formspec_version[7]
		size[10.25,9.25]
		background9[0,0;0,0;etc_formbg.png;true;8]
		field[-1,-1;0,0;pos;;]]..minetest.serialize(pos)..[[]
		list[current_player;main;0.25,4.25;8,4]
		list[nodemeta:]]..pos.x..[[,]]..pos.y..[[,]]..pos.z..[[;item;0.25,0.25;1,1]
		listring[]
		set_focus[itemname;false]
		]].. 'field[1.5,0.25;8.5,1;itemname;;'..(name or '')..']' .. [[
		]].. 'textarea[0.25,1.5;9.75,1.25;itemdesc;;'..(desc and desc: sub(2, -1) or '')..']' .. [[
		field_close_on_enter[itemname;false]
		field_close_on_enter[itemdesc;false]
		image_button[3.125,3;4,1;etc_rename_button.png;commit;]
		tooltip[commit;Rename Item]
	]]
end

etc: register_node('table_labelling', {
	displayname = 'Labelling Bench',
	description = 'Used to change the name and add or change the description of items.',
	tiles = {'etc_labelling_bench_top.png', 'etc_labelling_bench_bottom.png', 'etc_labelling_bench_side.png'},
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
		minetest.show_formspec(clicker: get_player_name(), 'etcetera:labelling_bench', bench_form(pos,
			item and item: get_short_description(),
			item and (item: get_description() ~= item: get_short_description()) and item: get_description(): gsub(item: get_short_description(), '')
		))
	end,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack: get_count() < 1 then stack = nil end
		minetest.show_formspec(player: get_player_name(), 'etcetera:labelling_bench', bench_form(pos,
			stack: get_short_description(),
			(stack: get_description() ~= stack: get_short_description()) and stack: get_description(): gsub(stack: get_short_description(), '')
		))
	end,
	
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local item = minetest.get_meta(pos): get_inventory(): get_stack('item', 1)
		if item: get_count() < 1 then item = nil end
		minetest.show_formspec(player: get_player_name(), 'etcetera:labelling_bench', bench_form(pos,
			item and item: get_short_description(),
			item and (item: get_description() ~= item: get_short_description()) and item: get_description(): gsub(item: get_short_description(), '')
		))
	end,
	
	on_dig = function (pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty('item') then
			etc.give_or_drop(digger, vector.add(pos, vector.new(0, 1, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
		end
		
		etc.give_or_drop(digger, pos, ItemStack 'etcetera:table_labelling')
		minetest.set_node(pos, {name='air'})
		return true
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == 'etcetera:labelling_bench' and fields.pos then
		local success, pos = pcall(minetest.deserialize, fields.pos)
		if success and minetest.get_node(pos).name == 'etcetera:table_labelling' then
			local inv = minetest.get_meta(pos): get_inventory()
			local stack = inv: get_stack('item', 1)
			if stack and stack: get_count() > 0 then
				stack: get_meta(): set_string('description', fields.itemname .. (fields.itemdesc ~= '' and '\n' .. fields.itemdesc or '' ))
				inv: set_stack('item', 1, stack)
			end
		end
	end
end)

if minetest.get_modpath 'default' and etc.modules.basic_resources then
	if minetest.get_modpath 'chunkydeco' and minetest.settings: get_bool('etc.labelling_bench_use_chunkydeco', true) then
		minetest.register_craft {
			output = 'etc:table_labelling',
			recipe = {
				{'default:paper', 'default:stick', 'etc:string'},
				{'', 'group:workbench', ''}
			}
		}
	else
		minetest.register_craft {
			output = 'etc:table_labelling',
			recipe = {
				{'default:paper', 'default:stick', 'etc:string'},
				{'default:stick', 'group:wood', 'default:stick'},
				{'group:wood', '', 'group:wood'}
			}
		}
	end
end
