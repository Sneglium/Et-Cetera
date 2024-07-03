-- A bunch of different helper functions that wouldn't make much sense as part of a different category

-- MISC. PLACEHOLDERS
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
function etc.check_depends (...)
	for _, depend in pairs {...} do
		local first_char = depend: sub(1,1)
		local key = depend: sub(2,-1)
		
		if first_char == '$' then
			if not rawget(_G, key) then return false end
		elseif first_char == '@' then
			if not minetest.registered_items[key] or minetest.registered_aliases[key] then return false end
		elseif first_char == '&' then
			if not etc.modules[key] then return false end
		else
			if not minetest.get_modpath(depend) then return false end
		end
	end
	return true
end

-- TABLE HELPERS
-- General stuff for manipulating tables

-- Converts a table with multiple dimensions into a flat array while preserving apparent order of bottom-level elements
-- Bottom-level elements may not be tables
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

-- Merges two tables together, with keys present in both being prioritized from the second table
function etc.merge (table_a, table_b)
	local new_table = table.copy(table_a)
	
	for k, v in pairs(table_b) do
		new_table[k] = v
	end
	
	return new_table
end

function etc.array_find (array, data)
	for index, v in pairs(array) do
		if v == data then return index, v end
	end
	
	return nil
end

-- TYPE & ERROR HELPERS

-- Table that holds the various log functions
etc.log = {}

function etc.log.fatal (msg)
	minetest.log('error', table.concat {'<', minetest.get_current_modname() or '@active', '/FATAL> ', msg})
	error(msg, 3)
end

function etc.log.assert (cond, msg)
	if not cond then
		etc.log.fatal(msg)
	end
	
	return cond
end

function etc.log.error (msg)
	minetest.log('error', table.concat {'<', minetest.get_current_modname() or '@active', '/ERROR> ', msg})
end

function etc.log.warn (msg)
	minetest.log('warning', table.concat {'<', minetest.get_current_modname() or '@active', '/WARN> ', msg})
end

function etc.log.info (msg)
	minetest.log('info', table.concat {'<', minetest.get_current_modname() or '@active', '/INFO> ', msg})
end

function etc.log.action (msg)
	minetest.log('action', table.concat {'<', minetest.get_current_modname() or '@active', '/ACTION> ', msg})
end

function etc.log.apoc (msg)
	minetest.log('verbose', table.concat {'<', minetest.get_current_modname() or '@active', '/APOC> ', msg})
end

etc.log = setmetatable(etc.log, {__call = etc.log.info})

-- Simple verification functions
-- Useful for passing to methods that require a verifier

function etc.is_number (...)
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'number' then return false end
	end
	
	return true
end

function etc.is_string (...)
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'string' then return false end
	end
	
	return true
end

function etc.is_bool (...)
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'boolean' then return false end
	end
	
	return true
end

function etc.is_table (...)
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'table' then return false end
	end
	
	return true
end

function etc.is_function (...)
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
-- Does NOT check if they are continuous
function etc.is_array (table)
	for key, _ in pairs(table) do
		if type(key) ~= 'number' then return false end
	end
	
	return true
end

local function single_is_vector (v)
	return getmetatable(v) and getmetatable(v) == vector.metatable
end

-- Ensures all the passed arguments are vectors with metatables
function etc.is_vector (...)
	for i = 1, select('#', ...) do
		if not single_is_vector(select(i, ...)) then return false end
	end
	
	return true
end


local function single_is_itemstack (v)
	return ItemStack(v) == v
end

-- Ensures all the passed arguments are itemstack objects
function etc.is_itemstack (...)
	for i = 1, select('#', ...) do
		if not single_is_itemstack(select(i, ...)) then return false end
	end
	
	return true
end

-- Recursively tests if all the fields in a table match the types required in the template.
-- Give the template with the exact structure of the table to test, where each non-table value is replaced by the type it should be as a string.
-- Types prepended with a ? (e.g. '?boolean') are optional, but will still fail if a wrong type is supplied (other than nil).
-- Does not test for keys not present in the template, arbitrary keys are allowed.
-- Returns a boolean for successful match; if false, secondarily returns the non-matching "key path" ('table.<key>.<key>...') as a string.
function etc.validate_table_struc (table, template, parent)
	parent = parent or 'table.'
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

-- Tries to give an item to a player, and drops it on the ground if unable
function etc.give_or_drop (player, pos, item)
	etc.log.assert(etc.is_vector(pos), 'Item position must be a vector')
	etc.log.assert(etc.is_itemstack(item), 'Item must be an ItemStack')
	
	local inv = player: get_inventory()
	if inv: room_for_item('main', item) then
		inv: add_item('main', item)
	else
		minetest.add_item(pos, item)
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
		local def = etc.log.assert(minetest.registered_items[toolname].tool_capabilities.groupcaps, 'No item named '..toolname)
		for __, group in pairs(def) do
			num_groups = num_groups + 1
			total_uses = total_uses + group.uses and group.uses * group.maxlevel  or 0
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
