
-- Component that registers items based on the definition of an existing item (or prototype) , with modifications.
-- Does not apply transformers if the item being inherited from is a real registered item, but does
--> apply transformers to items inherited from a prototype (as these aren't registered items, so haven't been transformed).
Etc.registerModComponent('inheritItem', function (modObject, parentItem, unlocalizedName, itemDef)
	local parentModname = parentItem: split ':' [1]
	local parentMod = Etc.registeredMods[parentModname]
	local proto = (parentMod and parentMod.itemPrototypes and parentMod.itemPrototypes[parentItem: split ':' [2]])
		or (modObject.itemPrototypes and modObject.itemPrototypes[parentItem])
		
	local finalDef
	
	if proto then
		finalDef = Etc.mergeRecursive(proto, itemDef)
		modObject: registerItem(unlocalizedName, finalDef)
		return
	else
		local item = core.registered_items[parentItem] or
			(core.registered_aliases[parentItem] and core.registered_items[core.registered_aliases[parentItem]])
		Etc.log.assert(item, 'Missing or invalid parent item for inherit: ' .. tostring(item))
		
		finalDef = Etc.mergeRecursive(item, itemDef)
	end
	
	local localizedName = (unlocalizedName: sub(1,1) ~= ':' and (modObject.name .. ':') or '') .. unlocalizedName
	
	core.register_item(localizedName, finalDef)
	
	for _, alias in ipairs(modObject.aliases) do
		core.register_alias(alias ..':'.. unlocalizedName, localizedName)
	end
	
	core.register_alias(unlocalizedName, localizedName)
end)

-- Creates 'prototypes', which are ethereal item defs that can be inherited from but don't exist on their own.
Etc.registerModComponent('registerItemPrototype', function (modObject, name, baseDef)
	modObject.itemPrototypes = modObject.itemPrototypes or {}
	
	Etc.log.assert(baseDef.type, 'Prototype base definition must contain a \'type\' field == "node" or "tool" or "craftitem" or "none"', 2)
	if baseDef.type == 'craftitem' then baseDef.type = 'craft' end
	
	modObject.itemPrototypes[name] = baseDef
end)

-- These fields are not merged by Etc.smartOverrideItem for one reason or another.
-- Currently only covers nodebox-like fields (because merging them would result in superimposed garbled nonsense).
local unmergingFields = {
	node_box = true,
	selection_box = true,
	collision_box = true
}

-- A version of override_item that also merges the fields it overrides.
-- For example, when changing item groups the core function would delete the existing groups field and replace it
--> with the new one, whereas smart override will smush them together allowing you to add groups without touching
--> the existing ones.
-- One major exception is that node_box and other fields with the same format will never be merged. (If they were,
--> you would end up with the new and old boxes superimposed on each other).
-- Just like the core function, this function can delete fields.
-- You can also specify additional fields to not merge, in which case the behaviour will match the core function
--> (just replacing the field entirely with the new version).
function Etc.smartOverrideItem (item, newDef, delete, extraNoMerge)
	local itemDef = core.registered_items[item]
		or (core.registered_aliases[item] and core.registered_items[core.registered_aliases[item]])
	local useDef = {}
	Etc.log.assert(itemDef, 'Missing or invalid parent item for override')
	
	for k, _ in pairs(newDef) do
		useDef[k] = itemDef[k]
	end
	
	local noMerge = Etc.merge(unmergingFields, extraNoMerge or {})
	core.override_item(item, Etc.mergeExclusive(noMerge, useDef, newDef), delete)
end
