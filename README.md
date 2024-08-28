# Et Cetera

### A general-purpose library mod for the Minetest engine


Et Cetera is a combination of two types of library:

 - A library of miscellaneous tweaks and gameplay features (primarily targeted at Minetest Game) for players to play with and for mod devs to use as crafting dependencies;
 - A library of common code with no singular primary purpose, though mainly useful for automating the creation of various kinds of mod boilerplate.

Et Cetera (abbreviated Etc from hereon) is divided into "Modules", which can be configured or disabled independently from the main settings menu. The <u>gameplay</u> features of Etc are listed below organized by module.

When an enabled module's dependencies are unsatisfied, it will disable itself and (optionally, see settings) log a warning.

A comprehensive reference to the APIs and utilities provided to mod and game developers can be found in the `doc/` directory, starting with `doc/main.html`. This doc is meant to be viewed in the browser, and makes use of CSS and JavaScript. References for the mini-APIs provided by individual modules can be found under `doc/module APIs/`.  

(*Quick Note: Itemnames below use the `etc:` prefix, which is an alias. `etcetera:` is the registered prefix, but `etc:item_name` and `etcetera:item_name` are both defined for all items.*)

## General Settings

*Library Mode* (`etc.library_mode`, boolean): Disable all modules and only load the APIs and utilities depended on by other mods.

*Warn Missing Dependencies* (`etc.dependency_warning`, boolean): Log a warning when a module is enabled but missing dependencies.

## Modules

---
### Basic Resources

**Depends on:**

 - `default` (`minetest_game` Mod; optional)

The *Basic Resources* module (technical: `basic_resources`) provides a variety of simple craftitems made only with naturally generating resources from vanilla MTG. These items are meant to fill gaps in what is available in the base game for things that are likely to be needed by mods, for example glue, cloth, string, and so on. They are also used as crafting resources for other gameplay modules in Etc.  

This module is intended to be continually expanded and added to as necessary to provide for new modules or additions and changes to existing ones.

**List of Items:**

 - *Heavy Canvas* (`etc:canvas`): A tough all-purpose fabric.
 - *Oilcloth* (`etc:canvas_tarred`): A waterproofed version of Heavy Canvas.
 - *Powdered Flint* (`etc:flint_dust`): Sharp crushed up flint shards used to create sandpaper. Requires mortar & pestle to craft.
 - *Powdered Mese* (`etc:mese_dust`): Sharp crushed up mese shards used to create sandpaper. Requires mortar & pestle to craft.
 - *Powdered Diamond* (`etc:diamond_dust`): Sharp crushed up diamond shards used to create sandpaper. Requires mortar & pestle to craft.
 - *Pine Tar* (`etc:pine_tar`): Rendered pine sap. A precursor to Pitch and a serviceable glue for a variety of applications.
 - *Charcoal* (`etc:charcoal`): Carbonized wood, a fuel with similar efficiency to coal.
 - *Pine Pitch* (`etc:pine_pitch`): Carbon-imbued pine tar that acts as a powerful waterproofing agent and a strong glue.
 - *Acidic Extract* (`etc:acid`): A corrosive catalyst for dissolving and softening substances.
 - *Algin* (`etc:algin`): A blobby gelatinous substance similar to agar.
 - *Sandpapers*
	- *Poor, Ungraded* (`etc:sandpaper_0`): Low quality sandpaper made from raw silicate sand.
	- *Poor, Low Grit* (`etc:sandpaper_1`): Low-medium quality sandpaper made with flint powder.
	- *Great, Medium Grit* (`etc:sandpaper_2`): High quality sandpaper made with mese powder.
	- *Great, High Grit* (`etc:sandpaper_3`): High quality sandpaper made with diamond powder.
 - *Rough Twine* (`etc:string`): A bundle of heavy cordage made from twisted plant fibers. Requires mortar & pestle to craft.

**List of Settings:**

 - *Load Module: Basic Resources* (`etc.load_module_basic_resources`, boolean): Enable or disable the module entirely.
 - *Easy Flint Recipe* (`etc.basic_resources_easy_flint`, boolean): Enable crafting gravel into flint directly.

---
### Craft Grid Tools

**Depends on:**

 - `default` (`minetest_game` Mod; optional)

