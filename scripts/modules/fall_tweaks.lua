
if beds and minetest.settings: get_bool('etc.fall_tweaks_beds', true) then
	local bed_groups = table.copy(minetest.registered_items['beds:bed_bottom'].groups)
	bed_groups.fall_damage_add_percent = -50
	bed_groups.bouncy = 45
	minetest.override_item('beds:bed_bottom', {groups = bed_groups})
	minetest.override_item('beds:bed_top', {groups = bed_groups})
	minetest.override_item('beds:fancy_bed_bottom', {groups = bed_groups})
	minetest.override_item('beds:fancy_bed_top', {groups = bed_groups})
end

local leaves = {
	'default:acacia_leaves',
	'default:acacia_bush_leaves',
	'default:aspen_leaves',
	'default:blueberry_bush_leaves_with_berries',
	'default:blueberry_bush_leaves_with_berries',
	'default:bush_leaves',
	'default:jungleleaves',
	'default:leaves',
	'default:pine_needles',
	'default:pine_bush_needles'
}

if minetest.settings: get_bool('etc.fall_tweaks_leaves', true) then
	for _, v in pairs(leaves) do
		local leaves_groups = table.copy(minetest.registered_items[v].groups)
		leaves_groups.fall_damage_add_percent = -40
		minetest.override_item(v, {groups = leaves_groups})
	end
end


local wool = {
	'wool:black',
	'wool:blue',
	'wool:brown',
	'wool:cyan',
	'wool:dark_green',
	'wool:dark_grey',
	'wool:green',
	'wool:grey',
	'wool:magenta',
	'wool:orange',
	'wool:pink',
	'wool:red',
	'wool:violet',
	'wool:white',
	'wool:yellow',
}

if minetest.get_modpath 'wool' and minetest.settings: get_bool('etc.fall_tweaks_wool', true) then
	for _, v in pairs(wool) do
		local wool_groups = table.copy(minetest.registered_items[v].groups)
		wool_groups.fall_damage_add_percent = -55
		minetest.override_item(v, {groups = wool_groups})
	end
end

local fences = {
	'default:fence_wood',
	'default:fence_acacia_wood',
	'default:fence_aspen_wood',
	'default:fence_junglewood',
	'default:fence_pine_wood',
	'default:fence_rail_wood',
	'default:fence_rail_acacia_wood',
	'default:fence_rail_aspen_wood',
	'default:fence_rail_junglewood',
	'default:fence_rail_pine_wood'
}

if minetest.settings: get_bool('etc.fall_tweaks_fence', true) then
	for _, v in pairs(fences) do
		local fence_groups = table.copy(minetest.registered_items[v].groups)
		fence_groups.fall_damage_add_percent = 15
		minetest.override_item(v, {groups = fence_groups})
	end
end
