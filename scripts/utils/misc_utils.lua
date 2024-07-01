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
	for k, v in pairs {...} do
		local ch1 = v: sub(1,1)
		local key = v: sub(2,-1)
		if ch1 == '$' then
			if not rawget(_G, key) then return false end
		elseif ch1 == '@' then
			if not minetest.registered_items[key] or minetest.registered_aliases[key] then return false end
		elseif ch1 == '&' then
			if not etc.modules[key] then return false end
		else
			if not minetest.get_modpath(v) then return false end
		end
	end
	return true
end

-- TABLE HELPERS
-- General stuff for manipulating tables

-- Recursively tests if all the fields in a table match the types required in the template.
-- Give the template with the exact structure of the table to test, where each non-table value is replaced by the type it should be as a string.
-- Types prepended with a ? (e.g. '?boolean') are optional, but will still fail if a wrong type is supplied (other than nil).
-- Does not test for keys not present in the template, arbitrary keys are allowed.
-- Returns a boolean for successful match; if false, secondarily returns the non-matching "key path" ('table.<key>.<key>...') as a string.
function etc.validate_table_struc (tb, template, parent)
	parent = parent or 'table.'
	
	for k, v in pairs(template) do
		if type(v) == 'table' then
			if type(tb[k]) == 'table' then
				local success, code = etc.validate_table_struc(tb[k], v, parent .. tostring(k) .. '.')
				if not success then
					return false, code
				end
			else
				return false, parent .. tostring(k)
			end
		else
			if v: sub(1,1) == '?' then
				if v: sub(2, -1) ~= type(tb[k]) and tb[k] ~= nil then
					return false, parent .. tostring(k)
				end
			else
				if v ~= type(tb[k]) then
					return false, parent .. tostring(k)
				end
			end
		end
	end
	
	return true, ''
end

-- Converts a table with multiple dimensions into a flat array while preserving apparent order of bottom-level elements
-- Bottom-level elements may not be tables
function etc.flatten(tb)
	local arr = {}
	
	for i = 1, #tb do
		local elem = tb[i]
		if type(elem) == 'table' then
			local ntb = etc.flatten(elem)
			for j = 1, #ntb do
				local sbelem = ntb[j]
				table.insert(arr, sbelem)
			end
		else
			table.insert(arr, v)
		end
	end
	
	return arr
end

-- GENERAL HELPERS

-- Tries to give an item to a player, and drops it on the ground if unable
function etc.give_or_drop (player, pos, item)
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
	local total_uses = 0
	
	for _, toolname in pairs {...} do
		local def = minetest.registered_items[toolname].tool_capabilities.groupcaps
		for __, group in pairs(def) do
			total_uses = total_uses + group.uses and group.uses * group.maxlevel or 0
		end
	end
	
	return total_uses
end

-- Averages the number of uses across all of a set of tools' digging groups
-- Tools should be in the form of an itemstring
function etc.average_uses (...)
	local num_groups = 0
	local total_uses = 0
	
	for _, toolname in pairs {...} do
		local def = minetest.registered_items[toolname].tool_capabilities.groupcaps
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