The *Craft Grid Tools* module (technical: `craft_tools`) includes five basic tools which, instead of being consumed, will lose a set amount of durability (gain _wear_) when crafted with. This behaviour does not require specifying `replacements` or similar in the recipe definition, and will always apply to any recipe using the crafting grid tools as long as it uses the built-in engine recipe system. Once a crafting tool runs out of durability it will break, however they can be repaired using the anvil and blacksmith's hammer if enabled.

**List of Items:**

 - *Metal File* (`etc:ct_file`): A file for rough shaping and facing of metal, stone, ceramic, wood, and so on.
 - *Metal Snips* (`etc:ct_cutters`): A pair of cutters capable of handling wire and sheetmetal, which are also suitable for other materials such as cord and fabric.
 - *Hand Drill* (`etc:ct_drill`): A brace-and-bit drill for boring holes in various materials.
 - *Sheeting Hammer* (`etc:ct_hammer`): A hammer with a wide flat face, good for flattening metal into sheets and general thwacking.
 - *Carving Knife* (`etc:ct_knife`): A small sturdy knife for whittling wood and all sorts of other cutting.

**List of Settings:**

 - *Load Module: Craft Grid Tools* (`etc.load_module_craft_tools`, boolean): Enable or disable the module entirely.
 - *Tool Durability* (`etc.craft_tools_num_uses`, integer): The maximum number of uses for craft tools other than the hammer.
 - *Hammer Durability* (`etc.craft_tools_hammer_num_uses`, integer): The maximum number of uses for the Sheeting Hammer.

---
### Wrought Iron

**Depends on:**

 - `default` (`minetest_game` Mod; required)

The *Wrought Iron* module (technical: `wrought_iron`) simply adds an ingot and block (with the expected interchange recipes) of a new material: Wrought Iron. this metal is intended to be decorative and a crafting ingredient, and is used in the anvil by default.

**List of Settings:**

 - *Load Module: Wrought Iron* (`etc.load_module_wrought_iron`, boolean): Enable or disable the module entirely.
 - *Dumber Crafting* (`etc.wrought_iron_dumb_crafting`, boolean): Replace the smelting recipe with a crafting grid recipe using a steel ingot and a coal lump. May be useful to resolve conflicts.

---
### Slime

**Depends on:**

 - `basic_resources` (Etc module; required)

The *Slime* module (technical: `slime`) adds slime balls and slime blocks. Slime balls are a general-purpose crafting ingredient, and slime blocks are a bouncy node which negate fall damage.

**List of Settings:**

 - *Load Module: Slime* (`etc.load_module_slime`, boolean): Enable or disable the module entirely.

---
### Treated Wood

**Depends on:**

 - `basic_resources` (Etc module; required)
 - `default` (`minetest_game` Mod; optional)

The *Treated Wood* module (technical: `treated_wood`) adds two new decorative wood plank nodes, which can be created by crafting any wood with pine tar or pitch.

**List of Settings:**

 - *Load Module: Treated Wood* (`etc.load_module_treated_wood`, boolean): Enable or disable the module entirely.

---
### Corrosion

**Depends on:**

 - `basic_resources` (Etc module; optional)
 - `default` (`minetest_game` Mod; required)
 - `technic` (Standalone mod; optional)
 - `unified_inventory` **OR** `i3` (Standalone mods; one or neither but not both - optional)

The *Corrosion* module (technical: `corrosion`) adds decorative versions of the default metal blocks which can be made by placing them in or near water, causing the metal to slowly corrode over time. It will also add variants for some of the technic metal blocks if present.

Corroded metal of any kind can be crafted with Acidic Extract from the basic resources module (if enabled) to remove the corrosion.

If Unified Inventory or I3 are present, corrosion will be visible as a recipe type in their respective crafting guides.

**List of Settings:**

 - *Load Module: Corrosion* (`etc.load_module_corrosion`, boolean): Enable or disable the module entirely.
 - *Corrosion Speed Multiplier* (`etc.corrosion_speed_mult`, floating-point): A multiplier for the average rate at which corrosion occurs.

---
### Bees

