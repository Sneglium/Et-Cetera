
etc.sounds = {}
etc.sound_groups = {}

function etc.register_sound (name, filename, gain, pitch, ephemeral)
	etc.sounds[name] = {
		name = filename, gain = gain, pitch = pitch,
		ephemeral = ephemeral
	}
end

function etc.get_sound (name)
	local sound = table.copy(etc.sounds[name] or {})
	sound.ephemeral = nil
	return sound
end

function etc.play_sound_to (player, name, params, pitch)
	if type(params) == 'table' then
		params.to_player = player: get_player_name()
		
		local sound =etc.get_sound(name)
		
		minetest.sound_play(sound, params, sound.ephemeral)
	else
		local new_params = {
		 to_player = player: get_player_name(),
		 gain = params, pitch = pitch
		}
		
		local sound = etc.get_sound(name)
		
		minetest.sound_play(sound, new_params, sound.ephemeral)
	end
end

function etc.play_sound_at (target, name, params, pitch)
	if type(params) == 'table' then
		params[etc.is_vector(target) and 'pos' or 'object'] = target
		
		local sound = etc.get_sound(name)
		
		minetest.sound_play(sound, params, sound.ephemeral)
	else
		local new_params = {
		 [etc.is_vector(target) and 'pos' or 'object'] = target,
		 gain = params, pitch = pitch
		}
		
		local sound = etc.get_sound(name)
		
		minetest.sound_play(sound, new_params, sound.ephemeral)
	end
end

function etc.register_sound_group (name, def)
	local def2 = {}
	
	def2.footstep     = etc.get_sound(def.step or def.dig)
	def2.dig          = etc.get_sound(def.dig or def.step)
	def2.dug          = etc.get_sound(def.dug or def.dig)
	def2.place        = etc.get_sound(def.place or def.dug)
	def2.fall         = etc.get_sound(def.fall or def.dug)
	def2.place_failed = etc.get_sound(def.place_failed)
	
	etc.sound_groups[name] = def2
end

function etc.get_sound_group (name)
	return etc.sound_groups[name]
end
