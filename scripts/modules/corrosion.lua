
local corrosion = {corrosion_nodes = {}}

local corrosion_words = {
	'Slightly',
	'Partially',
	'Mostly',
	'Completely'
}

if minetest.global_exists('unified_inventory') then
	unified_inventory.register_craft_type('etcetera:corrosion', {
		description = 'Progressive Corrosion (In Water)',
		icon = 'default_water.png',
		width = 1,
		height = 1,
		dynamic_display_size = function(craft)
			return {width = 1, height = 1}
		end,
		uses_crafting_grid = false
	})
end

if minetest.global_exists('i3') then
	i3.register_craft_type('etcetera:corrosion', {
		description = 'Progressive Corrosion (In Water)',
		icon = 'default_water.png',
	})
end

local function make_corrosion_group (modname, nodename, texname)
	local corrosion_tex = texname or ('etc_corrosion_' .. nodename .. '.png')
	local id = modname .. ':' .. nodename
	
	local newgroups = minetest.registered_nodes[id].groups
	newgroups.etc_corrodable = 1
	
	minetest.override_item(id, {groups=newgroups})
	
	for i = 1, 4 do
		local def = table.copy(minetest.registered_nodes[id])
		def.tiles = {table.concat {def.tiles[1], '^(etc_corrosion_mask_', i, '.png^[mask:', corrosion_tex, ')'}}
		def.description = table.concat {
			minetest.get_background_escape_sequence('#22242d'),
			def.description,
			' ',
			etc.translate('('..corrosion_words[i]..' Corroded)')
		}
		def.groups.not_in_creative_inventory = i == 4 and 0 or 1
		def.groups.etc_corrodable = i == 4 and 0 or 1
		minetest.register_node('etcetera:'..nodename..'_corroded_'..i, def)
		
		corrosion.corrosion_nodes['etcetera:'..nodename..'_corroded_'..i] = 'etcetera:'..nodename..'_corroded_'..(i+1)
	end
	
	corrosion.corrosion_nodes[modname..':'..nodename] = 'etcetera:'..nodename..'_corroded_1'
	corrosion.corrosion_nodes['etcetera:'..nodename..'_corroded_4'] = nil
	
	if etc.modules.basic_resources then
		for i = 1, 4 do
			minetest.register_craft {
				type = 'shapeless',
				output = modname..':'..nodename,
				recipe = {'etcetera:'..nodename..'_corroded_'..i, 'etc:acid'}
			}
		end
	end
	
	if minetest.global_exists('unified_inventory') then
		unified_inventory.register_craft({
		type = 'etcetera:corrosion',
		output = 'etcetera:'..nodename..'_corroded_4',
		items = {modname..':'..nodename},
		width = 1
	})
	end
	
	if minetest.global_exists('i3') then
		i3.register_craft {
			type   = 'etcetera:corrosion',
			result = 'etcetera:'..nodename..'_corroded_4',
			items  = {modname..':'..nodename},
		}
	end
end

make_corrosion_group('default', 'steelblock')
make_corrosion_group('default', 'copperblock')
make_corrosion_group('default', 'bronzeblock')
make_corrosion_group('default', 'tinblock')

if etc.modules.wrought_iron then
	make_corrosion_group('etcetera', 'wrought_iron_block')
end

function corrosion.add_metal_block (item, texname_override)
	etc.log.assert(etc.is_itemstring(item), 'Item name to add as corrodable block must be a valid itemstring')
	etc.log.assert(texname_override == nil or etc.is_string(texname_override), 'Corrosion texture override must be a string or nil')
	
	local texname_override = texname_override or 'etc_corrosion_steelblock.png'
	local itemstring_split = string.split(ItemStack(item): get_name(), ':')
	
	make_corrosion_group(itemstring_split[1], itemstring_split[2], texname_override)
end

local speed_mult = minetest.settings: get 'etc.corrosion_speed_mult' or 8

minetest.register_abm {
	label = 'Metal Corrosion',
	nodenames = {'group:etc_corrodable'},
	neighbors = {
		'default:water_source',
		'default:water_flowing',
		'default:river_water_source',
		'default:river_water_flowing'
	},
	interval = 8 / speed_mult,
	chance = math.ceil(6 / speed_mult),
	catch_up = true,
	action = function(pos, node)
		if minetest.get_meta(pos): get_string('sealed') == 'true' then return end
		print(node.name, corrosion.corrosion_nodes[node.name])
		minetest.swap_node(pos, {name = corrosion.corrosion_nodes[node.name], param2 = node.param2})
	end
}

if minetest.global_exists('technic') then
	corrosion.add_metal_block('technic:carbon_steel_block', 'etc_corrosion_carbon_steel_block.png')
	corrosion.add_metal_block('technic:cast_iron_block', 'etc_corrosion_cast_iron_block.png')
	corrosion.add_metal_block('technic:lead_block', 'etc_corrosion_lead_block.png')
end

return corrosion
