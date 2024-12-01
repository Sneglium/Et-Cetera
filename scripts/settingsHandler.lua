
-- These functions process the OUTPUT of a setting value, as retrieved from core.settings.
local dataTypeHandlers = {
	int = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		local rawData = tonumber(rawData or def.default) or 0
		return math.floor(math.min(math.max(def.min, rawData), def.max))
	end,
	float = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		local rawData = tonumber(rawData or def.default) or 0
		return math.min(math.max(def.min, rawData), def.max)
	end,
	string = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		return rawData or def.default or ''
	end,
	enum = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		return rawData or def.default or ''
	end,
	path = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		return rawData or def.default or ''
	end,
	filepath = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		return rawData or def.default or ''
	end,
	key = function (rawKey, def)
		local rawData = core.settings: get(rawKey)
		return rawData or def.default or ''
	end,
	flags = function (rawKey, def)
		local rawData = core.settings: get_flags (rawKey)
		return rawData or def.default or {}
	end,
	noise_params_2d = function (rawKey, def)
		local rawData = core.settings: get_np_group(rawKey)
		return rawData or def.default
	end,
	noise_params_3d = function (rawKey, def)
		local rawData = core.settings: get_np_group(rawKey)
		return rawData or def.default
	end,
	v3f = function (rawKey, def)
		local rawData = core.setting_get_pos(rawKey)
		return rawData or def.default or ''
	end
}

-- Get the value of a single setting or its' default if unset, adjusted to fall within min-max.
local function calcSetting (self, key, def)
	local rawKey = self._baseKey .. '.' .. key
	
	Etc.log.assert(Etc.isString(def.dataType), 'Missing or invalid datatype for setting ' .. rawKey, 2)
	
	if def.dataType == 'bool' then
		return core.settings: get_bool(rawKey, def.default)
	elseif dataTypeHandlers[def.dataType] then
		return dataTypeHandlers[def.dataType](rawKey, def)
	else
		Etc.log.throwFatal('Invalid datatype for setting ' .. rawKey .. ' (' .. def.dataType .. ')', 4)
	end
end

-- Get the value of a setting as set by the user, or its' default if unset.
local function getSetting (self, key)
	local def = self._settingDefs[key]
	
	if def then
		if def.alwaysRecheck then
			return calcSetting(self, key, def)
		else
			local stored = self._storedSettings[key]
			
			if stored then
				return stored
			else -- memoize if not already, then return
				local data = calcSetting(self, key, def)
				self._storedSettings[key] = data
				return data
			end
		end
	else -- used when indexing e.g. settings.foo, but foo isn't a defined setting
		return core.settings: get(self._baseKey .. '.' .. key)
	end
end

-- Define a new setting.
-- Setting Definition:
--- displayname: The human-readable name used in settingtypes.txt.
--- description: The line comment to attach to the settingtype.
---- Newlines will split into multiple line comments, resulting in newlines in the in-menu description.
--- dataType: The setting type. Same as the types used in settingtypes.txt.
--- default: The default value of the setting.
--- min, max: Used by float and int settings, the minimum and maximum allowed values. Enforced.
--- enum: Used by enum type settings, an array of strings representing the possible values.
--- flags: The same as the above value, but specifies the possible flags for the flags type.
--- category: Parent this setting to the supplied category object; results in a group (ex. 
---> [Category]) in the settingtypes file.
local function defineSetting (self, key, settingDef)
	self._settingDefs[key] = settingDef
	
	if settingDef.category then
		settingDef.category: add(self._baseKey .. '.' .. key, settingDef)
	else
		if self._rootCategory ~= 'none' then
			self._rootCategory: add(self._baseKey .. '.' .. key, settingDef)
		else
			self._categories[1]: add(self._baseKey .. '.' .. key, settingDef)
		end
	end
end

-- Create a new category.
-- Category Definition:
--- name: Technical name, not used, good to define anyway for future-proofing.
--- displayname: The human readable name used in settingtypes.txt.
--- description: A line comment added to settingtypes.txt.

-- Returns a category object, with the following methods:
-- add(key, settingDef): Parent a setting to this category.
-- addCategory(categoryDef): Create a new subcategory for this category, returning a category object.
local function makeCategory (catDef)
	local category = {
		name = catDef.name,
		settings = {},
		subcategories = {},
		add = function (self, key, settingDef)
			table.insert(self.settings, {name = key, def = settingDef})
		end,
		addCategory = function (self, newCatDef)
			local category = makeCategory(newCatDef)
			table.insert(self.subcategories, category)
			return category
		end
	}
	
	if catDef.name ~= '_root' then
		category.displayname = catDef.displayname or 'Unnamed Category'
		category.description = catDef.description
	end
	
	return category
end

local function registerCategory (self, catDef)
	local category = makeCategory(catDef)
	table.insert(self._categories, category)
	return category
end

local settingsMeta = {
	__index = getSetting, __newindex = defineSetting
}

local function setKeyExtension (self, extension)
	self._baseKey = self._baseKey .. '.' .. extension
end

local function resetKeyExtension (baseKey)
	return function (self)
		self._baseKey = baseKey
	end
end

local function newSettingsManager (baseSettingKey)
	local settingsManager = setmetatable({
		_settingDefs = {},
		_baseKey = baseSettingKey,
		_storedSettings = {},
		_categories = {},
		_rootCategory = 'none', -- used by modules' settings object to automatically categorize settings
		define = defineSetting,
		get = getSetting,
		registerCategory = registerCategory,
		setKeyExtension = setKeyExtension,
		resetKeyExtension = resetKeyExtension(baseSettingKey)
	}, settingsMeta)
	
	settingsManager: registerCategory {
		name = '_root'
	}
	
	return settingsManager
end

Etc.registerModComponent('settings', function (modObject)
	modObject.settings = newSettingsManager(modObject.baseSettingKey or modObject.name)
	return modObject.settings
end, true)
