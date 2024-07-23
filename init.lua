
etc = {modpath = minetest.get_modpath 'etcetera', modules = {}}

local function load_script (fn)
	dofile(table.concat {etc.modpath, '/scripts/', fn, '.lua'})
end

local load_script_optional
if minetest.settings: get_bool('etc.library_mode', false) then
	function load_script_optional() end
else
	function load_script_optional (fn, ...)
		if etc.check_depends(...) and minetest.settings: get_bool('etc.load_module_'..fn, true) then
			etc.modules[fn] = dofile(table.concat {etc.modpath, '/scripts/modules/', fn, '.lua'}) or true
			etc[fn] = etc.modules[fn]
		end
	end
end

load_script 'misc_utils'
load_script 'math_utils'

load_script 'text_utils'
load_script 'reg_utils'
load_script 'node_utils'

load_script 'item_display'
load_script 'node_display'
load_script 'beam_display'

etc.register_node, etc.register_item, etc.register_tool = etc.create_wrappers('etcetera', 'etc')

-- Resources
load_script_optional('basic_resources')
load_script_optional('craft_tools')
load_script_optional('wrought_iron', 'default')
load_script_optional('slime', '&basic_resources')
load_script_optional('treated_wood', '&basic_resources')
load_script_optional('corrosion', 'default')
load_script_optional('bees', 'default')
load_script_optional('gems')

-- Crafting stations and such
load_script_optional('labelling_bench')
load_script_optional('coloring_bench')
load_script_optional('mortar_and_pestle', '&basic_resources')
load_script_optional('dust', '&mortar_and_pestle', 'bucket')
load_script_optional('duststone', '&dust')
load_script_optional('anvil', '&craft_tools')

-- Misc. additions
load_script_optional('chalk', '&craft_tools')

-- Tweaks and additions for MTG/the engine
load_script_optional('fluid_bottles', 'default', 'vessels')
load_script_optional('paxels', 'default')
load_script_optional('fall_tweaks', 'default')
load_script_optional('sneak_tweaks')
load_script_optional('more_loot', 'dungeon_loot')
load_script_optional('farming_tweaks', 'farming', 'default')
load_script_optional('wood_variants', 'default')
load_script_optional('door_tweaks', 'doors')
