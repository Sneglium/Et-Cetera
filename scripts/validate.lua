
-- Simple validation functions
-- Useful for passing to methods that require a verifier, or using in asserts

function Etc.isNumber (...)
	if select('#', ...) == 1 and type(...) == 'number' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'number' then return false end
	end
	
	return true
end

function Etc.isInteger (...)
	if select('#', ...) == 1 and type(...) == 'number' and math.abs(...) == (...)  then return true end
	
	for i = 1, select('#', ...) do
		local n = select(i, ...)
		if type(n) ~= 'number' or math.floor(n) ~= n then return false end
	end
	
	return true
end

function Etc.isString (...)
	if select('#', ...) == 1 and type(...) == 'string' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'string' then return false end
	end
	
	return true
end

function Etc.isBool (...)
	if select('#', ...) == 1 and type(...) == 'boolean' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'boolean' then return false end
	end
	
	return true
end

function Etc.isTable (...)
	if select('#', ...) == 1 and type(...) == 'table' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'table' then return false end
	end
	
	return true
end

function Etc.isFunction (...)
	if select('#', ...) == 1 and type(...) == 'function' then return true end
	
	for i = 1, select('#', ...) do
		if type(select(i, ...)) ~= 'function' then return false end
	end
	
	return true
end

-- Advanced Verification functions

-- Ensures all the keys in a table are strings
function Etc.isDict (table)
	for key, _ in pairs(table) do
		if type(key) ~= 'string' then return false end
	end
	
	return true
end

-- Ensures all the keys in a table are numbers
-- Does NOT check if they are continuous, so not properly a mathematical array
function Etc.isArray (table)
	for key, _ in pairs(table) do
		if type(key) ~= 'number' or math.floor(key) ~= key then return false end
	end
	
	return true
end

-- Ensures all the passed arguments are vectors with metatables
function Etc.isVector (...)
	if select('#', ...) == 1 and vector.check(...) then return true end
	
	for i = 1, select('#', ...) do
		if not vector.check(select(i, ...)) then return false end
	end
	
	return true
end

local function singleIsItemstack (v)
	return ItemStack(v) == v
end

-- Ensures all the passed arguments are itemstack objects
function Etc.isItemstack (...)
	if select('#', ...) == 1 and singleIsItemstack(...) then return true end
	
	for i = 1, select('#', ...) do
		if not singleIsItemstack(select(i, ...)) then return false end
	end
	
	return true
end

local function singleIsItemstring (v)
	return core.registered_items[ItemStack(v): get_name()] ~= nil
end

-- Ensures all the passed arguments are valid strings representing registered items
function Etc.isItemstring (...)
	if select('#', ...) == 1 and singleIsItemstring(...) then return true end
	
	for i = 1, select('#', ...) do
		if not singleIsItemstring(select(i, ...)) then return false end
	end
	
	return true
end

-- Recursively tests if all the fields in a table and its' subtables match the types required in the template.
-- Give the template with the exact structure of the table to test, where each non-table value is replaced by the type it should be as a string.

-- Types prepended with a ? (e.g. '?boolean') are optional, but will still fail if a wrong type is supplied (other than nil).
-- Does not test for keys not present in the template, arbitrary keys are allowed.

-- If the type is appended with a colon (:) followed by a comma-delimited list of values, it is an enum with those specified values.
-- The supplied value will be matched against the allowed values after being run through tostring(), so the allowed values should
--> be possible outputs of tostring() as well.
-- For example, '?string:yes,no,maybe' allows nil, or one of the strings 'yes', 'no', or 'maybe' but no other values.
-- Example 2: 'number:0,0.5,1' will fail for any values other than 0, 0.5, or 1, including strings containing those values or nil.

-- Returns a boolean for successful match; if false, secondarily returns the non-matching "key path" ('table.<key>.<key>...') as a string.
-- Set <parent> to change the name of the root table in the error key path.
function Etc.validateTableStructure (table, template, parent)
	parent = parent and (parent .. '.') or 'table.'
	if type(table) ~= 'table' then return false, parent end
	
	for k, v in pairs(template) do
		if type(v) == 'table' then -- Subtable of the template?
			if type(table[k]) == 'table' then -- Check for a matching subtable of the validated table
				-- Recursively test subtables
				local success, code = Etc.validateTableStructure(table[k], v, parent .. tostring(k))
				if not success then
					return false, code
				end
			else
				return false, parent .. tostring(k)
			end
		else
			local allowed
			
			-- Is the key an enum?
			if v: find ':' then
				local sv = v: split ':'
				v = sv[1]
				allowed = sv[2]: split ','
			end
			
			if v: sub(1,1) == '?' then -- Key is optional, handle nils as allowed
				if v: sub(2, -1) ~= type(table[k]) and table[k] ~= nil then
					return false, parent .. tostring(k)
				end
				
				if allowed ~= nil and table[k] ~= nil then
					local found = false
					
					for _, v in ipairs(allowed) do -- Key is an enum, check if it has an allowed value
						if tostring(table[k]) == v then
							found = true; break
						end
					end
					
					if not found then
						return false, parent .. tostring(k)
					end
				end
			else
				if v ~= type(table[k]) then
					return false, parent .. tostring(k)
				end
				
				if allowed ~= nil then
					local found = false
					
					for _, v in ipairs(allowed) do
						if tostring(table[k]) == v then
							found = true; break
						end
					end
					
					if not found then
						return false, parent .. tostring(k)
					end
				end
			end
		end
	end
	
	return true, '' -- Empty string in case code always expects one
end