**Depends on:**

 - `craft_tools` (Etc module; optional)
 - `corrosion` (Etc module; optional)
 - `default` (`minetest_game` Mod; required)
 - `vessels` (`minetest_game` Mod; optional)
 - `fireflies` (`minetest_game` Mod; optional)

The *Bees* module (technical: `bees`) adds naturally spawning bees faithful to the MTG style (think butterflies and fireflies) that can be caught and farmed in an apiary for wax and honey.

In order to catch bees you will need to use the bug net from the `fireflies` mod (or a similar item with the ability to catch `catchable` nodes), however this module can load without it present.

To collect honey, the `vessels` mod is needed. Leftclick an empty glass bottle on an apiary with honey in it to collect it. Wax can be collected using the Carving Knife from the `craft_tools` module.

Bees will constantly produce wax, but will only produce honey during the day. They need flowers near their apiary and will remember which flowers they recently collected nectar from (the last two by default) and avoid those.

If the `corrosion` module is enabled, wax can be used to seal metal blocks and prevent them from corroding in the presence of water.

**List of Settings:**

 - *Load Module: Bees* (`etc.load_module_bees`, boolean): Enable or disable the module entirely.
 - *Honey Generation Rate* (`etc.bees_honey_rate`, floating-point): A multiplier for the average amount of honey generated every 10 seconds.
 - *Wax Generation Rate* (`etc.bees_wax_rate`, floating-point): A multiplier for the average amount of beeswax generated every 10 seconds.
 - *Apiary: Memory Length* (`etc.bees_memory_length`, integer): How many visited flowers can the apiary remember.
 - *Apiary: Search Radius* (`etc.bees_search_range`, integer): This radius defines a cube in which flowers will be looked for.
 - *Apiary: Capacity* (`etc.bees_capacity`, integer): How many units for wax and honey (each) a single apiary box can hold. A double box holds twice as much.

---
### Gems

**Depends on:**

 - Nothing

The *Gems* module (technical: `gems`) includes various gemstones, intended for use in recipes. If More Dungeon Loot is enabled, they can be found in dungeon chests; otherwise they are unobtainable by default.

**List of Items:**

 - *Quartz Crystal* (`etc:gem_quartz`): Part of the `quartz` group.
 - *Citrine Crystal* (`etc:gem_citrine`): Part of the `quartz` group.
 - *Rose Quartz Crystal* (`etc:gem_rose_quartz`): Part of the `quartz` group.
 - *Amethyst* (`etc:gem_amethyst`): Part of the `quartz` group.
 - *Tanzanite* (`etc:gem_tanzanite`)
 - *Scarlet Jasper* (`etc:gem_red_jasper`)
 - *Verdant Jasper* (`etc:gem_green_jasper`)
 - *Topaz* (`etc:gem_topaz`)
 - *Opal* (`etc:gem_opal`)

**List of Settings:**

 - *Load Module: Gems* (`etc.load_module_gems`, boolean): Enable or disable the module entirely.

---
### Item Cosmetic Stations

#### Labelling Bench

**Depends on:**

 - `default` (`minetest_game` Mod; optional)

The *Labelling Bench* submodule (technical: `labelling_bench`) provides a way for players to change the display-names and long descriptions of items. Includes only one item: the Labelling Bench node, which has a GUI for doing just that.

**List of Settings:**

 - *Load Module: Labelling Bench* (`etc.load_module_labelling_bench`, boolean): Enable or disable the module entirely.
 - *Labelling Bench: Use ChunkyDeco Workbench* (`etc.labelling_bench_use_chunkydeco`, boolean): If the ChunkyDeco mod is enabled, replaces the wood and sticks in the recipe with the `workbench` group (a workbench of any wood type).

#### Dyeing Table

**Depends on:**

 - `default` **AND** `dye` (`minetest_game` Mods; optional - both or neither)

The *Dyeing Table* submodule (technical: `coloring_bench`) provides a way for players to colorize the inventory images of items with custom RGB values. Includes only one item: the Dyeing Table node, which has a GUI for doing just that.

**List of Settings:**

 - *Load Module: Dyeing Table* (`etc.load_module_coloring_bench`, boolean): Enable or disable the module entirely.
 - *Dyeing Table: Use ChunkyDeco Workbench* (`etc.coloring_bench_use_chunkydeco`, boolean): If the ChunkyDeco mod is enabled, replaces the wood and sticks in the recipe with the `workbench` group (a workbench of any wood type).

