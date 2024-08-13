
local treated = minetest.settings: get_bool('etc.wood_variants_treated', true)

if treated then
	if stairs then
		stairs.register_stair_and_slab(
			'etcetera_tarred_wood',
			'etcetera:tarred_wood',
			{cracky=3},
			{'etc_tarred_wood.png'},
			etc.gettext 'Treated Wood Stairs',
			etc.gettext 'Treated Wood Slab',
			default.node_sound_wood_defaults(),
			false,
			etc.gettext 'Treated Wood Stairs (Inner Corner)',
			etc.gettext 'Treated Wood Stairs (Outer Corner)'
		)
		
		stairs.register_stair_and_slab(
			'etcetera_pitched_wood',
			'etcetera:pitched_wood',
			{cracky=3},
			{'etc_pitched_wood.png'},
			etc.gettext 'Pitch-Sealed Wood Stairs',
			etc.gettext 'Pitch-Sealed Wood Slab',
			default.node_sound_wood_defaults(),
			false,
			etc.gettext 'Pitch-Sealed Wood Stairs (Inner Corner)',
			etc.gettext 'Pitch-Sealed Wood Stairs (Outer Corner)'
		)
	end
	
	default.register_fence('etcetera:fence_treated_wood', {
		description = etc.gettext 'Treated Wood Fence',
		texture = 'etc_fence_tarred.png',
		inventory_image = 'default_fence_overlay.png^etc_tarred_wood.png^' ..
					'default_fence_overlay.png^[makealpha:255,126,126',
		wield_image = 'default_fence_overlay.png^etc_tarred_wood.png^' ..
					'default_fence_overlay.png^[makealpha:255,126,126',
		material = 'etcetera:tarred_wood',
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
	
	default.register_fence_rail('etcetera:fence_rail_treated_wood', {
		description = etc.gettext 'Treated Wood Fence Rail',
		texture = 'etc_fence_rail_tarred.png',
		inventory_image = 'default_fence_rail_overlay.png^etc_tarred_wood.png^' ..
					'default_fence_rail_overlay.png^[makealpha:255,126,126',
		wield_image = 'default_fence_rail_overlay.png^etc_tarred_wood.png^' ..
					'default_fence_rail_overlay.png^[makealpha:255,126,126',
		material = 'etcetera:tarred_wood',
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
	
	default.register_fence('etcetera:fence_pitched_wood', {
		description = etc.gettext 'Pitch-Sealed Wood Fence',
		texture = 'etc_fence_pitched.png',
		inventory_image = 'default_fence_overlay.png^etc_pitched_wood.png^' ..
					'default_fence_overlay.png^[makealpha:255,126,126',
		wield_image = 'default_fence_overlay.png^etc_pitched_wood.png^' ..
					'default_fence_overlay.png^[makealpha:255,126,126',
		material = 'etcetera:pitched_wood',
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
	
	default.register_fence_rail('etcetera:fence_rail_pitched_wood', {
		description = etc.gettext 'Pitch-Sealed Wood Fence Rail',
		texture = 'etc_fence_rail_pitched.png',
		inventory_image = 'default_fence_rail_overlay.png^etc_pitched_wood.png^' ..
					'default_fence_rail_overlay.png^[makealpha:255,126,126',
		wield_image = 'default_fence_rail_overlay.png^etc_pitched_wood.png^' ..
					'default_fence_rail_overlay.png^[makealpha:255,126,126',
		material = 'etcetera:pitched_wood',
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
	
	default.register_mesepost('etcetera:mese_post_light_tarred', {
		description = etc.gettext 'Treated Wood Mese Post Light',
		texture = 'etc_fence_tarred.png',
		material = 'etcetera:tarred_wood',
	})

	default.register_mesepost('etcetera:mese_post_light_pitched', {
		description = etc.gettext 'Pitch-Sealed Wood Mese Post Light',
		texture = 'etc_fence_pitched.png',
		material = 'etcetera:pitched_wood',
	})
	
	if doors then
		doors.register_fencegate('etcetera:fence_gate_treated_wood', {
			description = etc.gettext 'Treated Wood Fence Gate',
			texture = 'etc_tarred_wood.png',
			material = 'etcetera:tarred_wood',
			groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
		})
		
		doors.register_fencegate('etcetera:fence_gate_pitched_wood', {
			description = etc.gettext 'Pitch-Sealed Wood Fence Gate',
			texture = 'etc_pitched_wood.png',
			material = 'etcetera:pitched_wood',
			groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
		})
	end
end

local function make_bookshelf (name, reg_modname, displayname)
	local def = table.copy(minetest.registered_nodes['default:bookshelf'])
	
	local nodename = name .. '_bookshelf'
	
	def.description = nil
	def.displayname = displayname .. ' Bookshelf'
	
	local front_tex = 'default_bookshelf.png^('..reg_modname..'_'..name..'.png^[mask:etc_shelf_mask.png)'
	def.tiles = {reg_modname .. '_'..name..'.png', reg_modname .. '_'..name..'.png', reg_modname .. '_'..name..'.png',
	reg_modname .. '_'..name..'.png', front_tex, front_tex}
	
	def.on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, 'books', drops)
		drops[#drops+1] = 'etcetera:' .. nodename
		minetest.remove_node(pos)
		return drops
	end
	
	etc: register_node(nodename, def)
	
	minetest.register_craft {
		output = nodename,
		recipe = {
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name},
			{'default:book', 'default:book', 'default:book'},
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name}
		}
	}
end

local function make_vessel_shelf (name, reg_modname, displayname)
	local def = table.copy(minetest.registered_nodes['vessels:shelf'])
	
	local nodename = name .. '_vessels_shelf'
	
	def.description = nil
	def.displayname = displayname .. ' Vessels Shelf'
	
	local front_tex = 'vessels_shelf.png^('..reg_modname..'_'..name..'.png^[mask:etc_shelf_mask.png)'
	def.tiles = {reg_modname .. '_'..name..'.png', reg_modname .. '_'..name..'.png', reg_modname .. '_'..name..'.png',
	reg_modname .. '_'..name..'.png', front_tex, front_tex}
	
	def.on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, 'vessels', drops)
		drops[#drops+1] = 'etcetera:' .. nodename
		minetest.remove_node(pos)
		return drops
	end
	
	etc: register_node(nodename, def)
	
	minetest.register_craft {
		output = nodename,
		recipe = {
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name},
			{'group:vessel', 'group:vessel', 'group:vessel'},
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name}
		}
	}
end

if minetest.settings: get_bool('etc.wood_variants_shelves', true) then
	make_bookshelf('acacia_wood', 'default', 'Acacia Wood')
	make_bookshelf('aspen_wood', 'default', 'Aspen Wood')
	make_bookshelf('junglewood', 'default', 'Junglewood')
	make_bookshelf('pine_wood', 'default', 'Pine Wood')
	
	if treated then
		make_bookshelf('tarred_wood', 'etc', 'Treated Wood')
		make_bookshelf('pitched_wood', 'etc', 'Pitch-Sealed Wood')
	end
	
	minetest.override_item('default:bookshelf', {
		description = etc.gettext 'Applewood Bookshelf'
	})
	
	if minetest.get_modpath 'vessels' then
		make_vessel_shelf('acacia_wood', 'default', 'Acacia Wood')
		make_vessel_shelf('aspen_wood', 'default', 'Aspen Wood')
		make_vessel_shelf('junglewood', 'default', 'Junglewood')
		make_vessel_shelf('pine_wood', 'default', 'Pine Wood')
		
		if treated then
			make_vessel_shelf('tarred_wood', 'etc', 'Treated Wood')
			make_vessel_shelf('pitched_wood', 'etc', 'Pitch-Sealed Wood')
		end
		
		minetest.override_item('vessels:shelf', {
			description = etc.gettext 'Applewood Vessels Shelf'
		})
	end
end

local function make_ladder (name, reg_modname, displayname)
	etc: register_node('ladder_'..name, {
		displayname = displayname ..' Ladder',
		drawtype = 'signlike',
		tiles = {'etc_ladder_'..name..'.png'},
		inventory_image = 'etc_ladder_'..name..'.png',
		wield_image = 'etc_ladder_'..name..'.png',
		paramtype = 'light',
		paramtype2 = 'wallmounted',
		sunlight_propagates = true,
		walkable = false,
		climbable = true,
		is_ground_content = false,
		selection_box = {
			type = 'wallmounted',
		},
		groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	})
	
	minetest.register_craft {
		output = 'etcetera:ladder_'..name .. ' 15',
		recipe = {
			{'default:stick', '', 'default:stick'},
			{'default:stick', reg_modname..':'..name, 'default:stick'},
			{'default:stick', '', 'default:stick'}
		}
	}
end

if minetest.settings: get_bool('etc.wood_variants_ladders', true) then
	make_ladder('acacia_wood', 'default', 'Acacia Wood')
	make_ladder('aspen_wood', 'default', 'Aspen Wood')
	make_ladder('junglewood', 'default', 'Junglewood')
	make_ladder('pine_wood', 'default', 'Pine Wood')
	
	if treated then
		make_ladder('tarred_wood', 'etc', 'Treated Wood')
		make_ladder('pitched_wood', 'etc', 'Pitch-Sealed Wood')
	end
	
	minetest.override_item('default:ladder_wood', {
		description = etc.gettext 'Applewood Ladder'
	})
end

local function make_doors (name, reg_modname, displayname)
	doors.register('etcetera:door_'..name, {
		description = etc.gettext(displayname .. ' Door'),
		tiles = {{ name = 'etc_door_'..name..'.png', backface_culling = true }},
		inventory_image = 'etc_door_'..name..'_inv.png',
		groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		gain_open = 0.06,
		gain_close = 0.13,
		recipe = {
			{reg_modname..':'..name, reg_modname..':'..name},
			{reg_modname..':'..name, reg_modname..':'..name},
			{reg_modname..':'..name, reg_modname..':'..name}
		}
	})
	
	doors.register_trapdoor('etcetera:trapdoor_'..name, {
		description = etc.gettext(displayname .. ' Trapdoor'),
		inventory_image = 'etc_trapdoor_'..name..'.png',
		wield_image = 'etc_trapdoor_'..name..'.png',
		tile_front = 'etc_trapdoor_'..name..'.png',
		tile_side = 'etc_trapdoor_'..name..'_side.png',
		gain_open = 0.06,
		gain_close = 0.13,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1},
	})
	
	minetest.register_craft({
		output = 'etcetera:trapdoor_'..name..' 2',
		recipe = {
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name},
			{reg_modname..':'..name, reg_modname..':'..name, reg_modname..':'..name},
			{'', '', ''},
		}
	})
end

if minetest.settings: get_bool('etc.wood_variants_doors', true) and minetest.get_modpath 'doors' then
	make_doors('acacia_wood', 'default', 'Acacia Wood')
	make_doors('aspen_wood', 'default', 'Aspen Wood')
	make_doors('junglewood', 'default', 'Junglewood')
	make_doors('pine_wood', 'default', 'Pine Wood')
	
	if treated then
		make_doors('tarred_wood', 'etc', 'Treated Wood')
		make_doors('pitched_wood', 'etc', 'Pitch-Sealed Wood')
	end
	
	minetest.override_item('doors:door_wood', {
		description = etc.gettext 'Applewood Door'
	})
	
	minetest.override_item('doors:trapdoor', {
		description = etc.gettext 'Applewood Trapdoor'
	})
end
