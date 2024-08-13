-- MISC. PLACEHOLDERS
-- These are mostly for cases when a method or procedure asks for a function as its' argument,
-- and you only need it to do something very simple (or nothing)

-- Does nothing
function etc.NOP () end

-- Returns its' input(s)
function etc.ID (...) return ... end

-- Reverses its' inputs
function etc.INV (a, b) return b, a end

-- MODULE & MOD MANAGEMENT

-- Tests for various kinds of dependency condition and returns true if all are satisfied.
-- Each argument should be a string with one of the following formats:
-- <modname>: Fail if the mod named <modname> is not loaded.
-- $<var>: Fail if the GLOBAL variable <var> is nil or false.
-- @<mod:resource>: Fail if no node or item with the name <mod:resource> is registered. Aliases supported.
-- &<module>: Fail if the Et Cetera module <module> is missing or did not load.
-- Upon failure, the key that failed to resolve will be returned.
function etc.check_depends (...)
	for _, depend in pairs {...} do
		local first_char = depend: sub(1,1)
		local key = depend: sub(2,-1)
		
		if first_char == '$' then
			if not rawget(_G, key) then return false, depend end
		elseif first_char == '@' then
			if not minetest.registered_items[key] or minetest.registered_aliases[key] then return false, depend end
		elseif first_char == '&' then
			if not etc.modules[key] then return false, depend end
		else
			if not minetest.get_modpath(depend) then return false, depend end
		end
	end
	return true
end

-- TABLE HELPERS
-- General stuff for manipulating tables

-- Converts a table with multiple dimensions into a flat array while preserving apparent order of bottom-level elements
-- Bottom-level elements may not be tables (since they would be counted as an additional dimension)
-- The table's dimensions do not need to be the same size (the table can actually be any tree)
function etc.flatten (table)
	local array = {}
	
	for i = 1, #table do
		local element = table[i]
		
		if type(element) == 'table' then
			local new_element = etc.flatten(element)
			for j = 1, #new_element do
				local sub_element = new_element[j]
				table.insert(array, sub_element)
			end
		else
			table.insert(array, element)
		end
	end
	
	return array
end

-- Merges any number of tables together, with keys present in later tables overriding keys from previous tables
function etc.merge (table_a, ...)
	local new_table = table.copy(table_a)
	
	for _, curr_table in ipairs {...} do
		for k, v in pairs(curr_table) do
			new_table[k] = v
		end
	end
	
	return new_table
end

-- Merges any number of tables together, with keys present in later tables overriding keys from previous tables
-- also merges sub-tables, does not check for circular definitions
function etc.merge_recursive (table_a, ...)
	local new_table = table.copy(table_a)
	
	for _, curr_table in ipairs {...} do
		for k, v in pairs(curr_table) do
			new_table[k] = type(new_table[k]) == 'table' and type(v) == 'table' and etc.merge_recursive(new_table[k], v) or v
		end
	end
	
	return new_table
end

-- Finds the index of an entry in an array
-- Also returns the object at the index for convenience
function etc.array_find (array, data)
	for i = 1, #array do
		local v = array[i]
		if v == data then return i, v end
	end
	
	return nil
end

-- TYPE & ERROR HELPERS

-- Table that holds the various log functions
-- Each correspond to a built-in MT error level except fatal and assert
-- Can also be called directly; equivalent to etc.log.info
etc.log = {}

-- Log an error properly, then throw a plain Lua error
function etc.log.fatal (msg, code_add)
	minetest.log('error', table.concat {'<', minetest.get_current_modname() or '@active', '/FATAL> ', msg})
	error(msg, code_add and code_add + 2 or 2)
end

-- Same as the above, but only errors if a condition is not met
function etc.log.assert (cond, msg)
	if not cond then
		etc.log.fatal(msg, 1)
	end
	
	return cond
end

function etc.log.error (...)
	minetest.log('error', table.concat {'<', minetest.get_current_modname() or '@active', '> ', ...})
end

function etc.log.warn (...)
	minetest.log('warning', table.concat {'<', minetest.get_current_modname() or '@active', '> ', ...})
end

function etc.log.info (...)
	minetest.log('info', table.concat {'<', minetest.get_current_modname() or '@active', '> ', ...})
end

function etc.log.action (...)
	minetest.log('action', table.concat {'<', minetest.get_current_modname() or '@active', '> ', ...})
end

function etc.log.verbose (...)
	minetest.log('verbose', table.concat {'<', minetest.get_current_modname() or '@active', '> ', ...})
end

etc.log = setmetatable(etc.log, {__call = function (self, ...) self.info(...) end})