---
### Mortar and Pestle

**Depends on:**

 - `basic_resources` (Etc module; required)
 - `unified_inventory` **OR** `i3` (Standalone mods; one or neither but not both - optional)
 - `technic` (Standalone mod; optional)
 - `default` (`minetest_game` Mod; optional)
 - `farming` (`minetest_game` Mod; optional)
 - `bucket` (`minetest_game` Mod; optional)
 - `flowers` **AND** `dye` (`minetest_game` Mods; optional - both or neither)

The *Mortar and Pestle* module (technical: `mortar_and_pestle`) adds a node-item pair which function as a crafting station specialized in crushing things. It provides useful recipes for many MTG items, and supports Technic grinder recipes. It is also used as the primary crafting station for a number of other Etc items.

Registered recipes and Technic grinder recipes (if enabled) will be visible in Unified Inventory or I3, if present.

Additionally, if enabled, a Dust node will be added which can be obtained by crushing sand and is used to craft clay and other items from Etc.

**List of Settings:**

 - *Load Module: Mortar and Pestle* (`etc.load_module_mortar_and_pestle`, boolean): Enable or disable the module entirely.
 - *Use Technic Recipes* (`etc.mortar_and_pestle_technic_support`, boolean): Allow the mortar and pestle to accept technic grinder recipes.
 - *Hardness Multiplier* (`etc.mortar_and_pestle_hardness_mult`, floating-point): A multiplier for the average number of hits it will take to complete a recipe.
 - *Enable Particles* (`etc.mortar_and_pestle_particles`, boolean): Enable or disable particles on hit with the pestle.
 - *Enable Dust* (`etc.load_module_dust`, boolean): Add a 'dust' node, which is made by crushing sand and can be used to create clay.

_**Note:** the `etc.load_module_dust` setting pertains to a module called `dust`, which is not listed separately for the sake of brevity._

---
### Duststone

**Depends on:**

 - `dust` (Etc module; required)
 - `stairs` (`minetest_game` Mod; optional)

The *Duststone* module (technical: `duststone`) includes various decorative `cracky` (stone-like) nodes based on dust, similar to sandstone from sand.

**List of Items:**

 - *Duststone* (`etc:duststone`): The base duststone node, made directly from dust.
 - *Duststone Bricks* (`etc:duststone_bricks`): Large half-node sized bricks similar to MTG stone bricks.
 - *Duststone Tile* (`etc:duststone_block`): A single large tile of duststone with a bevelled border.
 - *Ornate Duststone Tile* (`etc:duststone_block_chiselled`): A fancy decorative spiral of duststone.
 - *Duststone Quartertiles* (`etc:duststone_tiles`): Similar to Duststone Tile, but split in four small tiles.
 - *Duststone Column* (`etc:duststone_column`): A pair of vertically-oriented strips of duststone, for pillars or bordering windows and doors.

**List of Settings:**

 - *Load Module: Duststone* (`etc.load_module_duststone`, boolean): Enable or disable the module entirely.

---
### Anvil

**Depends on:**

 - `craft_tools` (Etc module; required)
 - `wrought_iron` (Etc module; optional)
 - `unified_inventory` **OR** `i3` (Standalone mods; one or neither but not both - optional)
 - `default` (`minetest_game` Mod; optional)

The *Anvil* module (technical: `anvil`) adds a node-item pair which allow for the balanced repairing of nearly any tool. The Anvil can also be used by other mods as a crafting station similar to the Mortar and Pestle.

When this module and the corresponding setting are enabled, digging tools (but not hoes or swords) will not disappear upon breaking. Instead they will become useless until repaired.  
WARNING: This option may play weirdly with tools made via a compound parts system or similar. Once rendered useless, they will permanently be in that state or at least lose their buffs.

