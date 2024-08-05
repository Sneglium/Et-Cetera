# ETC: Mortar & Pestle API

The mortar and pestle module provides the following functions:

### register_mortar_recipe
**Usage**: `etc.register_mortar_recipe(input, output, hits, use_plant_sound)`

Adds a new recipe to be crafted with the mortar and pestle. Accepts the following parameters:

 - \[1\] `input` (itemstring): The item that must be placed in the mortar in order to craft the recipe. Must have a count of 1.
 - \[2\] `output` (itemstring): The resultant item that will replace the input item in the mortar once the crafting operation is complete. May have a count higher than one; oversized stacks at the end of the operation will be split into correctly sized ones when removed by the player.
 - \[3\] `hits` (integer): A fuzzy metric for the average number of hits with the pestle it will take to complete this recipe. This becomes less and less accurate as stack size increases, due to a 25% reduction of itemstack size when making the calculation. For example, `ceil(1 - 25%) = 1`, but `ceil(99 - 25%) = 75`.
 - \[4\] `use_plant_sound` (boolean): If set to true, each hit will make a mushier "plant" sound rather than the usual crunchy gravelly sound.
