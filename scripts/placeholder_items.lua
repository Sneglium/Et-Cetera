
etc: register_item('icon_time', {
	inventory_image = 'etc_icon_time.png',
	groups = {not_in_creative_inventory = 1},
	stack_max = -1
})

function etc.get_time_rep_stack (description, seconds)
	local stack = ItemStack('etcetera:icon_time')
	stack: set_count(math.max(1, seconds))
	
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	
	minutes = minutes - (hours * 60)
	new_seconds = seconds - (minutes * 60) - (hours * 60 * 60)
	
	local timestring = (hours and (hours .. 'h:')) .. (minutes and (minutes .. 'm:')) .. new_seconds .. 's'
	
	stack: get_meta(): set_string('description', description .. '\n' .. timestring)
	return stack
end

etc: register_item('icon_chance', {
	inventory_image = 'etc_icon_chance.png',
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
	
	percent = tostring(percent)
	stack: get_meta(): set_string('description', 'Percent Chance\n'..percent: sub(1, math.min(5, #percent))..'%'..(addendum and addendum ~= '' and ' '..addendum)..condstring)
	return stack
end

etc: register_item('icon_power', {
	inventory_image = 'etc_icon_power.png',
	groups = {not_in_creative_inventory = 1},
	stack_max = -1
})

function etc.get_power_rep_stack (description, unit, amount)
	local stack = ItemStack('etcetera:icon_power')
	stack: set_count(math.max(1, math.floor(amount)))
	stack: get_meta(): set_string('description', 'Energy ('..description..')\n'..amount..unit)
	return stack
end