**List of Settings:**

 - *Load Module: Anvil* (`etc.load_module_anvil`, boolean): Enable or disable the module entirely.
 - *Hammer Durability* (`etc.anvil_hammer_num_uses`, integer): How many times the Blacksmith's Hammer can hit an item before it breaks.
 - *Self-repairing Hammers* (`etc.anvil_circular_repair`, boolean): Allow hammers to repair other hammers, effectively making them unlimited once you have two or more.
 - *Repair Factor* (`etc.anvil_repair_factor`, floating-point): A multiplier for the number of "uses" of a given tool that will be repaired with a single hammer blow.
 - *Wrought Iron Recipe* (`etc.anvil_use_wrought_iron`, boolean): Use a wrought iron block in the anvil recipe instead of a steel block if the Wrought Iron module is enabled.
 - *Forgiving Tool Breakage* (`etc.anvil_prevent_tool_break`, boolean): Digging tools will not be destroyed when they reach 0 durability, and will instead become useless until repaired.
 - *Enable Particles* (`etc.anvil_particles`, boolean): Enable or disable particles on striking with the hammer.

---
### Chalk

**Depends on:**

 - `craft_tools` (Etc module; required)
 - `basic_resources` (Etc module; required)
 - `dust` (Etc module; optional)
 - `default` (`minetest_game` Mod; optional)
 - `dye` (`minetest_game` Mod; optional)

The *Chalk* module (technical: `chalk`) adds a few colored chalk sticks that can draw on any face of an eligible node. By default, a node is eligible if it is a full block and has a 'hard' digging group (for example, stone and wood planks are eligible but stone stairs are not). Chalk will normally not use durability when replacing a symbol of the same color, though this can be disabled.

**List of Settings:**

 - *Load Module: Chalk* (`etc.load_module_chalk`, boolean): Enable or disable the module entirely.
 - *Full Blocks Only* (`etc.chalk_cubes_only`, boolean): When enabled, chalk will only be able to draw on full cube nodes.
 - *Hard Nodes Only* (`etc.chalk_hard_only`, boolean): When enabled, chalk will only be able to draw on nodes with a `cracky` or `choppy` digging group.
 - *Free Re-Drawing* (`etc.chalk_free_switching`, boolean): Enable chalk to replace symbols of the same color without losing durability.
 - *Durability* (`etc.chalk_num_uses`, integer): How many symbols a single stick of chalk can draw.

---
### Fluid Bottles

**Depends on:**

 - `default` (`minetest_game` Mod; required)
 - `vessels` (`minetest_game` Mod; required)
 - `fire` (`minetest_game` Mod; optional)
 - `fireflies` (`minetest_game` Mod; optional)

The *Fluid Bottles* module (technical: `fluid_bottles`) allows water and lava (or just water, depending on your settings) to be collected in glass bottles. These fluid bottles can be placed, and the lava bottle can by default produce light and be thrown, causing fires on impact.

If the setting is enabled, this module will also replace the textures of the glass bottle from vessels and the firefly in a bottle from fireflies.

**List of Settings:**

 - *Load Module: Fluid Bottles* (`etc.load_module_fluid_bottles`, boolean): Enable or disable the module entirely.
 - *Lava Bottle* (`etc.fluid_bottles_lava_bottle`, boolean): Add a bottle of lava.
 - *Throwable Lava Bottle* (`etc.fluid_bottles_lava_bottle_throwable`, boolean): If enabled, allow players to throw the lava bottle and set fires from afar.
 - *Lava Bottle Light Level* (`etc.fluid_bottles_lava_bottle_light_source`, integer): How much light should the lava bottle produce when placed.
 - *Retexture Bottles* (`etc.fluid_bottles_retexture`, boolean): Replace the bottle textures from vessels & fireflies with a prettier version.

---
### All-In-One-Tools

**Depends on:**

 - `default` (`minetest_game` Mod; required)
 - `moreores` (Standalone mod; optional)

The *All-In-One-Tools* module (technical: `paxels`) adds a "Shpavel" for each basic tool material in MTG (and the More Ores mod if present and enabled) which acts as a combination Axe, Pickaxe and Shovel and is between the axe and sword in terms of attack damage.

**List of Settings:**

 - *Load Module: All-In-One-Tools* (`etc.load_module_paxels`, boolean): Enable or disable the module entirely.
 - *AIOT Damage Multiplier* (`etc.paxels_damage_mult`, floating-point): The percentage of the material's sword damage that the All-In-One Tool of the material should deal (rounds up).
 - *AIOT Durability Multiplier* (`etc.paxels_durability_mult`, floating-point): The All-In-One Tool's durability will be the sum of the durabilities of all the tools of the material type multiplied by this value (rounded up).
 - *All-In-One Tools for Moreores* (`etc.paxels_moreores`, boolean): Add AIOTs for moreores materials, if present.

