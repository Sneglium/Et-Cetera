
local ui = minetest.global_exists 'unified_inventory'

local fuel_recipes
if minetest.settings: get_bool('etc.more_recipes_fuel', true) then
	if ui then
		unified_inventory.register_craft_type('etcetera:fuel', {
			description = 'Furnace Fuel',
			icon = 'default_furnace_front_active.png^[verticalframe:8:4',
			width = 1,
			height = 1,
			dynamic_display_size = function(craft)
				return {width = 1, height = 1}
			end,
			uses_crafting_grid = false
		})
	end
	
	fuel_recipes = true
end

local loot_recipes
if minetest.settings: get_bool('etc.more_recipes_loot', true) then
	if ui then
		unified_inventory.register_craft_type('etcetera:loot', {
			description = 'Dungeon Loot',
			icon = 'default_chest_front.png',
			width = 1,
			height = 1,
			dynamic_display_size = function(craft)
				return {width = 1, height = 1}
			end,
			uses_crafting_grid = false
		})
	elseif i3 then
		i3.register_craft_type('etcetera:loot', {
			description = 'Dungeon Loot',
			icon = 'default_chest_front.png',
		})
	end
	
	loot_recipes = true
end

local ore_recipes
if minetest.settings: get_bool('etc.more_recipes_ore', true) then
	if ui then
		unified_inventory.register_craft_type('etcetera:ore', {
			description = 'Ore Generation',
			icon = 'default_stone.png^default_mineral_iron.png',
			width = 1,
			height = 1,
			dynamic_display_size = function(craft)
				return {width = 1, height = 1}
			end,
			uses_crafting_grid = false
		})
	elseif i3 then
		i3.register_craft_type('etcetera:ore', {
			description = 'Ore Generation',
			icon = 'default_stone.png^default_mineral_iron.png',
		})
	end
	
	ore_recipes = true
end

minetest.after(0, function()
	if fuel_recipes then
		for item, _ in pairs(minetest.registered_items) do
			local result = minetest.get_craft_result {
				method = 'fuel',
				width = 1,
				items = {item}
			}
			
			if result and result.time and result.time > 0 then
				if ui then
					unified_inventory.register_craft({
						type   = 'etcetera:fuel',
						output = etc.get_time_rep_stack('Burn Time (Seconds)', result.time or 1),
						items  = {item},
						width  = 1
					})
				end
			end
		end
	end
	
	if loot_recipes and dungeon_loot then
		local loot_total = #dungeon_loot.registered_loot
		for _, loot in pairs(dungeon_loot.registered_loot) do
			local conds = {}
			
			if loot.y then
				table.insert(conds, 'Y Level ' .. (loot.y[1] >= -100 and ('>= ' .. loot.y[1]) or ('<= ' .. loot.y[2])))
			end
			
			if loot.types then
				table.insert(conds, 'Dungeon Types: '.. table.concat(loot.types, '; '))
			end
			
			if loot.count then
				table.insert(conds, 'Count: '..loot.count[1]..'-'..loot.count[2])
			end
			
			if ui then
				unified_inventory.register_craft({
					type   = 'etcetera:loot',
					output = loot.name,
					items  = {etc.get_chance_rep_stack(loot.chance and ((loot.chance/loot_total)*dungeon_loot.STACKS_PER_CHEST_MAX) or 0, 'Per Chest of '..dungeon_loot.CHESTS_MIN..'-'..dungeon_loot.CHESTS_MAX..' Chests', conds)},
					width  = 1
				})
			elseif i3 then
				i3.register_craft {
					type   = 'etcetera:loot',
					result = loot.name,
					items  = {etc.get_chance_rep_stack(loot.chance and ((loot.chance/loot_total)*dungeon_loot.STACKS_PER_CHEST_MAX) or 0, 'Per Chest of '..dungeon_loot.CHESTS_MIN..'-'..dungeon_loot.CHESTS_MAX..' Chests', conds):to_string()}
				}
			end
		end
	end
	
	if ore_recipes then
		for _, ore in pairs(minetest.registered_ores) do
			local conds = {}
			
			if ore.y_min > -31000 then
				table.insert(conds, 'Y Level >= '..ore.y_min)
			end
			
			if ore.y_max < 31000 then
				table.insert(conds, 'Y Level <= '..ore.y_max)
			end
			
			if ore.biomes then
				table.insert(conds, 'Biome Types: ' .. (type(ore.biomes) == 'table' and table.concat(ore.biomes, '; ') or ore.biomes))
			end
			
			if ore.wherein then
				table.insert(conds, 'Spawns In: ' .. (type(ore.wherein) == 'table' and table.concat(ore.wherein, '; ') or ore.wherein))
			end
			
			local chance = 1
			
			if ore.clust_scarcity and (ore.clust_num_ores or ore.clust_size) then
				local volume = ore.clust_size and math.floor((4/3)*((math.pi*(ore.clust_size/2))^2))
				
				chance = (1/ore.clust_scarcity)*(ore.clust_num_ores or volume)
				
				table.insert(conds, 'Count: ~' .. (ore.clust_num_ores or volume))
			end
			
			if ore.noise_params and ore.ore_type == 'scatter' or ore.ore_type == 'vein' then
				local threshold = ore.noise_threshold or 0
				
				if ore.noise_params.scale <= threshold and ore.noise_params.offset >= threshold then
					chance = 1
				else
					local negative_part = math.abs(math.min(threshold, ore.noise_params.offset - ore.noise_params.scale))
					local positive_part = math.abs(math.max(threshold, ore.noise_params.offset + ore.noise_params.scale))
					chance = chance * positive_part / (negative_part + positive_part)
				end
			end
			
			if ui then
				unified_inventory.register_craft({
					type   = 'etcetera:ore',
					output = ore.ore,
					items  = {etc.get_chance_rep_stack(chance, 'To Spawn Cluster', conds)},
					width  = 1
				})
			elseif i3 then
				i3.register_craft {
					type   = 'etcetera:ore',
					result = ore.ore,
					items  = {etc.get_chance_rep_stack(chance, 'To Spawn Cluster', conds):to_string()}
				}
			end
		end
	end
end)
