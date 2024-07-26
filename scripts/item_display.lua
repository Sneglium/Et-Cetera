
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
	etc.log.assert(etc.is_vector(pos), 'Item display entity position must be a vector')
	etc.log.assert(etc.is_itemstack(item), 'Item display entity item must be an ItemStack')
	etc.log.assert(not scale or etc.is_number(scale), 'Item display entity scale must be a number')
	etc.log.assert(not rotation or etc.is_vector(rotation) or rotation == 'random_flat', 'Display entity rotation must be a vector or the string \'random_flat\'')
	
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
	
	etc.log.verbose('Added item display entity at ', tostring(pos))
	
	return entity
end

-- If rotation = 'random_flat', lies flat and has a random Y axis rotation
function etc.update_item_display (pos, item, scale, rotation)
	etc.log.assert(etc.is_vector(pos), 'Item display entity position must be a vector')
	etc.log.assert(etc.is_itemstack(item), 'Item display entity item must be an ItemStack')
	etc.log.assert(not scale or etc.is_number(scale), 'Item display entity scale must be a number')
	etc.log.assert(not rotation or etc.is_vector(rotation) or rotation == 'random_flat', 'Display entity rotation must be a vector or the string \'random_flat\'')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	local found_one = false
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_item then
			local properties = entity: get_properties()
			
			properties.wield_item = ItemStack(item): get_name()
			
			if scale then
				properties.visual_size = {x = scale*0.2, y = scale*0.2, z = scale*0.2}
			end
			
			entity: set_properties(properties)
			
			if rotation == 'random_flat' then
				local rot = entity: get_rotation()
				entity: set_rotation({x=rot.x, y=math.random()*math.pi*2, z=rot.z})
			elseif rotation ~= nil then
				entity: set_rotation(rotation)
			end
			
			found_one = true
		end
	end
	
	etc.log.verbose('Updated item display entity at ', tostring(pos))
	
	return found_one
end

function etc.remove_item_display (pos)
	etc.log.assert(etc.is_vector(pos), 'Item display entity position must be a vector')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_item then
			entity: remove()
		end
	end
	
	etc.log.verbose('Removed item display entity at ', tostring(pos))
end
