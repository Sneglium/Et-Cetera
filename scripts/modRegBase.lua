
-- Hold all the mods registered with Etc
Etc.registeredMods = {}

-- Hold all the mods registered with Etc, without duplicates/aliases
Etc.registeredModsRaw = {}

-- Holds 'mod components' (data all mods inherit)
Etc.modObjectInherits = {}
local inheritsToCall = {}

local modObjectMeta = {
	__index = function (self, key) -- mod._indexFuncs is used by the module lazy-loading system
		local func = rawget(self, '_indexFuncs')[key]
		if func then
			local dat = func()
			self[key] = dat
			return dat
		end
		
		if Etc.modObjectInherits[key] and inheritsToCall[key] then
			return Etc.modObjectInherits[key](self)
		else
			return Etc.modObjectInherits[key]
		end
	end
}

function Etc.registerMod (modName, ...)
	Etc.log.assert(Etc.isString(modName), 'Invalid modname: type <' .. type(modName) .. '>', 1)
	
	local modPath = core.get_modpath(modName)
	Etc.log.assert(modPath, 'Mod ' .. modName .. 'does not exist!', 1)
	
	local modObject = {}
	
	rawset(_G, modName, modObject)
	
	return Etc.registerExistingMod (modObject, modName, ...)
end

function Etc.registerExistingMod (modObject, modName, ...)
	Etc.log.assert(Etc.isString(modName), 'Invalid modname: type <' .. type(modName) .. '>', 1)
	
	local modPath = core.get_modpath(modName)
	Etc.log.assert(modPath, 'Mod ' .. modName .. 'does not exist!', 1)
	
	modObject._indexFuncs = {}
	
	local modObject = setmetatable(modObject, modObjectMeta)
	
	modObject.name = modName
	modObject.path = modPath
	modObject.dataPath = core.get_mod_data_path()
	
	modObject.aliases = {}
	
	if (...) and select('#', ...) > 0 then
		for i = 1, select('#', ...) do
			table.insert(modObject.aliases, select(i, ...))
			modObject.aliases[select(i, ...)] = true
		end
	end
	
	Etc.registeredModsRaw[modObject.name] = modObject
	Etc.registeredMods[modObject.name] = modObject
	for _, alias in ipairs(modObject.aliases) do
		Etc.registeredMods[alias] = modObject
	end
	
	return modObject
end

local componentErrMessage = 'A component called &name already exists! This may be a mod conflict, please report it.'

function Etc.registerModComponent (name, initialData, callOnIndex)
	Etc.log.assert(Etc.modObjectInherits[name] == nil, componentErrMessage: gsub('&name', name), 1)
	
	Etc.modObjectInherits[name] = initialData
	if callOnIndex then
		inheritsToCall[name] = true
	end
end

Etc.registerModComponent('addScript', function (modObject, fileBaseName)
	return dofile(table.concat {
		modObject.path,
		'/scripts/',
		fileBaseName,
		fileBaseName: find '%.lua'
			and ''
			or '.lua'
	})
end)
