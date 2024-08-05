
local cubes_only = minetest.settings: get_bool('etc.chalk_cubes_only', true)
local hard_only = minetest.settings: get_bool('etc.chalk_hard_only', true)

local function is_valid_drawing_node (name)
	local def = minetest.registered_nodes[name]
	
	if not def then
		return false
	end
	
	if cubes_only then
		if def.drawtype and def.drawtype ~= 'normal' then
			return false
		end
	end
	
	if hard_only then
		if (not def.groups) or (def.groups.cracky or 0) + (def.groups.choppy or 0) == 0 then
			return false
		end
	end
	
	return true
end

local free_switching = minetest.settings: get_bool('etc.chalk_free_switching', true)
local uses = minetest.settings: get('etc.chalk_num_uses') or 100

local symbolmap = {
	'etc_chalk_symbol_arrow.png',
	'etc_chalk_symbol_arrow.png^[transformR270',
	'etc_chalk_symbol_arrow.png^[transformR180',
	'etc_chalk_symbol_arrow.png^[transformR90',
	'etc_chalk_symbol_cross.png',
	'etc_chalk_symbol_circle.png'
}

local function chalk_on_use (colorname)
	return function (itemstack, user, pointed_thing)
		local nodename = minetest.get_node(pointed_thing.under).name
		if nodename: sub(1, 22+#colorname) == 'etcetera:chalk_symbol_'..colorname then
			local symbol_index = tonumber(nodename: sub(-1,-1)) + 1
			
			if symbol_index > #symbolmap then
				symbol_index = 1
			end
			
			minetest.item_place_node(ItemStack('etcetera:chalk_symbol_'..colorname..'_'..symbol_index), user, pointed_thing)
			
			if not free_switching then
				local wear = itemstack: get_wear() + math.ceil(65535/uses)
				if wear >= 65535 then
					minetest.sound_play('default_tool_breaks', {to_player = user: get_player_name(), gain = 0.5}, true)
					return ItemStack()
				end
				itemstack: set_wear(wear)
				return itemstack
			end
		elseif nodename: sub(1, 21) == 'etcetera:chalk_symbol' or is_valid_drawing_node(nodename) then
			minetest.item_place_node(ItemStack('etcetera:chalk_symbol_'..colorname..'_1'), user, pointed_thing)
			local wear = itemstack: get_wear() + math.ceil(65535/uses)
			if wear >= 65535 then
				minetest.sound_play('default_tool_breaks', {to_player = user: get_player_name(), gain = 0.5}, true)
				return ItemStack()
			end
			itemstack: set_wear(wear)
			return itemstack
		end
	end
end

local colormap = {
	red = 'colorize:#ff6e5490',
	orange = 'colorize:#ffa94690',
	yellow = 'colorize:#ffbf2a90',
	green = 'colorize:#60d05a90',
	blue = 'colorize:#6f9aff90',
	violet = 'colorize:#d174ff90',
	white = 'colorize:#e1e6d690'
}

local function make_chalk (colorname, color, displayname, item_overlay)
	local color_name = colorname: sub(1,1): upper() .. colorname: sub(2,-1)
	
	etc: register_tool('chalk_' .. colorname, {
		displayname = displayname or color_name .. ' Chalk',
		description = 'Used to draw symbols on hard nodes.' .. (free_switching and ' Redrawing a symbol of the same color will not use durability.' or ''),
		stats = '<LMB> to draw a symbol',
		inventory_image = 'etc_chalk.png^['..color..(item_overlay and '^'..item_overlay or ''),
		on_use = chalk_on_use(colorname, color),
		groups = {no_repair = 1}
	})
	
	for i = 1, #symbolmap do
		etc: register_node('chalk_symbol_'..colorname..'_'..i, {
			tiles = {symbolmap[i]..'^['..color},
			use_texture_alpha = 'blend',
			drawtype = 'signlike',
			paramtype = 'light',
			sunlight_propagates = true,
			paramtype2 = 'wallmounted',
			wallmounted_rotate_vertical = true,
			groups = {dig_immediate = 3, not_in_creative_inventory = 1, attached_node = 1},
			walkable = false,
			buildable_to = true,
			drop = '',
			selection_box = {
				type = 'fixed',
				fixed = {0.5, -7/16, 0.5, -0.5, -0.5, -0.5}
			}
		})
	end
end

for colorname, color in pairs(colormap) do
	make_chalk(colorname, color)
	
	if default and minetest.get_modpath 'dye' then
		minetest.register_craft {
			type = 'shapeless',
			output = 'etc:chalk_'..colorname,
			recipe = {'etc:ct_hammer', 'default:coral_skeleton', 'dye:'..colorname}
		}
	end
	
	if etc.modules.dust and minetest.get_modpath 'dye' then
		minetest.register_craft {
			type = 'shapeless',
			output = 'etc:chalk_'..colorname,
			recipe = {'etc:ct_hammer', 'etc:dust', 'dye:'..colorname}
		}
	end
end

make_chalk('black', 'multiply:#060708', 'Pressed Charcoal Stick', 'etc_chalk_shine.png')

minetest.register_craft {
	type = 'shapeless',
	output = 'etc:chalk_black',
	recipe = {'etc:ct_hammer', 'etc:charcoal', 'etc:charcoal', 'etc:charcoal'}
}
