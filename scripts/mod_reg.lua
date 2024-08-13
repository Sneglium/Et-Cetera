
local mod_meta = {
	__index = {}
}

etcetera.registered_mods = {}

local function get_translator (modname)
	local tl = minetest.get_translator(modname)
	return function (text, color, ...)
		return tl(text, ...)
	end
end

function etcetera.register_mod (modname, ...)
	local mod = setmetatable(rawget(_G, modname) or {}, mod_meta)
	
	mod.name = modname
	mod.path = minetest.get_modpath(modname)
	mod.aliases = {}
	
	if select('#', ...) >= 1 then
		for i = 1, select('#', ...) do
			table.insert(mod.aliases, select(i, ...))
		end
	end
	
	rawset(_G, modname, mod)
	
	etcetera.registered_mods[modname] = mod
	
	for _, v in pairs(mod.aliases) do
		etcetera.registered_mods[v] = mod
	end
	
	return mod
end

function etcetera.register_mod_component(name, data)
	mod_meta.__index[name] = data
end

etcetera.register_mod_component('load_script', function (self, fn)
	return dofile(table.concat {self.path, '/scripts/', fn, fn: find '%.lua' and '' or '.lua'})
end)

etcetera.register_mod_component('load_module', function (self, fn, ...)
	self.modules = self.modules or {}
	
	local key = self.settings_key or self.name
	if not minetest.settings: get_bool(key .. '.load_module_'..fn, true) then return end
		
	local success, missing = etc.check_depends(...)
	if success then
		local time = os.clock()
		self.modules[fn] = dofile(table.concat {self.path, '/scripts/modules/', fn, fn: find '%.lua' and '' or '.lua'}) or true
		self[fn] = self.modules[fn]
		etc.log('Loaded module ', fn, ' in ', tostring((os.clock() - time) * 0.001): sub(1, 4), 'ms')
	elseif minetest.settings: get_bool('etc.dependency_warning', true) then
		etc.log.warn('Module ', fn, ' is enabled but has unsatisfied dependency: ', missing)
	end
end)

etcetera.register_mod_component('translate', function (self, ...)
	self.translate = minetest.get_translator(self.name)
	
	return self.translate(...)
end)

etcetera.register_mod_component('gettext', function (self, ...)
	return self.translate(...)
end)

local function get_statblock (stats, translate)
	if type(stats) == 'table' then
		local statline = ''
		
		for _, v in ipairs(stats) do
			statline = statline .. minetest.colorize(etc.textcolors.statblock, '\n\t\u{2022} ') .. translate(tostring(v), 'statblock')
		end
		
		return statline
	else
		return minetest.colorize(etc.textcolors.statblock, '\n\t\u{2022} ') .. translate(tostring(stats), 'statblock')
	end
end

etcetera.register_mod_component('background_color', '#22242d')

function etcetera.register_rawitem_transformer (op)
	etcetera.rawitem_transformers = etcetera.rawitem_transformers or {}
	
	table.insert(etcetera.rawitem_transformers, op)
end

function etcetera.register_node_transformer (op)
	etcetera.node_transformers = etcetera.node_transformers or {}
	
	table.insert(etcetera.node_transformers, op)
end

function etcetera.register_item_transformer (op)
	etcetera.item_transformers = etcetera.item_transformers or {}
	
	table.insert(etcetera.item_transformers, op)
end

function etcetera.register_tool_transformer (op)
	etcetera.tool_transformers = etcetera.tool_transformers or {}
	
	table.insert(etcetera.tool_transformers, op)
end

etcetera.register_mod_component('register_node', function (self, id, def)
	if etcetera.rawitem_transformers then
		for _, op in pairs(etcetera.rawitem_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	if etcetera.node_transformers then
		for _, op in pairs(etcetera.node_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	minetest.register_node(self.name..':'.. id, def)
	
	for k, v in pairs(self.aliases) do
		minetest.register_alias(v ..':'.. id, self.name..':'.. id)
	end
	
	minetest.register_alias(id, self.name..':'.. id)
end)

etcetera.register_mod_component('register_item', function (self, id, def)
	if etcetera.rawitem_transformers then
		for _, op in pairs(etcetera.rawitem_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	if etcetera.item_transformers then
		for _, op in pairs(etcetera.item_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	minetest.register_craftitem(self.name..':'.. id, def)
	
	for k, v in pairs(self.aliases) do
		minetest.register_alias(v ..':'.. id, self.name..':'.. id)
	end
	
	minetest.register_alias(id, self.name..':'.. id)
end)

etcetera.register_mod_component('register_tool', function (self, id, def)
	if etcetera.rawitem_transformers then
		for _, op in pairs(etcetera.rawitem_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	if etcetera.tool_transformers then
		for _, op in pairs(etcetera.tool_transformers) do
			op(self, self.name..':'.. id, def)
		end
	end
	
	minetest.register_tool(self.name..':'.. id, def)
	
	for k, v in pairs(self.aliases) do
		minetest.register_alias(v ..':'.. id, self.name..':'.. id)
	end
	
	minetest.register_alias(id, self.name..':'.. id)
end)

etcetera.register_rawitem_transformer(function(self, id, def)
	def.description = minetest.get_background_escape_sequence(self.background_color or '')..(def.displayname and self.gettext(def.displayname, 'displayname') or '').. (def.description and def.description ~= '' and '\n'..self.gettext(def.description, 'description') or '') .. (def.stats and get_statblock(def.stats, self.gettext) or '')
end)
