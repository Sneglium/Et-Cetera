# ETC: Corrosion API

The corrosion module provides the following functions:

### add_metal_block
**Usage**: `etc.corrosion.add_metal_block(item, texname)`

Adds a metal block to the list of nodes for the corrosion ABM and creates 4 variants corroded at different levels. Accepts the following parameters:

 - \[1\] `item` (itemstring): The node that should be made corrodable. This node should have only one tile and use the `normal` drawtype (=nil) for best results. This itemstring must have no count, wear, or metadata specified.
 - \[2\] `texname` (string): The texture to use for the fully corroded version of the node. The other three variants will have generated textures based on this created with a mask. If not specified, the steel block corrosion texture will be used which will result in most or all of your fully-corroded nodes looking nearly identical.

_**NOTE:** Make sure to research the material you're adding! Not all metals readily corrode, and those that do won't usually have the same red-brown color that iron oxide does!_