-- Simple verification functions
-- Useful for passing to methods that require a verifier

function etc.is_number (...)
	if select('#', ...) == 1 and type(...) == 'number' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'number' then return false end
	end
	
	return true
end

function etc.is_integer (...)
	if select('#', ...) == 1 and type(...) == 'number' and math.abs(...) == (...)  then return true end
	
	for i = 1, select('#', ...) do
		local n = select(i, ...)
		if type(n) ~= 'number' or math.floor(n) ~= n then return false end
	end
	
	return true
end

function etc.is_string (...)
	if select('#', ...) == 1 and type(...) == 'string' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'string' then return false end
	end
	
	return true
end

function etc.is_bool (...)
	if select('#', ...) == 1 and type(...) == 'boolean' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'boolean' then return false end
	end
	
	return true
end

function etc.is_table (...)
	if select('#', ...) == 1 and type(...) == 'table' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'table' then return false end
	end
	
	return true
end

function etc.is_function (...)
	if select('#', ...) == 1 and type(...) == 'function' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'function' then return false end
	end
	
	return true
end

-- Advanced Verification functions

-- Ensures all the keys in a table are strings
function etc.is_dict (table)
	for key, _ in pairs(table) do
		if type(key) ~= 'string' then return false end
	end
	
	return true
end

-- Ensures all the keys in a table are numbers
-- Does NOT check if they are continuous, so not properly a mathematical array
function etc.is_array (table)
	for key, _ in pairs(table) do
		if type(key) ~= 'number' or math.floor(key) ~= key then return false end
	end
	
	return true
end

-- Ensures all the passed arguments are vectors with metatables
function etc.is_vector (...)
	if select('#', ...) == 1 and vector.check(...) then return true end
	
	for i = 1, select('#', ...) do
		if not vector.check(select(i, ...)) then return false end
	end
	
	return true
end

local function single_is_itemstack (v)
	return ItemStack(v) == v
end

-- Ensures all the passed arguments are itemstack objects
function etc.is_itemstack (...)
	if select('#', ...) == 1 and single_is_itemstack(...) then return true end
	
	for i = 1, select('#', ...) do
		if not single_is_itemstack(select(i, ...)) then return false end
	end
	
	return true
end

local function single_is_itemstring (v)
	return minetest.registered_items[ItemStack(v): get_name()] ~= nil
end

-- Ensures all the passed arguments are valid strings representing registered items
function etc.is_itemstring (...)
	if select('#', ...) == 1 and single_is_itemstring(...) then return true end
	
	for i = 1, select('#', ...) do
		if not single_is_itemstring(select(i, ...)) then return false end
	end
	
	return true
end

-- Recursively tests if all the fields in a table match the types required in the template.
-- Give the template with the exact structure of the table to test, where each non-table value is replaced by the type it should be as a string.
-- Types prepended with a ? (e.g. '?boolean') are optional, but will still fail if a wrong type is supplied (other than nil).
-- Does not test for keys not present in the template, arbitrary keys are allowed.
-- Returns a boolean for successful match; if false, secondarily returns the non-matching "key path" ('table.<key>.<key>...') as a string.
-- Set <parent> to change the name of the root table in the error key path
function etc.validate_table_struc (table, template, parent)
	parent = parent and (parent .. '.') or 'table.'
	if type(table) ~= 'table' then return false, parent end
	
	for k, v in pairs(template) do
		if type(v) == 'table' then
			if type(table[k]) == 'table' then
				local success, code = etc.validate_table_struc(table[k], v, parent .. tostring(k) .. '.')
				if not success then
					return false, code
				end
			else
				return false, parent .. tostring(k)
			end
		else
			if v: sub(1,1) == '?' then
				if v: sub(2, -1) ~= type(table[k]) and table[k] ~= nil then
					return false, parent .. tostring(k)
				end
			else
				if v ~= type(table[k]) then
					return false, parent .. tostring(k)
				end
			end
		end
	end
	
	return true, ''
end

-- GENERAL HELPERS

-- Returns an array of itemstacks resultant from dividing the input stack by the item's max stack size
function etc.split_oversized_stack (item)
	local count, stack_max = item: get_count(), item: get_stack_max()
	if count <= stack_max then return {item} end
	
	local stacks = {}
	local stacks_needed = math.floor(count / stack_max)
	local remainder = count - (stacks_needed * stack_max)
	
	for i = 1, stacks_needed do
		local new_stack = ItemStack(item)
		new_stack: set_count(stack_max)
		table.insert(stacks, new_stack)
	end
	
	local final_stack = ItemStack(item)
	final_stack: set_count(remainder)
	table.insert(stacks, final_stack)
	
	return stacks