---
### Falling Tweaks

**Depends on:**

 - `default` (`minetest_game` Mod; required)
 - `beds` (`minetest_game` Mod; optional)
 - `wool` (`minetest_game` Mod; optional)

The *Falling Tweaks* module (technical: `fall_tweaks`) changes some group values of various MTG nodes to do more or less damage to a player falling on them, and makes beds slightly bouncy. That's all.

**List of Settings:**

 - *Load Module: Falling Tweaks* (`etc.load_module_fall_tweaks`, boolean): Enable or disable the module entirely.
 - *Modify Beds* (`etc.fall_tweaks_beds`, boolean): Makes beds reduce fall damage by 50% and bounce the player slightly.
 - *Modify Leaves* (`etc.fall_tweaks_leaves`, boolean): Makes leaves reduce fall damage by 40%
 - *Modify Wool* (`etc.fall_tweaks_wool`, boolean): Makes wool reduce fall damage by 55%
 - *Modify Fences* (`etc.fall_tweaks_fence`, boolean): Makes fences and fence rails increase fall damage by 15%

---
### Sneaking Tweaks

**Depends on:**

 - Nothing.

The *Sneaking Tweaks* module (technical: `sneak_tweaks`) changes some mechanics around sneaking and adds new ones to make it feel more useful and immersive. Primarily, this module makes sneaking stealthier by disabling players' footstep sounds and hiding their nametags when sneaking. It also changes the camera height to indicate visually that you're in sneak mode. Lastly, it makes sneaking resist unwanted movement (ex. sliding on ice or being pushed by other objects).

Note that none of these changes will affect players with the `fly` privilege.

**List of Settings:**

 - *Load Module: Sneaking Tweaks* (`etc.load_module_sneak_tweaks`, boolean): Enable or disable the module entirely.
 - *Hide Nametag* (`etc.sneak_tweaks_hide_nametag`, boolean): Player names will no longer be visible when that player is sneaking.
 - *Silent Sneak* (`etc.sneak_tweaks_silent_sneak`, boolean): Players will no longer make any footstep noises when sneaking.
 - *Lower POV* (`etc.sneak_tweaks_lower_cam`, boolean): The camera will lower by a set amount while sneaking to make it visually obvious.
 - *Resist Movement* (`etc.sneak_tweaks_anti_slip`, boolean): Unless pressing a movement key, sneaking will allow players to reduce their movement speed in all directions while touching the ground.
 - *Reduce Hitbox Height* (`etc.sneak_tweaks_reduced_hitbox`, boolean): When sneaking the player's hitbox height will be reduced by a small amount, allowing them to sneak under smaller gaps than usual.

---
### More Dungeon Loot

**Depends on:**

 - `dungeon_loot` (`minetest_game` Mod; required)
 - `craft_tools` (Etc module; optional)
 - `bees` (Etc module; optional)
 - `slime` (Etc module; optional)
 - `wrought_iron` (Etc module; optional)
 - `anvil` (Etc module; optional)
 - `chalk` (Etc module; optional)
 - `basic_resources` (Etc module; optional)

The *More Dungeon Loot* module (technical: `more_loot`) adds a number or additional entries for the `dungeon_loot` MTG mod both for things from the base game and from various Etc modules. 

**List of Settings:**

 - *Load Module: More Dungeon Loot* (`etc.load_module_more_loot`, boolean): Enable or disable the module entirely.
 - *Craft Grid Tools* (`etc.more_loot_ct_tools`, boolean): Add craft grid tools as loot items.
 - *Honey* (`etc.more_loot_honey`, boolean): Add honey bottles and honey blocks as loot items.
 - *Slime* (`etc.more_loot_slime`, boolean): Add slimeballs as loot items.
 - *Wrought Iron* (`etc.more_loot_wrought_iron`, boolean): Add wrought iron ingots as loot items.
 - *Anvil & hammer* (`etc.more_loot_anvil`, boolean): Add the anvil and blacksmith's hammer as loot items.
 - *Chalk* (`etc.more_loot_chalk`, boolean): Add chalk sticks and pressed charcoal stick as loot items.
 - *Gems* (`etc.more_loot_gems`, boolean): Add gemstones from Etc as loot items.
 - *Basic Resources* (`etc.more_loot_basic_resources`, boolean): Add various resource items from Etc as loot items.
 - *MTG Items* (`etc.more_loot_misc`, boolean): Add various additional items from Minetest Game as loot items.

