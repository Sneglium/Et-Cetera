
Etc.registerSound('mud_dig', 'etc_mud_dig', 1, 1, true)
Etc.registerSound('mud_dug', 'etc_mud_dug', 1, 1, true)
Etc.registerSound('mud_step', 'etc_mud_step', 1, 1, true)

Etc.registerMaterialSounds('mud', {
	step = 'mud_step',
	dig  = 'mud_dig',
	dug  = 'mud_dug'
})

Etc.registerSound('slime_dig', 'etc_slime_dig', 1, 1, true)
Etc.registerSound('slime_step', 'etc_slime_step', 1, 1, true)

Etc.registerMaterialSounds('slime', {
	step = 'slime_step',
	dig  = 'slime_dig',
	dug  = 'mud_dug'
})

