
local DEFAULT_WRAP_LIMIT  = 40
local DEFAULT_BULLET_CHAR = '\u{2022}'

local DEFAULT_STAT_COLORS = {
	'#d43356',
	'#5094e8',
	'#b1e71d'
}

-- Defines the displayname - description convention of associating text with item definitions,
-- which is used rather than a single description field for Etc mods.
-- Item defs can still use just the description field, but it will not be automatically processed
-- in any way (no colors, wrapping, translations...)
Etc.registerRawItemTransformer('displayname', function (modObject, value, def, defTransformed)
	local oldDesc = def.description
	def.description = nil
	
	local nameColor, descColor
	
	if def.textColors then
		nameColor, descColor = def.textColors.displayname or 'white', def.textColors.description or '#788d9f'
	elseif modObject.textColors then
		nameColor, descColor = modObject.textColors.displayname or 'white', modObject.textColors.description or '#788d9f'
	else
		nameColor, descColor = 'white', '#788d9f'
	end
	
	local displayname = Etc.colorizeTranslated(nameColor, modObject.translate(value))
	defTransformed.description = displayname
	defTransformed.short_description = displayname
	
	if oldDesc then
		local description = Etc.colorizeTranslated(descColor, modObject.translate(Etc.wrapText(oldDesc, modObject.descWrapLimit or DEFAULT_WRAP_LIMIT)))
		defTransformed.description = defTransformed.description .. '\n' .. description
		defTransformed.long_description = description
	end
	
	if def.stats then
		local stats = ''
		local colors = modObject.statColors or DEFAULT_STAT_COLORS
		
		for _, line in ipairs(def.stats) do
			local rawText = Etc.wrapText(line[1], (modObject.descWrapLimit or DEFAULT_WRAP_LIMIT) - 3)
			local text = Etc.colorizeTranslated(colors[line[2] or 2] or DEFAULT_STAT_COLORS[2], modObject.translate(rawText))
			
			stats = stats .. '\n\t' .. (modObject.bulletPointChar or DEFAULT_BULLET_CHAR) .. ' ' .. text
		end
		
		defTransformed.description = defTransformed.description .. '\n' .. stats
	end
	
	modObject.translate: addBreak()
	
	return nil
end)

local function getTexture (modObject, texture)
	local modName = modObject.texPrefix or modObject.name
	
	if texture == nil then return nil end
	
	if type(texture) == 'table' then
		if texture.scale and (not texture.align_style) then
			texture.align_style = 'world'
		end
		
		if not texture.name then
			texture.name = texture[1]
		end
		
		if texture.name ~= nil and not (texture.name: find '%.png' or texture.name: find '%.jpg' or texture.name: find '%[') then
			texture.name = modName .. '_' .. texture.name .. '.png'
		end
	else
		if not (texture: find '%.png' or texture: find '%.jpg' or texture: find '%[') then
			texture = modName .. '_' .. texture .. '.png'
		end
	end
	
	return texture
end

