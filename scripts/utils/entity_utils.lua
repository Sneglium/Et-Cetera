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

-- If rotation = 'random_flat', lies flat and has a random Y axis rotation
function etc.add_item_display (pos, item, scale, rotation)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	etc.log.assert(etc.is_itemstack(item), 'Display entity item must be an ItemStack')
	etc.log.assert(etc.is_number(scale), 'Display entity scale must be a number')
	etc.log.assert(etc.is_vector(rotation) or rotation == 'random_flat', 'Display entity rotation must be a vector or the string \'random_flat\'')
	
	local entity = minetest.add_entity(pos, 'etcetera:item_display')
	local properties = entity: get_properties()
	
	properties.wield_item = ItemStack(item): get_name()
	
	if scale then
		properties.visual_size = {x = scale*0.2, y = scale*0.2, z = scale*0.2}
	end
	
	entity: set_properties(properties)
	
	if rotation == 'random_flat' then
		entity: set_rotation({x=math.pi/2, y=math.random()*math.pi*2, z=0})
	elseif rotation ~= nil then
		entity: set_rotation(rotation)
	end
	
	return entity
end

-- If rotation = 'random_flat', lies flat and has a random Y axis rotation
function etc.update_item_display (pos, item, scale, rotation)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	etc.log.assert(etc.is_itemstack(item), 'Display entity item must be an ItemStack')
	etc.log.assert(etc.is_number(scale), 'Display entity scale must be a number')
	etc.log.assert(etc.is_vector(rotation) or rotation == 'random_flat', 'Display entity rotation must be a vector or the string \'random_flat\'')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_item then
			local properties = entity: get_properties()
			
			properties.wield_item = ItemStack(item): get_name()
			
			if scale then
				properties.visual_size = {x = scale*0.2, y = scale*0.2, z = scale*0.2}
			end
			
			entity: set_properties(properties)
			
			if rotation == 'random_flat' then
				entity: set_rotation({x=math.pi/2, y=math.random()*math.pi*2, z=0})
			elseif rotation ~= nil then
				entity: set_rotation(rotation)
			end
		end
	end
end

function etc.remove_item_display (pos)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_item then
			entity: remove()
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
function etc.add_liquid_display (pos, tiles, scale, initial_level)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	etc.log.assert(etc.is_array(tiles), 'Display entity tiles must be an array')
	etc.log.assert(etc.is_number(scale), 'Display entity scale must be a number')
	etc.log.assert(etc.is_number(initial_level), 'Display entity level must be a number')
	
	local level = initial_level or 1
	
	local height = scale * level -- set height to level% of the height of the object
	local offset = -(scale*0.5)+(height*0.5) -- move the entity down half its' max height, then up half its' current height
	
	local entity = minetest.add_entity(vector.add(pos, vector.new(0, offset, 0)), 'etcetera:liquid_display')
	
	local properties = entity: get_properties()
	properties.textures = tiles
	
	properties.visual_size = {x = scale, y = height, z = scale}
	
	entity: set_properties(properties)
	
	local luaentity = entity: get_luaentity()
	luaentity._scale = scale
	luaentity._basepos = pos
	
	return entity
end

function etc.update_liquid_display (pos, level)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	etc.log.assert(etc.is_number(initial_level), 'Display entity level must be a number')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, entity in pairs(objects) do
		local luaentity = entity: get_luaentity()
		if luaentity and luaentity._etc_display_liquid then
			local properties = entity: get_properties()
			local level = level or 1
			local scale = luaentity._scale
	
			local height = scale * level
			local offset = -(scale*0.5)+(height*0.5)
			
			properties.visual_size = {x = scale, y = height, z = scale}
			
			entity: set_properties(properties)
			
			entity: set_pos(vector.add(luaentity._basepos, vector.new(0, offset, 0)))
		end
	end
end

function etc.remove_liquid_display (pos)
	etc.log.assert(etc.is_vector(pos), 'Display entity position must be a vector')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_liquid then
			entity: remove()
		end
	end
end
