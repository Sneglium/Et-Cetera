
EtCetera = { }
Etc = EtCetera

local MP = core.get_modpath('etcetera')

-- Load logging & error management tools
dofile(MP .. '/scripts/log.lua')
dofile(MP .. '/scripts/validate.lua')

-- Load mod registration system & basic mod components
dofile(MP .. '/scripts/modRegBase.lua')

-- Register self as a mod
EtCetera.registerExistingMod(EtCetera, 'etcetera', 'etc')

-- General utilities
Etc: addScript 'miscUtils'
Etc: addScript 'textUtils'
Etc: addScript 'mathUtils'
Etc: addScript 'tableUtils'

-- Settings handling mod component & settingtypes generation command
Etc: addScript 'settingsHandler'
Etc: addScript 'dumpSettingTypes'
Etc.baseSettingKey = 'etc'

-- Module loading system
Etc: addScript 'modules'

-- Translation management mod component & example.tr generation
Etc: addScript 'tlManager'
Etc: addScript 'dumpTranslations'

-- Mod components: Basic content
Etc: addScript 'itemRegBase'
Etc: addScript 'customItemDef'
Etc: addScript 'itemRegExtended'

Etc: addScript 'nodeBoxUtils'

--Etc: addScript 'commandBuilder'
--Etc: addScript 'formspecBuilder'

-- Content: Sounds
Etc: addScript 'soundManager'
Etc: addScript 'basicSoundLibrary'