---
### Farming Tweaks

**Depends on:**

 - `farming` (`minetest_game` Mod OR standalone mod; required)
 - `default` (`minetest_game` Mod; required)
 - `moreores` (standalone mod; optional)

The *Farming Tweaks* module (technical: `farming_tweaks`) makes some changes to the crops system provided either by the MTG `farming` mod, or "Farming Redo". Primarily it allows harvesting and automatically replanting crops by right-clicking on them, and harvesting larger areas at once by right-clicking with a hoe.

It also adds some new nodes: a compost bin, which can be used to make _compost_ from plant materials; and compost itself which can be used as an alternative soil for growing plants on that boosts their growth rate. Compost (by default) will eventually lose its' fertility and 'exhaust', turning into plain dirt soil.

The _trowel_ item can be used to painlessly replace dirt or tilled soil with compost without breaking any plant that might be growing on top.

The _watering can_ item wets soil faster, slightly boosts crop growth and prevents exhaustion of compost for a set number of cycles. Hold leftclick while pointing at water to fill it, then again over your crops to water them. Its' durability bar represents how full it is; don't worry, it won't break!

**List of Settings:**

 - *Load Module: Farming Tweaks* (`etc.load_module_farming_tweaks`, boolean): Enable or disable the module entirely.
 - *Right-Click to Harvest* (`etc.farming_tweaks_rightclick_harvest`, boolean): Enable right-clicking crops to receive their drops and automatically replant them instead if they would have dropped a seed.
 - *Enable Composting* (`etc.farming_tweaks_compost`, boolean): Add a 'compost' node which acts as a higher-quality soil for crops, and a compost bin that can be used to make it.
 - *Compost Avg. Boost Interval* (`etc.farming_tweaks_compost_tickrate`, floating-point): The average amount of time in seconds between cycles of a compost node ticking the plant above it to grow. Non-wet compost soil will take 1.5x this long between cycles, on average.
 - *Fertility Exhaustion Chance* (`etc.farming_tweaks_compost_exhaust_chance`, integer): Every ticking cycle, compost will have 1 in this many chances to turn into regular dirt.
 - *Enable Trowel* (`etc.farming_tweaks_trowel`, boolean): Add a 'trowel' item that allows quickly replacing dirt/desert sand and the tilled variants of both with the compost version.
 - *Trowel Durability* (`etc.farming_tweaks_trowel_uses`, integer): How many dirt or sand nodes the trowel can replace before breaking.
 - *Compost Bin Interval* (`etc.farming_tweaks_compost_process_rate`, floating-point): Interval in seconds between compost processing cycles in the Compost Bin.
 - *Enable Watering Can* (`etc.farming_tweaks_watering_can`, boolean): Add a 'watering can' item that wets soil nodes faster, and helps the growth of crops slightly.
 - *Watering Can Capacity* (`etc.farming_tweaks_watering_can_limit`, integer): How many (approximately) pouring seconds worth of water the watering can can hold.
 - *Watering Can: Chance to Boost* (`etc.farming_tweaks_watering_can_boost_chances`, integer): The watering can has one in this many chances to boost the growth of a crop each step.
 - *Watering Can: Boost Limit* (`etc.farming_tweaks_watering_can_boost_max`, integer): The watering can will select this many crop nodes within its' radius to potentially boost each step.
 - *Watering Can: Exhaust Delay Limit* (`etc.farming_tweaks_watering_can_anti_exhaust_limit`, integer): The watering can will be capable of delaying the exhaustion of a compost node by at most this many cycles.
 - *Enable Particles* (`etc.farming_tweaks_particles`, boolean): Enable or disable particles for growth boosting and the watering can.

