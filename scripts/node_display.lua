
-- An entity for displaying a node-like object
-- mainly for showing liquids filling containers and so on
minetest.register_entity('etcetera:node_display', {
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
	
	_etc_display_node = true,
	_scale = 1
})

 -- scales and positions the side textures such that the bottom edge of the texture is aligned with the bottom
 -- of the display entity and pixel aspect ratio is preserved
local function get_levelled_tiles (tiles, level)
	if level == 1 then return tiles end
	
	local sixteenths = math.ceil(16 * level)
	
	for i = 3, 6 do
		tiles[i] = table.concat {
			'[combine:16x',
			tostring(sixteenths),
			':0,', tostring(level > 0.9 and 0 or -(16-sixteenths)), '=', tiles[i]
		}
	end
	
	return tiles
end

-- add an axis-aligned node display entity at <pos>
-- initial_level should range from 0-1; sets the node height
-- be aware the entity will move down relative to <pos> depending on the level
-- only really works with 16x tiles for anything other than level = 1
function etc.add_node_display (pos, tiles, scale, initial_level)
	etc.log.assert(etc.is_vector(pos), 'Node display entity position must be a vector')
	etc.log.assert(etc.is_string(tiles) or etc.is_array(tiles), 'Node display entity tiles must be an array or a single string')
	etc.log.assert(etc.is_number(scale), 'Node display entity scale must be a number')
	etc.log.assert(not initial_level or etc.is_number(initial_level), 'Node display entity level must be a number')
	
	local level = initial_level and math.max(0.0001, initial_level) or 1
	
	local height = scale * level -- set height to level% of the height of the object
	local offset = -(scale*0.5)+(height*0.5) -- move the entity down half its' max height, then up half its' current height
	
	local entity = minetest.add_entity(vector.add(pos, vector.new(0, offset, 0)), 'etcetera:node_display')
	
	local properties = entity: get_properties()
	
	if type(tiles) == 'string' then
		tiles = {tiles, tiles, tiles, tiles, tiles, tiles}
	end
	properties.textures = get_levelled_tiles(tiles, level)
	
	properties.visual_size = {x = scale, y = height, z = scale}
	
	entity: set_properties(properties)
	
	local luaentity = entity: get_luaentity()
	luaentity._scale = scale
	luaentity._basepos = pos
	
	etc.log.verbose('Added node display entity at ', tostring(pos))
	
	return entity
end

function etc.update_node_display (pos, level, tiles)
	etc.log.assert(etc.is_vector(pos), 'Node display entity position must be a vector')
	etc.log.assert(etc.is_number(level), 'Node display entity level must be a number')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	local found_one = false
	for _, entity in pairs(objects) do
		local luaentity = entity: get_luaentity()
		if luaentity and luaentity._etc_display_node then
			local properties = entity: get_properties()
			local level = level and math.max(0.0001, level) or 1
			local scale = luaentity._scale
	
			local height = scale * level
			local offset = -(scale*0.5)+(height*0.5)
			
			if tiles then
				if type(tiles) == 'string' then
					tiles = {tiles, tiles, tiles, tiles, tiles, tiles}
				end
				properties.textures = get_levelled_tiles(tiles, level)
			end
			
			properties.visual_size = {x = scale, y = height, z = scale}
			
			entity: set_properties(properties)
			
			entity: set_pos(vector.add(luaentity._basepos, vector.new(0, offset, 0)))
			found_one = true
		end
	end
	
	etc.log.verbose('Updated node display entity at ', tostring(pos))
	
	return found_one
end

function etc.remove_node_display (pos)
	etc.log.assert(etc.is_vector(pos), 'Node display entity position must be a vector')
	
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, entity in pairs(objects) do
		if entity: get_luaentity() and entity: get_luaentity()._etc_display_node then
			entity: remove()
		end
	end
	
	etc.log.verbose('Removed node display entity at ', tostring(pos))
end
