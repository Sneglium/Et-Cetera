local damage_multiplier = minetest.settings: get 'etc.paxels_damage_mult' or 0.85
local durability_multiplier = minetest.settings: get 'etc.paxels_durability_mult' or 0.75

local function make_paxel (name, resource, pick, shovel, axe, sword)
	local displayname = name: sub(1,1): upper() .. name: sub(2,-1)
	
	local pick_def = table.copy(minetest.registered_items[pick].tool_capabilities)
	local shovel_def = table.copy(minetest.registered_items[shovel].tool_capabilities)
	local axe_def = table.copy(minetest.registered_items[axe].tool_capabilities)
	local sword_def = table.copy(minetest.registered_items[sword].tool_capabilities)
	
	local digging_groups = {
		snappy = sword_def.groupcaps.snappy,
		cracky = pick_def.groupcaps.cracky,
		choppy = axe_def.groupcaps.choppy,
		crumbly = shovel_def.groupcaps.crumbly
	}
	
	local durability = math.ceil(etc.sum_uses(pick, shovel, axe, sword) * durability_multiplier)
	
	for _, v in pairs(digging_groups) do v.uses = durability end
	
	etc.register_tool('paxel_'..name, {
		displayname = displayname .. ' Shpavel',
		inventory_image = 'etc_paxel_'..name..'.png',
		tool_capabilities = {
			max_drop_level = math.floor((pick_def.max_drop_level + shovel_def.max_drop_level + axe_def.max_drop_level + sword_def.max_drop_level)/4),
			full_punch_interval = sword_def.full_punch_interval,
			damage_groups = {fleshy = math.ceil(sword_def.damage_groups.fleshy*damage_multiplier)},
			groupcaps = digging_groups,
		}
	})
	
	minetest.register_craft {
		output = 'etc:paxel_'..name,
		recipe = {
			{pick, shovel, axe},
			{'', resource, ''},
			{'', 'default:stick', ''}
		}
	}
end

make_paxel('wooden', 'default:wood', 'default:pick_wood', 'default:shovel_wood', 'default:axe_wood', 'default:sword_wood')
make_paxel('stone', 'group:stone', 'default:pick_stone', 'default:shovel_stone', 'default:axe_stone', 'default:sword_stone')
make_paxel('bronze', 'default:bronze_ingot', 'default:pick_bronze', 'default:shovel_bronze', 'default:axe_bronze', 'default:sword_bronze')
make_paxel('steel', 'default:steel_ingot', 'default:pick_steel', 'default:shovel_steel', 'default:axe_steel', 'default:sword_steel')
make_paxel('mese', 'default:mese', 'default:pick_mese', 'default:shovel_mese', 'default:axe_mese', 'default:sword_mese')
make_paxel('diamond', 'default:diamond', 'default:pick_diamond', 'default:shovel_diamond', 'default:axe_diamond', 'default:sword_diamond')

if minetest.get_modpath 'moreores' and minetest.settings: get_bool('etc.paxels_moreores', true) then
	make_paxel('silver', 'moreores:silver_ingot', 'moreores:pick_silver', 'moreores:shovel_silver', 'moreores:axe_silver', 'moreores:sword_silver')
	make_paxel('mithril', 'moreores:mithril_ingot', 'moreores:pick_mithril', 'moreores:shovel_mithril', 'moreores:axe_mithril', 'moreores:sword_mithril')
end
