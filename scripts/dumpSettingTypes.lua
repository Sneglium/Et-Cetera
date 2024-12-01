
local typeArgs = {
	int = function (def)
		if def.min and def.max then
			return tostring(def.default) .. ' ' .. tostring(def.min) .. ' ' .. tostring(def.max)
		else
			return tostring(def.default)
		end
	end,
	string = function (def)
		return def.default
	end,
	bool = function (def)
		return tostring(def.default)
	end,
	float = function (def)
		if def.min and def.max then
			return tostring(def.default) .. ' ' .. tostring(def.min) .. ' ' .. tostring(def.max)
		else
			return tostring(def.default)
		end
	end,
	enum = function (def)
		return def.default .. ' ' .. table.concat(def.enum, ',')
	end,
	path = function (def)
		return def.default
	end,
	filepath = function (def)
		return def.default
	end,
	key = function (def)
		return def.default
	end,
	flags = function (def)
		return def.default .. ' ' .. table.concat(def.flags, ',')
	end
}

local function dumpSetting (setting)
	local content = ''
	
	if setting.def.description then
		content = content .. '\n\n# ' .. setting.def.description: gsub('\n', '\n# ')
	else
		content = content .. '\n'
	end

	content = content .. '\n' .. setting.name

	if setting.def.displayname then
		content = content .. ' (' .. setting.def.displayname .. ')'
	else
		content = content .. ' (Unnamed Setting)'
	end

	content = content .. ' ' .. setting.def.dataType
	content = content .. ' ' .. typeArgs[setting.def.dataType](setting.def)
	
	return content
end

local function dumpCategories (categories, indent)
	local content = ''
	
	local stars = ''
	for i = 1, indent do
		stars = stars .. '*'
	end
	
	for _, cat in ipairs(categories) do
		if cat.name ~= '_root' then
			content = content .. '\n\n'
			
			if cat.description then
				content = content .. '# '.. cat.description .. '\n'
			end
			
			content = content .. '[' .. stars .. cat.displayname .. ']'
		end
		
		for __, setting in ipairs(cat.settings) do
			content = content .. dumpSetting(setting)
		end
		
		if cat.subcategories then
			content = content .. dumpCategories(cat.subcategories, indent + 1)
		end
	end
	
	return content
end

function Etc.dumpSettingTypes(mod)
	local content = ''
	
	content = content .. dumpCategories(mod.settings._categories, 0)
	
	local filePath = mod.dataPath..'/settingtypes_generated.txt'
	local success = core.safe_file_write(filePath, content)
	
	if not success then
		return false, 'File writing failed'
	end
	
	return true, 'Wrote settingtypes to ' .. filePath
end

local function dumpForMod (mod)
	if mod.settings ~= nil then
		local success, msg = Etc.dumpSettingTypes(mod)
		
		return success, msg
	else
		return false, 'Mod has no defined settings'
	end
end

local commandDef = {
	privs = {server = true},
	description = 'Generate a settingtypes.txt file for a registered Etc mod in the mod data directory. Passing * as the parameter will run the command for all Etc mods. Passing no parameter will run the command for the Etc mod itself.',
	params = '<modname> | *',
	func = function (name, param)
		if param == '' then param = 'etcetera' end
		
		if param == '*' then
			local successTotal = true
			local msgTotal = ''
			for _, mod in pairs(Etc.registeredModsRaw) do
				local success, msg = dumpForMod(mod)
				
				successTotal = successTotal and success
				
				msgTotal = msgTotal .. msg .. '\n'
			end
			
			return successTotal, msgTotal
		else
			local mod = Etc.registeredMods[param]
			if mod then
				return dumpForMod(mod)
			else
				return false, 'Mod "'..param..'" does not exist'
			end
		end
	end
}

core.register_chatcommand('etc:dump_settingtypes', commandDef)
core.register_chatcommand('etc:dst', commandDef)
