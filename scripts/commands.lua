
local affirmative = {
	['true'] = true,
	['True'] = true,
	['1'] = true,
	['y'] = true,
	['Y'] = true,
	['yes'] = true,
	['Yes'] = true
}

local function read_amount (inv, list, amount, verbose)
	local stacks = {}
	for i = 1, amount do
		local stack = inv: get_stack(list, i)
		if (stack: get_name() == '' or stack: get_name() == ':') and verbose then
			table.insert(stacks, '<nothing>\n')
		elseif not (stack: get_name() == '' or stack: get_name() == ':') then
			table.insert(stacks, (verbose and stack:to_string() or stack:get_name()) .. '\n')
		end
	end
	return table.concat(stacks)
end

local dump_funcs = {
	hand = function (name, verbose)
		local player = minetest.get_player_by_name(name)
		
		if (not player) then
			return false, 'Invalid usage.'
		end
		
		if verbose then
			etc.log.action(player: get_wielded_item(): to_string())
		else
			etc.log.action(player: get_wielded_item(): get_name())
		end
		
		return true, 'Wrote held item to log.'
	end,
	
	inv = function (name, verbose)
		local player = minetest.get_player_by_name(name)
		
		if (not player) then
			return false, 'Invalid usage.'
		end
		
		local inv = player: get_inventory()
		local stacks = read_amount(inv, 'main', inv: get_size 'main', verbose)
		etc.log.action('Player inventory dump begins: \n'..stacks)
		
		return true, 'Wrote inventory to log.'
	end,
	
	hotbar = function (name, verbose)
		local player = minetest.get_player_by_name(name)
		
		if (not player) then
			return false, 'Invalid usage.'
		end
		
		local inv = player: get_inventory()
		local stacks = read_amount(inv, 'main', math.min(8, inv: get_size 'main'), verbose)
		etc.log.action('Player hotbar dump begins: \n'..stacks)
		
		return true, 'Wrote hotbar to log.'
	end
}

dump_funcs.inventory = dump_funcs.inv

minetest.register_chatcommand('etc:dump', {
	privs = {server = true},
	description = 'Send player inventory info to the server console.\nIf verbose is true, dumps raw data.',
	params = '[hand | inventory | inv | hotbar] [<verbose>]',
	func = function (name, param)
		if param == '' then return false end
		
		local params = param: split ' '
		if #params > 2 then return false end
		
		local verbose = false
		if params[2] then
			if affirmative[params[2]] then
				verbose = true
			else
				return false
			end
		end
		
		if dump_funcs[params[1]] then
			return dump_funcs[params[1]](name, verbose)
		else
			return false
		end
	end
})
