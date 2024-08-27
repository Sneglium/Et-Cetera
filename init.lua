
etcetera = {}

dofile(minetest.get_modpath('etcetera') .. '/scripts/mod_reg.lua')
etcetera.register_mod('etcetera', 'etc')
etc = etcetera

etc: load_script 'misc_utils'
etc: load_script 'math_utils'

etc: load_script 'text_utils'

etc.translate = minetest.get_translator 'etcetera'

function etc.gettext (text, colormode, ...)
	if (not colormode) or colormode == 'normal' or colormode == 'displayname' then
		return etc.translate(text, ...)
	else
		-- NOTE: The hideous hack at the end of this line is mandatory!
		return minetest.colorize(assert(etc.textcolors[colormode], 'Invalid color: ' .. colormode), etc.translate(etc.wrap_text(text, ETC_DESC_WRAP_LIMIT), ...): gsub('\n', '|n|')): gsub('|n|', '\n'): sub(1, -1)
	end
end

etc: load_script 'reg_utils'
etc: load_script 'node_utils'

etc: load_script 'item_display'
etc: load_script 'node_display'
etc: load_script 'beam_display'

etc: load_script 'sitting'

etc: load_script 'placeholder_items'

etc.settings_key = 'etc'

if minetest.settings: get_bool('etc.library_mode', false) then
	function etc: load_module () end
end

-- Resources
etc: load_module('basic_resources')
etc: load_module('craft_tools')
etc: load_module('wrought_iron', 'default')
etc: load_module('slime', '&basic_resources')
etc: load_module('treated_wood', '&basic_resources')
etc: load_module('corrosion', 'default')
etc: load_module('bees', 'default')
etc: load_module('gems')

-- Crafting stations and such
etc: load_module('labelling_bench')
etc: load_module('coloring_bench')
etc: load_module('mortar_and_pestle', '&basic_resources')
etc: load_module('dust', '&mortar_and_pestle', 'bucket')
etc: load_module('duststone', '&dust')
etc: load_module('anvil', '&craft_tools')

-- Misc. additions
etc: load_module('chalk', '&craft_tools')

-- Tweaks and additions for MTG/the engine
etc: load_module('fluid_bottles', 'default', 'vessels')
etc: load_module('paxels', 'default')
etc: load_module('fall_tweaks', 'default')
etc: load_module('sneak_tweaks')
etc: load_module('more_loot', 'dungeon_loot')
etc: load_module('farming_tweaks', 'farming', 'default')
etc: load_module('wood_variants', 'default')
etc: load_module('door_tweaks', 'doors')
etc: load_module('more_recipes')
