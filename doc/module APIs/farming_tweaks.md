# ETC: Farming Tweaks API

The farming tweaks module provides the following functions:

## add_metal_block
**Usage**: `etc.farming_tweaks.register_plant(name_prefix, stages, seed, guide_node, compost_value)`

Adds a set of plant nodes to work with farming tweaks' features. All the names of the nodes should be formatted like `modname:name_prefix_<n>` where `<n>` is a number starting with 1 and ending with the number of stages.

 - \[1\] `name_prefix` (string): A prefix for the nodenames of each plant
 - \[2\] `stages` (string): How many growth stages does this plant have
 - \[3\] `seed` (string): The node that acts as the seed for this plant
 - \[4\] `guide_node` (string, optional): An additional node (such as a frame the plant grows on) that should not be returned on rightclick-harvest
 - \[5\] `compost_value` (number): How many units of compost does this plant convert into
