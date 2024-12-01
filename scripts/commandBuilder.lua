
-- Maps param type names to a function that accumulates characters and
--> outputs a type-converted result, or returns an error message.
local parameterTypes = {
	pos2 = function(stream)end,
	pos3 = function(stream)end,
	num = function(stream)end,
	int = function(stream)end,
	str = function(stream)end,
	bool = function(stream)end,
	player = function(stream)end,
	object = function(stream)end,
	item = function(stream)end,
	timestamp2 = function(stream)end,
	timestamp3 = function(stream)end
}

-- Maps command aliases to the function they should run.
Etc.knownCommandAliases = {}

-- Defines the format of a chat command definition.
local commandTemplate = {
	aliases = '?table',
	params = 'table',
	description = 'string',
	privs = 'table',
	func = 'function'
}

-- Registers a command or set of commands using the above format, which is
--> the same as an engine chatcommand except that 'params' is an array of
--> parameter type identifiers, and 'aliases' is an array of other allowed
--> names for the command.

-- Aliases are not actual registered commands, but rather are caught by
--> core.register_on_chat_message and then run through the main command
--> function. Aliases will be appended to the set description.

-- A parameter type identifier consists of either a name from parameterTypes
--> or an arbitrary string to be matched exactly. Prepend with a % to always
--> treat as a string to match even if a param has that name. Any identifier
--> can also be preceded by a ? in order to make it optional. A union of mul
--> -tiple identifiers can be created by concatenating them together with |,
--> for example pos3|player|%surface to match a position, player selector, or
--> the string "surface".
Etc.registerModComponent('registerChatCommand', function (modObject, name, def)
	if name: sub(1,1) == ':' then
		name = name: sub(2, -1)
	else
		name = modObject.name .. ':' .. name
	end
	
	local succ, err = Etc.validateTableStructure(def, commandTemplate, 'commandDef')
	Etc.log.assert(succ, 'Invalid chatcommand definition: key ' .. err .. ' missing or incorrect type', 2)
	
	
end)

Etc: registerChatCommand('test', {
	aliases = {'test2'},
	description = 'peemf',
	params = {'?player'},
	privs = {'server'},
	func = function (execName, player)
	
	end
})
