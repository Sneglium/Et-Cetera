
-- Stores functions that process particular fields of an Etc-style item definition.
local itemDefTransformers = {}

-- Register a raw item of any type.
-- Runs a set of generic transformers that apply to all items.
Etc.registerModComponent('registerItem', function (modObject, unlocalizedName, itemDef)
	itemDef.type = itemDef.type or 'none'
	itemDef.mod_origin = modObject.name
	
	local localizedName = (unlocalizedName: sub(1,1) ~= ':' and (modObject.name .. ':') or '') .. unlocalizedName
	
	local itemDefTransformed = {}
	
	for key, value in pairs(itemDef) do
		if value ~= nil then
			if itemDefTransformers[key] then
				itemDefTransformed[key] = itemDefTransformers[key](modObject, value, itemDef, itemDefTransformed, localizedName)
			else
				itemDefTransformed[key] = value
			end
		end
	end
	
	core.register_item(localizedName, itemDefTransformed)
	
	for _, alias in ipairs(modObject.aliases) do
		core.register_alias(alias ..':'.. unlocalizedName, localizedName)
	end
	
	core.register_alias(unlocalizedName, localizedName)
end)

-- Registers a "craftitem" (an item that isn't a tool and doesn't represent a node).
Etc.registerModComponent('registerBasicItem', function (modObject, unlocalizedName, itemDef)
	itemDef.type = 'craft'
	
	local itemDefTransformed = {}
	
	if modObject.craftitemDefTransformers then
		for key, value in pairs(itemDef) do
			if modObject.craftitemDefTransformers[key] then
				itemDefTransformed[key] = modObject.craftitemDefTransformers[key](value, itemDef, itemDefTransformed, unlocalizedName)
			else
				itemDefTransformed[key] = value
			end
		end
	else
		itemDefTransformed = itemDef
	end
	
	modObject: registerItem(unlocalizedName, itemDefTransformed)
end)

-- Registers a tool (unstackable item with wear/durability).
Etc.registerModComponent('registerToolItem', function (modObject, unlocalizedName, itemDef)
	itemDef.type = 'tool'
	
	local itemDefTransformed = {}
	
	if modObject.toolDefTransformers then
		for key, value in pairs(itemDef) do
			if modObject.toolDefTransformers[key] then
				itemDefTransformed[key] = modObject.toolDefTransformers[key](value, itemDef, itemDefTransformed, unlocalizedName)
			else
				itemDefTransformed[key] = value
			end
		end
	else
		itemDefTransformed = itemDef
	end
	
	modObject: registerItem(unlocalizedName, itemDefTransformed)
end)

-- Registers a node.
Etc.registerModComponent('registerNode', function (modObject, unlocalizedName, itemDef)
	itemDef.type = 'node'
	
	local itemDefTransformed = {}
	
	if modObject.nodeDefTransformers then
		for key, value in pairs(itemDef) do
			if modObject.nodeDefTransformers[key] then
				itemDefTransformed[key] = modObject.nodeDefTransformers[key](value, itemDef, itemDefTransformed, unlocalizedName)
			else
				itemDefTransformed[key] = value
			end
		end
	else
		itemDefTransformed = itemDef
	end
	
	modObject: registerItem(unlocalizedName, itemDefTransformed)
end)

-- Create an item def transformer that applies to ALL items registered by ALL Etc mods.
-- These functions must take care to not assume anything about the item in question, because
--> there are no guarantees that can be made about 'raw' items.
function Etc.registerRawItemTransformer (key, func)
	Etc.log.assert(itemDefTransformers[key] == nil, 'Transformer for field '..key..' already exists!', 1)
	itemDefTransformers[key] = func
end

-- Create a transformer that only applies to craftitems registered by the relevant mod.
Etc.registerModComponent('registerCraftItemTransformer', function (modObject, key, func)
	modObject.craftitemDefTransformers[key] = func
end)

-- Create a transformer that only applies to tool items registered by the relevant mod.
Etc.registerModComponent('registerToolTransformer', function (modObject, key, func)
	modObject.toolDefTransformers[key] = func
end)

-- Create a transformer that only applies to node items registered by the relevant mod.
Etc.registerModComponent('registerNodeTransformer', function (modObject, key, func)
	modObject.nodeDefTransformers[key] = func
end)
