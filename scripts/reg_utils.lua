
etc.register_mod_component('inherit_item', function (self, parent, id, new_def)
	local parent_modname = parent: split ':' [1]
	local parent_mod = etc.registered_mods[parent_modname]
	if parent_mod and parent_mod.item_prototypes and parent_mod.item_prototypes[parent: split ':' [2]] then
		local final_def = etc.merge_recursive(parent_mod.item_prototypes[parent: split ':' [2]], new_def)
		
		if etcetera.rawitem_transformers then
			for _, op in pairs(etcetera.rawitem_transformers) do
				op(self, self.name..':'.. id, final_def)
			end
		end
		
		minetest.register_item(self.name .. ':' .. id, final_def)
	else
		local item = minetest.registered_items[parent]
		etc.log.assert(item, 'Missing or invalid parent item for inherit')
		
		local final_def = etc.merge_recursive(item, new_def)
		
		if etcetera.rawitem_transformers then
			for _, op in pairs(etcetera.rawitem_transformers) do
				op(self, self.name..':'.. id, final_def)
			end
		end
		
		minetest.register_item(self.name .. ':' .. id, final_def)
	end
	
	for k, v in pairs(self.aliases) do
		minetest.register_alias(v ..':'.. id, self.name..':'.. id)
	end
	
	minetest.register_alias(id, self.name..':'.. id)
end)

etc.register_mod_component('register_item_prototype', function (self, id, base_def)
	self.item_prototypes = self.item_prototypes or {}
	
	etc.log.assert(base_def.type, 'Prototype base definition must contain a \'type\' field == "node" or "tool" or "craftitem" or "none"')
	if base_def.type == 'craftitem' then base_def.type = 'craft' end
	
	self.item_prototypes[id] = base_def
end)

function etc.smart_override_item (item, redef)
	local itemdef = table.copy(minetest.registered_items[item])
	etc.log.assert(item, 'Missing or invalid parent item for override')
	
	itemdef.name = nil
	itemdef.type = nil
	minetest.override_item(item, etc.merge_recursive(itemdef, redef))
end
