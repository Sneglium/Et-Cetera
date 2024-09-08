
etc: register_item('icon_time', {
	inventory_image = 'etc_icon_time.png^etc_icon_bar_overlay.png',
	groups = {not_in_creative_inventory = 1},
	stack_max = -1
})

function etc.get_time_rep_stack (description, seconds)
	local stack = ItemStack('etcetera:icon_time')
	
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	
	minutes = minutes - (hours * 60)
	new_seconds = seconds - (minutes * 60) - (hours * 60 * 60)
	
	local timestring = (hours ~= 0 and (hours .. ':') or '') .. ((minutes ~= 0 or hours ~= 0) and (minutes .. ':') or '') .. new_seconds
	local timestring_long = hours .. 'h:' .. minutes .. 'm:' .. new_seconds .. 's'
	
	local meta = stack: get_meta()
	meta:set_int('count_alignment', 18)
	meta:set_string('count_meta', timestring)
	meta: set_string('description', description .. '\n' .. timestring_long)
	return stack
end

etc: register_item('icon_chance', {
	inventory_image = 'etc_icon_chance.png^etc_icon_bar_overlay.png',
	groups = {not_in_creative_inventory = 1},
	stack_max = -1
})

function etc.get_chance_rep_stack (percent, addendum, conds)
	local percent = 100*percent
	
	local stack = ItemStack('etcetera:icon_chance')
	stack: set_count(math.max(1, math.floor(percent)))
	
	local condstring = ''
	
	for _, v in ipairs(conds) do
		condstring = condstring .. '\n\t* '..v
	end
	
	percentstr = tostring(percent)
	
	local meta = stack: get_meta()
	meta:set_int('count_alignment', 18)
	meta:set_string('count_meta', percentstr: sub(1, math.min(4, #percentstr))..'%')
	meta: set_string('description', 'Percent Chance\n'..percentstr: sub(1, math.min(5, #percentstr))..'%'..(addendum and addendum ~= '' and ' '..addendum)..condstring)
	return stack
end

etc: register_item('icon_power', {
	inventory_image = 'etc_icon_power.png^etc_icon_bar_overlay.png',
	groups = {not_in_creative_inventory = 1},
	stack_max = -1
})

function etc.get_power_rep_stack (description, unit, amount, image)
	local stack = ItemStack('etcetera:icon_power')
	local meta = stack: get_meta()
	meta:set_int('count_alignment', 18)
	meta:set_string('count_meta', amount..unit)
	meta: set_string('description', 'Energy ('..description..')\n'..amount..unit)
	if image then
		meta: set_string('inventory_image', image..'^etc_icon_bar_overlay.png')
	end
	return stack
end
