
-- Merges any number of tables together, with keys present in later tables overriding keys from previous tables.
function Etc.merge (tableA, ...)
	local newTable = table.copy(tableA)
	
	for _, currTable in ipairs {...} do
		for k, v in pairs(currTable) do
			newTable[k] = v
		end
	end
	
	return newTable
end

-- Merges any number of tables together, with keys present in later tables overriding keys from previous tables.
-- Also merges sub-tables; NOTE: does NOT check for circular definitions.
function Etc.mergeRecursive (tableA, ...)
	local newTable = table.copy(tableA)
	
	for _, currTable in ipairs {...} do
		for k, v in pairs(currTable) do
			newTable[k] = type(newTable[k]) == 'table' and type(v) == 'table' and Etc.mergeRecursive(newTable[k], v) or v
		end
	end
	
	return newTable
end

-- Same as mergeRecursive, but has an extra first argument that is an array of keys to not merge.
-- Unmerged keys will use the value supplied in the last (rightmostmost) supplied table containing the key.
function Etc.mergeExclusive (exclude, tableA, ...)
	local newTable = table.copy(tableA)
	
	for _, currTable in ipairs {...} do
		for k, v in pairs(currTable) do
			newTable[k] = (not exclude[k]) and type(newTable[k]) == 'table' and type(v) == 'table' and Etc.mergeRecursive(newTable[k], v) or v
		end
	end
	
	return newTable
end

-- Converts a table with multiple dimensions into a flat array while preserving apparent order of bottom-level elements.
-- Bottom-level elements can not be tables (since they would be counted as an additional dimension).
-- The table's "dimensions" do not need to be the same size (the table can actually be any tree).
-- Non-integer keys are not considered ordered, so they will not be present in the resultant array.
function Etc.flatten (table)
	local array = {}
	
	for i = 1, #table do
		local element = table[i]
		
		if type(element) == 'table' then
			local new_element = Etc.flatten(element)
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