-- Allows grouping all textures together into one table
Etc.registerRawItemTransformer('textures', function (modObject, value, def, defTransformed)
	if value.wield then
		if type(value.wield) == 'table' then
			defTransformed.wield_image = getTexture(modObject, value.wield[1])
			defTransformed.wield_overlay = getTexture(modObject, value.wield[2])
		else
			defTransformed.wield_image = getTexture(modObject, value.wield)
		end
	end
	
	if value.inventory then
		if type(value.inventory) == 'table' then
			defTransformed.inventory_image = getTexture(modObject, value.inventory[1])
			defTransformed.inventory_overlay = getTexture(modObject, value.inventory[2])
		else
			defTransformed.inventory_image = getTexture(modObject, value.inventory)
		end
	end
	
	if value.palette then
		defTransformed.palette = getTexture(modObject, value.palette)
	end
	
	if value.node then
		defTransformed.tiles = {
			getTexture(modObject, value.node.top    or value.node.up    or value.node[1] or value.node.ends or value.node.all),
			getTexture(modObject, value.node.bottom or value.node.down  or value.node[2] or value.node.ends or value.node.all),
			getTexture(modObject, value.node.right  or value.node.east  or value.node[3] or value.node.sides or value.node.all),
			getTexture(modObject, value.node.left   or value.node.west  or value.node[4] or value.node.sides or value.node.all),
			getTexture(modObject, value.node.back   or value.node.north or value.node[5] or value.node.sides or value.node.all),
			getTexture(modObject, value.node.front  or value.node.south or value.node[6] or value.node.sides or value.node.all)
		}
	end
	
	if value.node_overlay then
		defTransformed.overlay_tiles = {
			getTexture(modObject, value.node_overlay.top    or value.node_overlay.up    or value.node_overlay[1] or value.node_overlay.ends or value.node_overlay.all) or '',
			getTexture(modObject, value.node_overlay.bottom or value.node_overlay.down  or value.node_overlay[2] or value.node_overlay.ends or value.node_overlay.all) or '',
			getTexture(modObject, value.node_overlay.right  or value.node_overlay.east  or value.node_overlay[3] or value.node_overlay.sides or value.node_overlay.all) or '',
			getTexture(modObject, value.node_overlay.left   or value.node_overlay.west  or value.node_overlay[4] or value.node_overlay.sides or value.node_overlay.all) or '',
			getTexture(modObject, value.node_overlay.back   or value.node_overlay.north or value.node_overlay[5] or value.node_overlay.sides or value.node_overlay.all) or '',
			getTexture(modObject, value.node_overlay.front  or value.node_overlay.south or value.node_overlay[6] or value.node_overlay.sides or value.node_overlay.all) or ''
		}
	end
	
	if value.node_special then
		defTransformed.special_tiles = {
			getTexture(modObject, value.node_special.top    or value.node_special.up    or value.node_special[1] or value.node_special.ends or value.node_special.all),
			getTexture(modObject, value.node_special.bottom or value.node_special.down  or value.node_special[2] or value.node_special.ends or value.node_special.all),
			getTexture(modObject, value.node_special.right  or value.node_special.east  or value.node_special[3] or value.node_special.sides  or value.node_special.all),
			getTexture(modObject, value.node_special.left   or value.node_special.west  or value.node_special[4] or value.node_special.sides  or value.node_special.all),
			getTexture(modObject, value.node_special.back   or value.node_special.north or value.node_special[5] or value.node_special.sides  or value.node_special.all),
			getTexture(modObject, value.node_special.front  or value.node_special.south or value.node_special[6] or value.node_special.sides  or value.node_special.all)
		}
	end
	
	return nil
end)

-- Holds group keys that should automatically imply other groups
Etc.groupImplicationMappings = {
	unlisted = {'not_in_creative_inventory'},
	simple_pick = {'oddly_breakable_by_hand'},
	flower = {'plant'},
	mushroom = {'plant', 'fungus'},
	fungus = {'plant'},
	leaf = {'plant'},
	leaves = {'plant'},
	sapling = {'plant'},
	seedling = {'plant'},
	crop = {'plant'},
	disable_repair = {'no_repair'}
}

function Etc.registerGroupImplication (base, ...)
	Etc.groupImplicationMappings[base] = Etc.groupImplicationMappings[base] or {}
	
	for _, v in ipairs {...} do
		table.insert(Etc.groupImplicationMappings[base], v)
	end
end

Etc.registerRawItemTransformer('groups', function (modObject, value, def, defTransformed)
	local newValue = table.copy(value)
	
	for name, rating in pairs(value) do
		if Etc.groupImplicationMappings[name] then
			for _, imp in ipairs(Etc.groupImplicationMappings[name]) do
				newValue[imp] = rating
			end
		end
	end
	
	return newValue
end)

Etc.registerRawItemTransformer('aliases', function (modObject, value, def, defTransformed, itemName)
	for _, alias in pairs(value) do
		core.register_alias(alias, itemName)
		
		if not alias: find ':' then
			core.register_alias(modObject.name .. ':' .. alias, itemName)
		end
	end
end)
