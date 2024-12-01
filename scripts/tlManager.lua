
-- Allow using Mod.translate(text, ...) over Mod.translate: getText().
local translatorMeta = {
	__call = function (self, text, ...)
		return self: getText(text, ...)
	end
}

local function makeTranslator (modObject)
	local rootStage = {name = '_root'}
	
	local tl = {
		_stage = '_root',
		_texts = {_root = rootStage},
		_stages = {rootStage},
		_textsProcessed = {},
		setStage = function (self, stageName)
			if stageName == nil then
				stageName = '_root'
			end
			
			self._stage = stageName
			if not self._texts[self._stage] then
				local stageIndex = #self._stages + 1
				self._texts[self._stage] = {index = stageIndex, name = stageName}
				self._stages[stageIndex] = self._texts[self._stage]
			end
		end,
		getText = function (self, text, ...)
			local tld = core.translate(modObject.name, text, ...)
			
			if not self._textsProcessed[text] then
				self._textsProcessed[text] = true
				table.insert(self._texts[self._stage], text)
			end
			
			return tld
		end,
		addBreak = function (self)
			table.insert(self._texts[self._stage], '_LINEBREAK')
		end
	}
	
	return setmetatable(tl, translatorMeta)
end

Etc.registerModComponent('translate', function (modObject)
	modObject.translate = makeTranslator(modObject)
	return modObject.translate
end, true)
