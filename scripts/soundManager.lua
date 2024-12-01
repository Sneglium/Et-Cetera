
Etc.sounds = {}
Etc.materialSounds = {}

-- Define a new sound, with optional default parameters.
function Etc.registerSound (name, fileName, gain, pitch, ephemeral)
	Etc.sounds[name] = {
		name = fileName, gain = gain, pitch = pitch,
		ephemeral = ephemeral
	}
end

-- Return a soundspec for a named sound. Undefined sounds will return an empty table.
function Etc.getSound (name)
	local sound = table.copy(Etc.sounds[name] or {})
	sound.ephemeral = nil
	return sound
end

-- Play a registered sound to a player.
-- The following argument signatures can be used:
--- (player, soundName, [gain, pitch]): Play the sound with optional simple volume and pitch control
--- (player, soundName, parameters): Play using a full sound parameter table
function Etc.playSoundTo (player, name, params, pitch)
	if type(params) == 'table' then
		params.to_player = player: get_player_name()
		
		local sound = Etc.getSound(name)
		
		core.sound_play(sound, params, sound.ephemeral)
	else
		local newParams = {
		 to_player = player: get_player_name(),
		 gain = params, pitch = pitch
		}
		
		local sound = Etc.getSound(name)
		
		core.sound_play(sound, newParams, sound.ephemeral)
	end
end

-- Play a registered sound either at a vector world position, or attached to an object
-- The following argument signatures can be used:
--- (pos, soundName, [gain, pitch]): Play the sound with optional simple volume and pitch control to a position
--- (pos, soundName, parameters): Play using a full sound parameter table to a position
--- (object, soundName, [gain, pitch]): Play the sound with optional simple volume and pitch control at an object
--- (object, soundName, parameters): Play using a full sound parameter table at an object
function Etc.playSoundAt (target, name, params, pitch)
	if type(params) == 'table' then
		params[Etc.isVector(target) and 'pos' or 'object'] = target
		
		local sound = Etc.getSound(name)
		
		core.sound_play(sound, params, sound.ephemeral)
	else
		local newParams = {
		 [Etc.isVector(target) and 'pos' or 'object'] = target,
		 gain = params, pitch = pitch
		}
		
		local sound = Etc.getSound(name)
		
		core.sound_play(sound, newParams, sound.ephemeral)
	end
end

-- Define a new sound group. Sane defaults are set for missing sounds based on the other sounds
--> provided, if applicable.
function Etc.registerMaterialSounds (name, def)
	local def2 = {}
	
	def2.footstep     = Etc.getSound(def.step or def.dig)
	def2.dig          = Etc.getSound(def.dig or def.step)
	def2.dug          = Etc.getSound(def.dug or def.dig)
	def2.place        = Etc.getSound(def.place or def.dug)
	def2.fall         = Etc.getSound(def.fall or def.dug)
	def2.place_failed = Etc.getSound(def.place_failed)
	
	Etc.materialSounds[name] = def2
end

-- Retrieve a sound group by name, or an empty table if undefined.
function Etc.getMaterialSounds (name)
	return Etc.materialSounds[name] or {}
end
