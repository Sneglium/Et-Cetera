
local function get_translator (modname)
	local tl = minetest.get_translator(modname)
	return function (text, color, ...)
		return tl(text, ...)
	end
end

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

function etc.create_wrappers (modname, ...)
	local aliases = {...}
	
	local translate = etc.gettext[modname] or get_translator(modname) or etc.ID
	
	return function (id, def)
		def.description = def.displayname and translate(def.displayname) .. (def.description and '\n'..translate(def.description, 'description') or '') .. (def.stats and get_statblock(def.stats, translate) or '')
		
		minetest.register_node(modname..':'.. id, def)
		
		for k, v in pairs(aliases) do
			minetest.register_alias(v ..':'.. id, modname..':'.. id)
		end
		
		minetest.register_alias(id, modname..':'.. id)
	end,

	function (id, def)
		def.description = def.displayname and translate(def.displayname) .. (def.description and '\n'..translate(def.description, 'description') or '') .. (def.stats and get_statblock(def.stats, translate) or '')
		
		minetest.register_craftitem(modname..':'.. id, def)
		
		for k, v in pairs(aliases) do
			minetest.register_alias(v ..':'.. id, modname..':'.. id)
		end
		
		minetest.register_alias(id, modname..':'.. id)
	end,
	
	function (id, def)
		def.description = def.displayname and translate(def.displayname) .. (def.description and '\n'..translate(def.description, 'description') or '') .. (def.stats and get_statblock(def.stats, translate) or '')
		
		minetest.register_tool(modname..':'.. id, def)
		
		for k, v in pairs(aliases) do
			minetest.register_alias(v ..':'.. id, modname..':'.. id)
		end
		
		minetest.register_alias(id, modname..':'.. id)
	end
end

