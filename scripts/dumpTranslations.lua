
local function tlEscape (rawText)
	return rawText:
	       gsub('@(%d)', '&&arg:%1'): -- Unescape number arguments to avoid mangling
	       gsub('@',     '@@'):       -- Escape any remaining @ signs
	       gsub('\n',    '@n'):       -- Convert newlines to escape codes
	       gsub('=',     '@='):       -- Convert equal signs to escapes
	       gsub('&&arg:(%d)', '@%1')  -- Restore number arguments
end

local function dumpTl (modObject)
	local content = '# textdomain: ' .. modObject.name .. '\n'
	
	for _, stage in ipairs(modObject.translate._stages) do
		if stage.name ~= '_root' then
			content = content .. '\n\n# stage: ' .. stage.name
		end
		
		for _, entry in ipairs(modObject.translate._texts[stage.name]) do
			if entry == '_LINEBREAK' then
				content = content .. '\n'
			else
				content = content .. '\n' .. tlEscape(entry) .. '='
			end
		end
	end
	
	local filePath = modObject.dataPath .. '/' .. modObject.name .. '.example.tr'
	local success = core.safe_file_write(filePath, content)
	
	if not success then
		return false, 'File writing failed'
	end
	
	return true, 'Wrote translations to ' .. filePath
end

local function dumpForMod (mod)
	if mod.translate ~= nil then
		local success, msg = dumpTl(mod)
		
		return success, msg
	else
		return false, 'Mod has no defined translations'
	end
end

local commandDef = {
	privs = {server = true},
	description = 'Generate a <modname>.example.tr file for a registered Etc mod in the mod data directory. Passing * as the parameter will run the command for all Etc mods. Passing no parameter will run the command for the Etc mod itself.',
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

core.register_chatcommand('etc:dump_translations', commandDef)
core.register_chatcommand('etc:dtl', commandDef)
