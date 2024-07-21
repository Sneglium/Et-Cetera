
if etc.modules.craft_tools and minetest.settings: get_bool('etc.more_loot_ct_tools', true) then
	dungeon_loot.register {
		{name = 'etcetera:ct_file', chance = 0.15, y = {-32768, -100}},
		{name = 'etcetera:ct_cutters', chance = 0.15, y = {-32768, -100}},
		{name = 'etcetera:ct_drill', chance = 0.15, y = {-32768, -100}},
		{name = 'etcetera:ct_knife', chance = 0.15, y = {-32768, -100}},
		{name = 'etcetera:ct_hammer', chance = 0.075, y = {-32768, -100}}
	}
end

if etc.modules.bees and minetest.settings: get_bool('etc.more_loot_honey', true) then
	dungeon_loot.register {
		{name = 'etcetera:bottle_honey', chance = 0.25, count = {2, 8}},
		{name = 'etcetera:honey_block', chance = 0.03, count = {1, 3}}
	}
end

if etc.modules.slime and minetest.settings: get_bool('etc.more_loot_slime', true) then
	dungeon_loot.register {
		{name = 'etcetera:slimeball', chance = 0.3, count = {1, 5}}
	}
end

if etc.modules.wrought_iron and minetest.settings: get_bool('etc.more_loot_wrought_iron', true) then
	dungeon_loot.register {
		{name = 'etcetera:wrought_iron_ingot', chance = 0.5, count = {2, 7}}
	}
end

if etc.modules.anvil and minetest.settings: get_bool('etc.more_loot_anvil', true) then
	dungeon_loot.register {
		{name = 'etcetera:blacksmith_hammer', chance = 0.075},
		{name = 'etcetera:anvil', chance = 0.02}
	}
end

if etc.modules.chalk and minetest.settings: get_bool('etc.more_loot_chalk', true) then
	dungeon_loot.register {
		{name = 'etcetera:chalk_red', chance = 0.045},
		{name = 'etcetera:chalk_orange', chance = 0.045},
		{name = 'etcetera:chalk_yellow', chance = 0.045},
		{name = 'etcetera:chalk_green', chance = 0.045},
		{name = 'etcetera:chalk_blue', chance = 0.045},
		{name = 'etcetera:chalk_violet', chance = 0.045},
		{name = 'etcetera:chalk_white', chance = 0.045},
		{name = 'etcetera:chalk_black', chance = 0.025}
	}
end

if etc.modules.basic_resources and minetest.settings: get_bool('etc.more_loot_basic_resources', true) then
	dungeon_loot.register {
		{name = 'etcetera:pine_tar', chance = 0.25, count = {2,5}},
		{name = 'etcetera:charcoal', chance = 0.25, count = {3,18}},
		{name = 'etcetera:acid', chance = 0.25, count = {2,5}},
		{name = 'etcetera:algin', chance = 0.25, count = {1,3}},
		{name = 'etcetera:canvas', chance = 0.1, count = {1,2}},
		{name = 'etcetera:canvas_tarred', chance = 0.045},
		{name = 'etcetera:sandpaper_0', chance = 0.1, count = {1,4}},
		{name = 'etcetera:sandpaper_1', chance = 0.035, count = {1,4}, y = {-32768, -100}},
		{name = 'etcetera:sandpaper_2', chance = 0.015, count = {1,6}, y = {-32768, -300}}
	}
end

if etc.modules.gems and minetest.settings: get_bool('etc.more_loot_gems', true) then
	dungeon_loot.register {
		{name = 'etcetera:gem_quartz', chance = 0.25, count = {1,2}},
		{name = 'etcetera:gem_citrine', chance = 0.25, count = {1,2}},
		{name = 'etcetera:gem_rose_quartz', chance = 0.25, count = {1,2}},
		{name = 'etcetera:gem_amethyst', chance = 0.25, count = {1,2}},
		{name = 'etcetera:gem_tanzanite', chance = 0.15, count = {1,2}},
		{name = 'etcetera:gem_red_jasper', chance = 0.15, count = {1,2}},
		{name = 'etcetera:gem_green_jasper', chance = 0.15, count = {1,2}},
		{name = 'etcetera:gem_topaz', chance = 0.15, count = {1,2}},
		{name = 'etcetera:gem_opal', chance = 0.15, count = {1,2}}
	}
end

if minetest.settings: get_bool('etc.more_loot_misc', true) then
	dungeon_loot.register {
		{name = 'default:clay_lump', chance = 0.5, count = {2, 5}},
		{name = 'default:clay_brick', chance = 0.35, count = {1, 4}},
		{name = 'default:paper', chance = 0.4, count = {2, 9}},
		{name = 'default:book', chance = 0.275, count = {1, 15}},
		{name = 'vessels:glass_bottle', chance = 0.3, count = {2, 10}},
		{name = 'default:ladder', chance = 0.4, count = {5, 35}},
		{name = 'default:sign_wall_wood', chance = 0.4, count = {2, 4}},
		{name = 'fireflies:bug_net', chance = 0.1},
		{name = 'map:mapping_kit', chance = 0.01},
		{name = 'binoculars:binoculars', chance = 0.01}
	}
end