---
### Wood Type Variants

**Depends on:**

 - `default` (`minetest_game` Mod; required)
 - `doors` (`minetest_game` Mod; optional)
 - `stairs` (`minetest_game` Mod; optional)
 - `vessels` (`minetest_game` Mod; optional)

The *Wood Type Variants* module (technical: `wood_variants`) includes new variations of MTG 'wooden' nodes which only come in one flavour. The default behaviour is to rename the base version to 'applewood', and add new versions for each of the other four MTG wood types plus tarred and pitched wood if the `treated_wood` module is enabled.

**List of Settings:**

 - *Load Module: Wood Type Variants* (`etc.load_module_wood_variants`, boolean): Enable or disable the module entirely.
 - *Treated Wood Variants* (`etc.wood_variants_treated`, boolean): Enable or disable Treated Wood and Pitch-Sealed Wood variants of the enabled node types.
 - *Node Type: Shelves* (`etc.wood_variants_shelves`, boolean): Enable or disable wood variants of bookshelves and vessels shelves.
 - *Node Type: Ladders* (`etc.wood_variants_ladders`, boolean): Enable or disable wood variants of ladders.
 - *Node Type: Doors* (`etc.wood_variants_doors`, boolean): Enable or disable wood variants of doors and trapdoors.

---
### Door Tweaks

**Depends on:**

 - `doors` (`minetest_game` Mod; required)

The *Door Tweaks* module (technical: `door_tweaks`) makes a number of changes to the way doors work in MTG. By default, it does the following:

 - Open trapdoors are now climbable like ladders (this means they are not physical, however)
 - Doors open in pairs if placed in the 'double door' configuration.
 - Trapdoors open in a flat radius around the first trapdoor (by default, a maximum of a 5x5 area)

All of these can be configured.

**List of Settings:**

 - *Load Module: Door Tweaks* (`etc.load_module_door_tweaks`, boolean): Enable or disable the module entirely.
 - *Climbable Trapdoors* (`etc.door_tweaks_climb_trapdoors`, boolean): Trapdoors in their 'open' state will be non-physical and climbable like a ladder.
 - *Double Doors* (`etc.door_tweaks_double_doors`, boolean): Doors will open and shut in pairs.
 - *Collateral Trapdoors* (`etc.door_tweaks_connected_trapdoors`, boolean): Trapdoors will open/close in a flat radius.
 - *Collateral Trapdoors: Radius* (`etc.door_tweaks_connected_trapdoors_spread`, integer): The radius in which trapdoors will open collaterally. This is a square region, not a circle.

---
### More Recipe Types

**Depends on:**

 - `dungeon_loot` (`minetest_game` Mod; optional)
 - `unified_inventory` **OR** `i3` (Standalone mods; one or neither but not both - optional)

The *More Recipe Types* module (technical: `more_recipes`) adds custom recipe types in I3 or Unified Inventory for use as furnace fuel and generation as an ore, and if dungeon loot is enabled it will also add a type for generation as dungeon loot.

**List of Settings:**

 - *Load Module: More Recipe Types* (`etc.load_module_more_recipes`, boolean): Enable or disable the module entirely.
 - *Fuel Recipe Type* (`etc.more_recipes_fuel`, boolean): Add recipe type for fuel items.
 - *Dungeon Loot Recipe Type* (`etc.more_recipes_loot`, boolean): Add recipe type for dungeon loot.
 - *Ore Recipe Type* (`etc.more_recipes_ore`, boolean): Add recipe type for ore generation.

## Licensing
```
Et Cetera (etcetera) (c) 2024 Hagatha (Sneglium)  

License of code & data files (*.lua, *.conf, *.txt, *.html, *.css, *.js): Apache-2.0  
https://www.apache.org/licenses/LICENSE-2.0.txt  
see LICENSING/code.LICENSE  

License of media and other files (*.obj, *.ogg, *.png, *.tr, *.md): Attribution-ShareAlike 4.0 International  
https://creativecommons.org/licenses/by-sa/4.0/legalcode.txt  
see LICENSING/media.LICENSE  

Some files are under separate licenses. An individual license file called <file_name>.LICENSE will  
be provided in the directories containing these files, specifying the filenames, licenses, and attribution.
```
