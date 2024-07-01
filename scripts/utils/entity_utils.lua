-- DISPLAY ENTITY FUNCTIONS
-- These are intended to be used as if targeting a world position rather than an existing entity because entities do not have IDs,
-- and because displays are transitive (not saved on unload).

-- An entity for displaying items in the world

minetest.register_entity('etcetera:item_display', {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		pointable = false,
		visual = 'wielditem',
		wield_item = '',
		visual_size = {x = 0.2, y = 0.2, z = 0.2},
		is_visible = true,
		static_save = false,
		damage_texture_modifier = ''
	},
	_etc_display_item = true
})

-- If 'laid' is true, lies flat and has a random horizontal rotation
function etc.add_display_entity (pos, item, scale, laid)
	local ent = minetest.add_entity(pos, 'etcetera:item_display')
	local prop = ent: get_properties()
	prop.wield_item = ItemStack(item): get_name()
	if scale then
		prop.visual_size = {x = scale*0.2, y = scale*0.2, z = scale*0.2}
	end
	ent: set_properties(prop)
	if laid then ent: set_rotation({x=math.pi/2, y=math.random()*math.pi*2, z=0}) end
end

-- If 'laid' is true, lies flat and has a random horizontal rotation
function etc.update_display_entity (pos, item, laid)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	for _, ent in pairs(objs) do
		if ent: get_luaentity() and ent: get_luaentity()._etc_display_item then
			local prop = ent: get_properties()
			prop.wield_item = ItemStack(item): get_name()
			ent: set_properties(prop)
			if laid then ent: set_rotation({x=math.pi/2, y=math.random()*math.pi*2, z=0}) end
		end
	end
end

function etc.remove_display_entity (pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	for _, ent in pairs(objs) do
		if ent: get_luaentity() and ent: get_luaentity()._etc_display_item then
			ent: remove()
		end
	end
end

minetest.register_entity('etcetera:liquid_display', {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		pointable = false,
		visual = 'cube',
		textures = '',
		use_texture_alpha = true,
		visual_size = {x = 1, y = 1, z = 1},
		is_visible = true,
		static_save = false,
		damage_texture_modifier = ''
	},
	_etc_display_liquid = true,
	_scale = 1
})

-- initial_level should range from 0-1; sets the liquid level
-- Be aware the entity will move down relative to <pos> depending on the level
function etc.add_liquid_entity (pos, tiles, scale, initial_level)
	local level = initial_level or 1
	
	local height = scale * level -- set height to level% of the height of the object
	local offset = -(scale*0.5)+(height*0.5) -- move the entity down half its' max height, then up half its' current height
	
	local ent = minetest.add_entity(vector.add(pos, vector.new(0, offset, 0)), 'etcetera:liquid_display')
	
	local prop = ent: get_properties()
	prop.textures = tiles
	
	prop.visual_size = {x = scale, y = height, z = scale}
	
	ent: set_properties(prop)
	
	local luaent = ent: get_luaentity()
	luaent._scale = scale
	luaent._basepos = pos
end

function etc.update_liquid_entity (pos, level)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	for _, ent in pairs(objs) do
		local luaent = ent: get_luaentity()
		if luaent and luaent._etc_display_liquid then
			local prop = ent: get_properties()
			local level = level or 1
			local scale = luaent._scale
	
			local height = scale * level
			local offset = -(scale*0.5)+(height*0.5)
			
			prop.visual_size = {x = scale, y = height, z = scale}
			
			ent: set_properties(prop)
			
			ent: set_pos(vector.add(luaent._basepos, vector.new(0, offset, 0)))
		end
	end
end

function etc.remove_liquid_entity (pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	for _, ent in pairs(objs) do
		if ent: get_luaentity() and ent: get_luaentity()._etc_display_liquid then
			ent: remove()
		end
	end
end
