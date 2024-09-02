
etc.register_sound('mud_dig', 'etc_mud_dig', 1, 1, true)
etc.register_sound('mud_dug', 'etc_mud_dug', 1, 1, true)
etc.register_sound('mud_step', 'etc_mud_step', 1, 1, true)

etc.register_sound_group('mud', {
	step = 'mud_step',
	dig  = 'mud_dig',
	dug  = 'mud_dug'
})

etc.register_sound('slime_dig', 'etc_slime_dig', 1, 1, true)
etc.register_sound('slime_step', 'etc_slime_step', 1, 1, true)

etc.register_sound_group('slime', {
	step = 'slime_step',
	dig  = 'slime_dig',
	dug  = 'mud_dug'
})
