# ETC: Anvil API

The anvil module provides the following functions:

### register_anvil_recipe
**Usage**: `etc.register_anvil_recipe(input, output, hits)`

Adds a new recipe to be crafted with the anvil. Accepts the following parameters:

 - \[1\] `input` (itemstring): The item that should be placed on the anvil by the player. Must have a count of 1.
 - \[2\] `output` (itemstring): The resultant item that will replace the input item on the anvil once the crafting operation is complete. May have a count higher than one; oversized stacks at the end of the operation will be split into correctly sized ones when removed by the player.
 - \[3\] `hits` (integer): The recipe will take this many hit multiplied by the input stacksize to complete.. Correlates directly to hammer wear.

## Notes
The anvil will not repair tools with the following groups:

 - `no_repair`
 - `powertool`

Or the following definition fields:

 - `wear_represents`

This allows the registration of pseudo-tools, such as Technic's power tools or Etc chalk and watering can.
