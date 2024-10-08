local module = {}

local damage_multiplier = minetest.settings: get 'etc.paxels_damage_mult' or 0.85
local durability_multiplier = minetest.settings: get 'etc.paxels_durability_mult' or 0.75

function module.make_paxel (name, resource, pick, shovel, axe, sword, custom_dur_mod)
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
	if custom_dur_mod then
		durability = math.floor(durability * custom_dur_mod)
	end
	
	for _, v in pairs(digging_groups) do v.uses = durability end
	
	etc: register_tool('paxel_'..name, {
		displayname = displayname .. ' Shpavel',
		inventory_image = 'etc_paxel_'..name..'.png',
		tool_capabilities = {
			max_drop_level = math.ceil((pick_def.max_drop_level + shovel_def.max_drop_level + axe_def.max_drop_level + sword_def.max_drop_level)/4),
			full_punch_interval = sword_def.full_punch_interval,
			damage_groups = {fleshy = math.ceil(sword_def.damage_groups.fleshy*damage_multiplier)},
			groupcaps = digging_groups,
		},
		groups = etc.merge(pick_def.groups or {pick = 1}, shovel_def.groups or {shovel = 1}, axe_def.groups or {axe = 1}, sword_def.groups or {sword = 1})
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

module.make_paxel('wooden', 'default:wood', 'default:pick_wood', 'default:shovel_wood', 'default:axe_wood', 'default:sword_wood')
module.make_paxel('stone', 'group:stone', 'default:pick_stone', 'default:shovel_stone', 'default:axe_stone', 'default:sword_stone')
module.make_paxel('bronze', 'default:bronze_ingot', 'default:pick_bronze', 'default:shovel_bronze', 'default:axe_bronze', 'default:sword_bronze')
module.make_paxel('steel', 'default:steel_ingot', 'default:pick_steel', 'default:shovel_steel', 'default:axe_steel', 'default:sword_steel')
module.make_paxel('mese', 'default:mese', 'default:pick_mese', 'default:shovel_mese', 'default:axe_mese', 'default:sword_mese')
module.make_paxel('diamond', 'default:diamond', 'default:pick_diamond', 'default:shovel_diamond', 'default:axe_diamond', 'default:sword_diamond')

if minetest.get_modpath 'moreores' and minetest.settings: get_bool('etc.paxels_moreores', true) then
	module.make_paxel('silver', 'moreores:silver_ingot', 'moreores:pick_silver', 'moreores:shovel_silver', 'moreores:axe_silver', 'moreores:sword_silver', 0.5)
	module.make_paxel('mithril', 'moreores:mithril_ingot', 'moreores:pick_mithril', 'moreores:shovel_mithril', 'moreores:axe_mithril', 'moreores:sword_mithril', 0.4)
end

return module
