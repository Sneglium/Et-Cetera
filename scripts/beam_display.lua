
-- An entity for displaying a linear beam between two points
-- For lasers, taut ropes/chains, poles, and such that don't move often
minetest.register_entity('etcetera:beam_display', {
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
	
	_etc_display_beam = true,
	_width = 1,
	_id = 0,
	_tiles = 'empty.png',
	_tile_size = 16
})

local function update_rotation(object, beam_vector)
	object: set_rotation {
		x = math.atan2(beam_vector.y, math.sqrt((beam_vector.z^2)+(beam_vector.x^2))),
		y = -math.atan2(beam_vector.x, beam_vector.z),
		z = 0
	}
end

local function get_horizontal_beam_tex (tile, length, tile_size)
	tiles = {}
	for i = 0, length do
		table.insert(tiles, table.concat {tostring(i * tile_size), ',0=', tile})
	end
	return table.concat {'[combine:', tostring(#tiles * tile_size), 'x', tostring(tile_size), ':', table.concat(tiles, ':')}
end

local function get_vertical_beam_tex (tile, length, tile_size)
	local tiles = {}
	for i = 0, length do
		table.insert(tiles, table.concat {'0,', tostring(i * tile_size), '=', tile})
	end
	return table.concat {'[combine:', tostring(tile_size), 'x', tostring(#tiles * tile_size), ':', table.concat(tiles, ':')}
end

-- Adds a beam between pos1 and pos2 with a specified <width> (in fractions of a node)
-- Tiles can be a table or a string; if a string, the specified texture will be used for all faces
-- each tile must be square to avoid visual artifacts
-- <tile_size> will be used to determine how many tiles are needed for the long sides of a beam with a given length and width, maintaining a square aspect ratio for each tile
-- if <tile_size> is 0, the textures will be stretched instead of tiling along the length of the beam
-- tiles[3] and [4] will tile horizontally, while [1] and [2] will tile vertically (in terms of the texture's initial orientation)
-- <identifier> is an arbitrary value optionally used to specify a particular beam for the update and remove functions
function etc.add_beam_display (pos1, pos2, tiles, tile_size, width, identifier)
	etc.log.assert(etc.is_vector(pos1), 'Beam display entity end positions must be vectors')
	etc.log.assert(etc.is_vector(pos2), 'Beam display entity end positions must be vectors')
	etc.log.assert(etc.is_string(tiles) or etc.is_array(tiles), 'Beam display entity tiles must be an array or a single string')
	etc.log.assert(etc.is_number(tile_size), 'Beam display entity tile scale must be a number')
	etc.log.assert(etc.is_number(width), 'Beam display entity width must be a number')
	
	local identifier = identifier or 0
	local beam_vector = pos2 - pos1
	local beam_center = pos1 + (beam_vector / 2)
	local beam_length = vector.length(beam_vector)
	
	local entity = minetest.add_entity(beam_center, 'etcetera:beam_display')
	update_rotation(entity, beam_vector)
	
	local properties = entity: get_properties()
	
	properties.visual_size = {x = width, y = width, z = beam_length}
	
	local old_tiles = tiles
	if type(tiles) == 'string' then
		tiles = {tiles, tiles, tiles, tiles, tiles, tiles}
	end
	
	if tile_size ~= 0 then
		local texlen = math.floor(beam_length * (1/width))
		
		local tex_vert_1 = get_vertical_beam_tex(tiles[1], texlen, tile_size)
		local tex_vert_2 = get_vertical_beam_tex(tiles[2], texlen, tile_size)
		local tex_hor_1 = get_horizontal_beam_tex(tiles[3], texlen, tile_size)
		local tex_hor_2 = get_horizontal_beam_tex(tiles[4], texlen, tile_size)
		
		tiles = {tex_vert_1, tex_vert_2, tex_hor_1, tex_hor_2, tiles[5], tiles[6]}
	end
	
	properties.textures = tiles
	
	entity: set_properties(properties)
	
	local luaentity = entity: get_luaentity()
	luaentity._width = width
	luaentity._id = identifier
	luaentity._tiles = old_tiles
	luaentity._tile_size = tile_size
	
	etc.log.verbose('Added beam display entity between ', tostring(pos1), tostring(pos2))
	
	return entity
end

-- Change the endpoints and/or the width of any beam entities CURRENTLY between <pos1> and <pos2>
-- If <identifier> is set, only beams with the same identifier value are affected
function etc.update_beam_display (pos1, pos2, pos1_new, pos2_new, width_new, identifier)
	etc.log.assert(etc.is_vector(pos1), 'Beam display entity end positions must be vectors')
	etc.log.assert(etc.is_vector(pos2), 'Beam display entity end positions must be vectors')
	etc.log.assert(pos1_new == nil or etc.is_vector(pos1_new), 'Beam display entity new end positions must be vectors')
	etc.log.assert(pos2_new == nil or etc.is_vector(pos2_new), 'Beam display entity new end positions must be vectors')
	etc.log.assert(width_new == nil or etc.is_number(width_new), 'Beam display entity width must be a number')
	
	local pos1_new = pos1_new or pos1
	local pos2_new = pos2_new or pos2
	
	local identifier = identifier or 0
	local beam_vector = pos2 - pos1
	local beam_center = pos1 + (beam_vector / 2)
	
	local objects = minetest.get_objects_inside_radius(beam_center, 0.5)
	local found_one = false
	for _, entity in pairs(objects) do
		local luaent = entity: get_luaentity()
		if luaent
		and luaent._etc_display_beam
		and luaent._id == identifier or luaent._id == nil then
			
			local width_new = width_new or luaent._width or 1
			local beam_vector_new = pos2_new - pos1_new
			local beam_center_new = pos1_new + (beam_vector_new / 2)
			local beam_length_new = vector.length(beam_vector_new)
			
			update_rotation(entity, beam_vector_new)
			
			local properties = entity: get_properties()
			
			local tiles = luaent._tiles
			if type(tiles) == 'string' then
				tiles = {tiles, tiles, tiles, tiles, tiles, tiles}
			end
			
			if tile_size ~= 0 then
				local texlen = math.floor(beam_length_new * (1/width_new))
				local tile_size = luaent._tile_size
				
				local tex_vert_1 = get_vertical_beam_tex(tiles[1], texlen, tile_size)
				local tex_vert_2 = get_vertical_beam_tex(tiles[2], texlen, tile_size)
				local tex_hor_1 = get_horizontal_beam_tex(tiles[3], texlen, tile_size)
				local tex_hor_2 = get_horizontal_beam_tex(tiles[4], texlen, tile_size)
				
				tiles = {tex_vert_1, tex_vert_2, tex_hor_1, tex_hor_2, tiles[5], tiles[6]}
			end
			
			properties.textures = tiles
			
			properties.visual_size = {x = width_new, y = width_new, z = beam_length_new}
			
			entity: set_properties(properties)
			
			local luaentity = entity: get_luaentity()
			luaentity._width = width_new
			
			found_one = true
		end
	end
	
	etc.log.verbose('Updated beam display entity between ', tostring(pos1), tostring(pos2))
	
	return found_one
end

-- Remove any beam entities CURRENTLY between <pos1> and <pos2>
-- If <identifier> is set, only beams with the same identifier value are affected
function etc.remove_beam_display (pos1, pos2, identifier)
	etc.log.assert(etc.is_vector(pos1), 'Beam display entity end positions must be vectors')
	etc.log.assert(etc.is_vector(pos2), 'Beam display entity end positions must be vectors')
	
	local identifier = identifier or 0
	local beam_vector = pos2 - pos1
	local beam_center = pos1 + (beam_vector / 2)
	
	local objects = minetest.get_objects_inside_radius(beam_center, 0.5)
	for _, entity in pairs(objects) do
		local luaent = entity: get_luaentity()
		if luaent
		and luaent._etc_display_beam
		and luaent._id == identifier or luaent._id == nil then
			entity: remove()
		end
	end
	
	etc.log.verbose('Removed beam display entity between ', tostring(pos1), tostring(pos2))
end
