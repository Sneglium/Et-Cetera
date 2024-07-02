
local corrosion_nodes = {}

local corrosion_words = {
	'Slightly',
	'Partially',
	'Mostly',
	'Completely'
}

local function make_corrosion_group (modname, nodename)
	for i = 1, 4 do
		local id = modname .. ':' .. nodename
		local def = table.copy(minetest.registered_nodes[id])
		
		def.tiles = {def.tiles[1] .. '^(etc_corrosion_mask_'..i..'.png^[mask:etc_corrosion_'..nodename..'.png)'}
		local newdesc = def.description: gsub('@default%)', ''): gsub('[^a-zA-z ]', ''): sub(2, -2)
		def.description = etc.translate(newdesc) .. ' ' .. etc.translate('('..corrosion_words[i]..' Corroded)')
		def.groups.not_in_creative_inventory = i == 4 and 0 or 1
		minetest.register_node('etcetera:'..nodename..'_corroded_'..i, def)
		
		corrosion_nodes['etcetera:'..nodename..'_corroded_'..i] = 'etcetera:'..nodename..'_corroded_'..(i+1)
	end
	
	corrosion_nodes[modname..':'..nodename] = 'etcetera:'..nodename..'_corroded_1'
	corrosion_nodes['etcetera:'..nodename..'_corroded_4'] = nil
end

make_corrosion_group('default', 'steelblock')
make_corrosion_group('default', 'copperblock')
make_corrosion_group('default', 'bronzeblock')
make_corrosion_group('default', 'tinblock')

local abm_list = {}
for k, _ in pairs(corrosion_nodes) do
	table.insert(abm_list, k)
end

local speed_mult = minetest.settings: get 'etc.corrosion_speed_mult' or 1

minetest.register_abm {
	label = 'Metal Corrosion',
	nodenames = abm_list,
	neighbors = {'default:water_source', 'default:water_flowing', 'default:river_water_source', 'default:river_water_flowing'},
	interval = 8 / speed_mult,
	chance = math.ceil(6 / speed_mult),
	catch_up = true,
	action = function(pos, node)
		minetest.swap_node(pos, {name = corrosion_nodes[node.name], param2 = node.param2})
	end
}
