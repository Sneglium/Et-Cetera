
local retexture = minetest.settings: get_bool('etc.fluid_bottles_retexture', true)

etc.bottle_fluids = {
	['default:water_source'] = 'etc:bottle_water',
	['default:river_water_source'] = 'etc:bottle_water'
}

etc: register_node('bottle_water', {
	displayname = 'Glass Bottle (Water)',
	inventory_image = table.concat {
		(retexture and 'etc_bottle_water.png' or 'etc_bottle_water_old.png'),
		'^',
		(retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png')
	},
	tiles = {table.concat {
		(retexture and 'etc_bottle_water.png' or 'etc_bottle_water_old.png'),
		'^',
		(retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png')
	}},
	use_texture_alpha = 'blend',
	drawtype = 'plantlike',
	paramtype = 'light',
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_glass_defaults()
})

if minetest.settings: get_bool('etc.fluid_bottles_lava_bottle', true) then
	etc.bottle_fluids['default:lava_source'] = 'etc:bottle_lava'
	
	local lava_bottle_def = {
		displayname = 'Glass Bottle (Lava)',
		inventory_image = table.concat {
		(retexture and 'etc_bottle_lava.png' or 'etc_bottle_lava_old.png'),
		'^',
		(retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png')
	},
		tiles = {table.concat {
		(retexture and 'etc_bottle_lava.png' or 'etc_bottle_lava_old.png'),
		'^',
		(retexture and 'etc_glass_bottle.png' or 'vessels_glass_bottle.png')
	}},
		use_texture_alpha = 'blend',
		drawtype = 'plantlike',
		paramtype = 'light',
		is_ground_content = false,
		walkable = false,
		selection_box = {
			type = 'fixed',
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
		},
		groups = {dig_immediate = 3, attached_node = 1},
		light_source = minetest.settings: get 'etc.fluid_bottles_lava_bottle_light_source' or 8,
		sounds = default.node_sound_glass_defaults()
	}
	
	if minetest.settings: get_bool('fluid_bottles_lava_bottle_throwable', true)  and minetest.get_modpath 'fire' then
		minetest.register_entity('etcetera:lava_bottle', {
			initial_properties = {
				physical = false,
				pointable = false,
				visual = 'wielditem',
				visual_size = {x = 0.25, y = 0.25, z = 0.25},
				wield_item = 'etcetera:bottle_lava',
				static_save = false
			},

			on_step = function(self, dtime, moveresult)
				local ent = self.object
				local rot = ent: get_rotation()
				ent: set_rotation(rot + vector.new(math.random() * math.pi * 0.1, math.random() * math.pi * 0.1, math.random() * math.pi * 0.1))
				
				if minetest.get_node(ent: get_pos()).name and minetest.registered_nodes[minetest.get_node(ent: get_pos()).name].walkable then
					local pos = minetest.find_node_near(ent: get_pos(), 1, 'air')
					
					if not self._owner or minetest.is_protected(pos, self._owner) then
						ent: remove()
						return
					end
					
					if pos then
						minetest.set_node(pos, {name = 'fire:basic_flame'})
					end
					
					ent: remove()
					
					minetest.sound_play({name = 'default_break_glass'}, {pos = pos})
					minetest.sound_play({name = 'fire_extinguish_flame'}, {pos = pos})
				end
			end
		})
		
		lava_bottle_def.on_use = function (itemstack, user, pointed_thing)
			local pos_offset = vector.new(0, 1.5, 0) + user: get_pos() + user: get_look_dir()*1.1
			
			local obj = minetest.add_entity(pos_offset, 'etcetera:lava_bottle')
			obj: add_velocity(user: get_velocity() + user: get_look_dir() * 20)
			obj: set_acceleration(user: get_look_dir() * -2 + vector.new(0, -15, 0))
			
			local luaent = obj: get_luaentity()
			luaent._owner = user: get_player_name()
			
			itemstack: take_item(1)
			return itemstack
		end
	end
	
	etc: register_node('bottle_lava', lava_bottle_def)
end

local old_on_use = minetest.registered_items['vessels:glass_bottle'].on_use

minetest.override_item('vessels:glass_bottle', {
	tiles = retexture and {'etc_glass_bottle.png'} or {'vessels_glass_bottle.png'},
	inventory_image = retexture and 'etc_glass_bottle.png' or 'fireflies_bottle.png',
	wield_image = retexture and 'etc_glass_bottle.png' or 'fireflies_bottle.png',
	use_texture_alpha = 'blend',
	liquids_pointable = true,
	on_use = function (itemstack, user, pointed_thing)
		if old_on_use then
			local item, success = old_on_use(itemstack, user, pointed_thing)
			if success then
				return item
			end
		end
		
		if pointed_thing.type == 'node' then
			local node = minetest.get_node(pointed_thing.under)
			if etc.bottle_fluids[node.name] then
				if itemstack: get_count() == 1 then
					itemstack: set_name(etc.bottle_fluids[node.name])
				else
					etc.give_or_drop(user, user: get_pos() + user: get_look_dir(), ItemStack(etc.bottle_fluids[node.name]))
					itemstack: take_item(1)
				end
				return itemstack
			elseif node.name == 'etcetera:apiary_full' or node.name == 'etcetera:apiary_half' then
				return minetest.registered_nodes[node.name].on_punch(pointed_thing.under, node, user, pointed_thing)
			end
		end
	end
})

if minetest.get_modpath 'fireflies' then
	minetest.override_item('fireflies:firefly_bottle', {
		use_texture_alpha = 'blend',
		inventory_image = retexture and 'etc_fireflies_bottle.png' or 'fireflies_bottle.png',
		wield_image = retexture and 'etc_fireflies_bottle.png' or 'fireflies_bottle.png',
		tiles = {{
			name = retexture and 'etc_fireflies_bottle_animated.png' or 'fireflies_bottle_animated.png',
			animation = {
				type = 'vertical_frames',
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}},
	})
end