end

-- Tries to give an item to a player, and drops it on the ground if unable
-- Oversized stacks will be split up into correctly sized ones
function etc.give_or_drop (player, pos, give_item)
	etc.log.assert(pos == nil or etc.is_vector(pos), 'Item position must be a vector')
	etc.log.assert(etc.is_itemstack(give_item), 'Item must be an ItemStack')
	
	pos = pos or player: get_pos() + vector.new(0, 1.5, 0) + player: get_look_dir()
	
	local inv = player: get_inventory()
	
	local itemstacks = etc.split_oversized_stack(give_item)
	
	for _, item in pairs(itemstacks) do
		if inv: get_stack('main', player:get_wield_index()): is_empty() then
			inv: set_stack('main', player:get_wield_index(), item)
		elseif inv: room_for_item('main', item) then
			inv: add_item('main', item)
		else
			minetest.add_item(pos, item)
		end
	end
end

-- Sums the number of uses across all of a set of tools' digging groups
-- Tools should be in the form of an itemstring
function etc.sum_uses (...)
	assert(etc.is_string(...), 'Items for sum_uses must be in the form of itemstrings')
	local total_uses = 0
	
	for _, toolname in pairs {...} do
		local toolname = ItemStack(toolname): get_name()
		local def = etc.log.assert(minetest.registered_items[toolname].tool_capabilities.groupcaps, 'No item named '..toolname)
		for __, group in pairs(def) do
			total_uses = total_uses + group.uses and group.uses * group.maxlevel or 0
		end
	end
	
	return total_uses
end

-- Averages the number of uses across all of a set of tools' digging groups
-- Tools should be in the form of an itemstring
function etc.average_uses (...)
	assert(etc.is_string(...), 'Items for average_uses must be in the form of itemstrings')
	local num_groups = 0
	local total_uses = 0
	
	for _, toolname in pairs {...} do
		local toolname = ItemStack(toolname): get_name()
		etc.log.assert(minetest.registered_items[toolname], 'No item named '..toolname)
		def = minetest.registered_items[toolname].tool_capabilities and minetest.registered_items[toolname].tool_capabilities.groupcaps
		
		if not def then
			num_groups = num_groups + 1
		else
			for __, group in pairs(def) do
				num_groups = num_groups + 1
				total_uses = total_uses + group.uses and group.uses * group.maxlevel or 0
			end
		end
	end
	
	return total_uses / num_groups
end

-- Converts RGB values from 0-1 into #RRGGBB[AA] hex
function etc.rgb_to_hex (r, g, b, a)
	return table.concat {'#',
		bit.tohex(r*255, 2): upper(),
		bit.tohex(g*255, 2): upper(),
		bit.tohex(b*255, 2): upper(),
		a and bit.tohex(a*255, 2): upper()
	}
end

-- Converts #RRGGBB[AA] hex strings into 0-1 RGB values r, g, b, a
function etc.hex_to_rgb (hex)
	local offset = hex: sub(1,1) == '#' and 1 or 0
	return tonumber('0x' .. hex: sub(1+offset, 2+offset))/255,
				 tonumber('0x' .. hex: sub(3+offset, 4+offset))/255,
				 tonumber('0x' .. hex: sub(5+offset, 6+offset))/255,
				 tonumber('0x' .. (#hex-offset > 6 and hex: sub(7+offset, 8+offset) or 'FF'))/255
end

-- return the current pointing range of the player
function etc.get_player_range (player)
	local item = player: get_wielded_item()
	
	local meta = item: get_meta()
	if meta: contains 'range' then
		return item: get_float 'range'
	end
	
	local def = item: get_definition()
	return def and def.range or player: get_inventory(): get_stack('hand', 1): get_definition().range or 4
end

-- returns the thing the player is pointing at, not including the player themself
-- <objects> and <liquids> are booleans specifying whether the player can point those things.
function etc.get_player_pointed_thing (player, objects, liquids)
	local properties = player: get_properties()
	local pos1 = player: get_pos() + vector.new(0, properties.eye_height, 0)
	local pos2 = pos1 + (player: get_look_dir() *  etc.get_player_range(player))
	
	local ray = Raycast(pos1, pos2, objects, liquids); ray: next()
	
	return ray: next()
end

function etc.set_player_look_dir (player, dir)
	dir = dir: normalize()
	player: set_look_horizontal(math.atan2(-dir.x, dir.z))
	player: set_look_vertical(math.asin(-dir.y))
end
