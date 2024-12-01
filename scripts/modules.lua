
-- These functions handle checking for particular kinds of dependency.
local dependTypes = {
	['$'] = function (name, modObject) -- Checks for global values w/ sub-values, ex. a.b.c and fails if a, b, or c are undefined
		if rawget(_G, name) ~= nil then
			return true
		end
		
		local keys = string.split(name, '.')
		
		local lastLocation = _G
		local currentPath = ''
		
		for _, key in ipairs(keys) do
			if lastLocation[key] ~= nil then
				lastLocation = lastLocation[key]
				currentPath = currentPath .. key .. '.'
			else
				return false, currentPath..key..' is not defined.'
			end
		end
		
		return true
	end,
	['@'] = function (name, modObject) -- Checks a single-level value of the relevant mod
		return modObject[name] ~= nil, 'Module or property "'..name..'" of '..modObject.name..' not defined.'
	end,
	['&'] = function (name, modObject) -- Checks for a registered item or alias
		local exists = core.registered_items[name] ~= nil or core.registered_aliases[name] ~= nil
		return exists, 'Resource "'..name..'" is not registered.'
	end
}

-- Assess a set of dependencies from the perspective of a particular mod.
-- modObject only determines the effect of @prop depends, which refer to a value e.g. modObject.prop
local function checkDepends (depends, modObject)
	local available = {}
	
	for _, depend in ipairs(depends) do
		local prefix = depend: sub(1,1)
		local suffix = depend: sub(-1, -1)
		
		local realName = depend:sub (dependTypes[prefix] and 2 or 1, suffix == '?' and -2 or -1)
		
		local success = false
		local message
		
		if dependTypes[prefix] then
			success, message = dependTypes[prefix](realName, modObject)
		else -- no special depend type, assume a mod
			success = core.get_modpath(realName) ~= nil
			if not success then message = 'Mod "'..realName..'" disabled or nonexistent.' end
		end
		
		if suffix == '?' then -- if optional depend
			available[realName] = success -- then mark as available or not, used in module.depends
		elseif not success then
			return false, {}, message -- else fail
		end
	end
	
	return true, available -- we didn't fail, so return success and the available optional depends
end

-- Loads and runs a module file.
-- This function creates the environment table for the module file, as well as a special
--> addFile function which loads files Etc-style from the perspective of the module and
--> into the module environment, not globally.

-- Returns the environment as left after the module has finished running.
local function doModuleFile (modObject, moduleDef, optionalAvailable)
	local modulePath = table.concat {
		modObject.path,
		'/scripts/modules/',
		moduleDef.file,
		moduleDef.file: find '%.lua' and '' or '.lua'
	}
	
	local moduleEnv = setmetatable({
		depends = optionalAvailable, -- table of available optional depends as dependName = bool
		settings = modObject.settings -- when inside will be set up to use a special category
	}, {__index = _G})
	
	-- adds another file inside the module's environment
	local function addFile (fileBaseName)
		local chunk = loadfile(table.concat {
			modObject.path,
			'/scripts/modules/',
			fileBaseName,
			fileBaseName: find '%.lua'
				and ''
				or '.lua'
		})
		
		setfenv(chunk, moduleEnv)
		
		return chunk()
	end
	
	setfenv(addFile, moduleEnv)
	moduleEnv.addFile = addFile
	
	-- load the module code from the file, treat errors like MT does, give it environment
	local moduleChunk = setfenv(assert(loadfile(modulePath)), moduleEnv)
	
	-- make the settings object use modName.moduleName.key rather than just modName.key,
	-- and put things in the category moduleName rather than _root
	modObject.settings: setKeyExtension(moduleDef.name or moduleDef.file)
	modObject.settings._rootCategory = moduleDef.settingsCategory
	-- run the module
	moduleChunk()
	-- return the settings object to its' out-of-module state
	modObject.settings: resetKeyExtension()
	modObject.settings._rootCategory = 'none'
	
	-- return the module's environment
	return getfenv(moduleChunk)
end

-- These functions control how a module is loaded.
-- Currently the only loading style (other than the default) is 'lazy'.
-- Lazy modules' loading will be postponed until a reference is made to their parent
--> modObject, ex. modObject.moduleName.someModuleProperty...
local moduleLoadStyles = {
	lazy = function (modObject, moduleDef, optionalAvailable)
		modObject._indexFuncs[moduleDef.name or moduleDef.file] = function ()
			return doModuleFile(modObject, moduleDef, optionalAvailable)
		end
	end
}

-- This mod component defines the mod: addModule method for all Etc mods.
-- It creates a settings category for the module regardless of the actual status of the module
---> (e.g. enabled, has depends) so that its configuration can still be accessed for other reasons.
Etc.registerModComponent('addModule', function (modObject, moduleDef)
	local settingKey = moduleDef.settingKey or (moduleDef.name or moduleDef.file) .. '.enable'
	
	if moduleDef.enabledByDefault == nil then
		moduleDef.enabledByDefault = true
	end
	
	-- Special category that any settings defined inside will go into
	local moduleCategory = modObject.settings: registerCategory {
		name = moduleDef.name or moduleDef.file,
		displayname = moduleDef.displayname or moduleDef.name or moduleDef.file,
		description = moduleDef.description
	}
	
	moduleDef.settingsCategory = moduleCategory
	
	-- Modules exist so that they can be user-disabled, hence no option to take away this setting
	modObject.settings: define(settingKey, {
		category = moduleCategory,
		dataType = 'bool',
		default = moduleDef.enabledByDefault,
		displayname = 'Enable Module',
		description = 'Enable or disable the module entirely.'
	})
	
	local enabled = core.settings: get_bool(settingKey, moduleDef.enabledByDefault)
	
	if enabled then
		local success, optionalAvailable, message
		
		if moduleDef.depends then
			success, optionalAvailable, message = checkDepends(moduleDef.depends, modObject)
		else
			success = true -- has no depends so always satisfied
		end
		
		if success then
			if moduleDef.loadStyle then
				Etc.log.assert(moduleLoadStyles[moduleDef.loadStyle], 'Undefined module loading style: ' .. tostring(moduleDef.loadStyle), 1)
				moduleLoadStyles[moduleDef.loadStyle](modObject, moduleDef, optionalAvailable)
			else -- no special loading style, just run it
				return doModuleFile(modObject, moduleDef, optionalAvailable)
			end
		else
			if moduleDef.logOnFail then -- if enabled but unsatisifed, optionally log a message
				Etc.log[moduleDef.logOnFail]('Not loading module ', (moduleDef.name or moduleDef.file), ': ', message)
			end
		end
	else
		Etc.log.verbose('Not loading module ', moduleDef.name or moduleDef.file, '; disabled via settings')
	end
end)
