
Etc.log = {}

-- Equivalent to error(), but logs the message minetest-style first
-- Default: blames the function calling the function that calls this
function Etc.log.throwFatal (message, level)
	Etc.log.error(message)
	error('\n' .. message .. '\n', level or 2)
end

-- Equivalent to assert(), but logs the message minetest-style first
-- Default: blames the function calling the function that calls this
-- <level> is _added_ to that, not replacing it
function Etc.log.assert (condition, message, level)
	if not condition then
		Etc.log.throwFatal(message, (level or 0) + 3)
	end
end

function Etc.log.error (...)
	core.log('error', table.concat {'<', core.get_current_modname() or '@active', '> ', ...})
end

function Etc.log.warn (...)
	core.log('warning', table.concat {'<', core.get_current_modname() or '@active', '> ', ...})
end

function Etc.log.info (...)
	core.log('info', table.concat {'<', core.get_current_modname() or '@active', '> ', ...})
end

function Etc.log.action (...)
	core.log('action', table.concat {'<', core.get_current_modname() or '@active', '> ', ...})
end

function Etc.log.verbose (...)
	core.log('verbose', table.concat {'<', core.get_current_modname() or '@active', '> ', ...})
end

-- Etc.log(...) := Etc.log.info(...)
Etc.log = setmetatable(Etc.log, {
	__call = function (self, ...)
		self.info(...)
	end
})
