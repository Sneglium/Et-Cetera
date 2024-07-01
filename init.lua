 
etc = {modpath = minetest.get_modpath 'etcetera', modules = {}}

local function load_script (fn)
	dofile(table.concat {etc.modpath, '/scripts/', fn, '.lua'})
end

local function load_script_optional (fn, ...)
	if etc.check_depends(...) and minetest.settings: get_bool('etc.load_module_'..fn, true) then
		etc.modules[fn] = dofile(table.concat {etc.modpath, '/scripts/', fn, '.lua'}) or true
	end
end

load_script 'utils/misc_utils'
load_script 'utils/text_utils'
load_script 'utils/reg_utils'
load_script 'utils/nodebox_utils'
load_script 'utils/entity_utils'

etc.register_node, etc.register_item, etc.register_tool = etc.create_wrappers('etcetera', 'etc')

load_script_optional('basic_resources')
load_script_optional('craft_tools')
load_script_optional('wrought_iron', 'default')
load_script_optional('slime', '&basic_resources')

load_script_optional('labelling_bench')
load_script_optional('coloring_bench')

load_script_optional('mortar_and_pestle', '&basic_resources')
load_script_optional('dust', '&mortar_and_pestle', 'bucket')

load_script_optional('anvil', '&craft_tools')

load_script_optional('chalk', '&craft_tools')

load_script_optional('fluid_bottles', 'default', 'vessels')

load_script_optional('paxels', 'default')

load_script_optional('fall_tweaks', 'default')
