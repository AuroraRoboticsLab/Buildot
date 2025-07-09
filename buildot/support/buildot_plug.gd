# A Buildot Plug connects two modules together
#  Mostly exists for the various properties, nothing at runtime (for efficiency)
class_name BuildotPlug
extends Node3D

# Determines rotation allowed by two connected plugs
enum Orient {
	FIXED, # no rotation allowed (default)
	SPIN, # rotation along Z axis only
	FREE, # free rotation along all axes
}
@export var plug_orient : Orient = Orient.FIXED

# Determines minimum rotation change, in degrees (may be zero)
#   (E.g., plug_orient = ORIENT_2D and plug_deg = 90 allows 4 orientations)
@export var plug_deg : float = 0

# Lists the plugs that will mate to us, as (parent) class string names.
#  This allows distinct male/female plug types.
#  If this array is empty, then this plug only mates to itself.
@export var mate_list : Array[String] = []

# Add icons for each matching module

# Move this child module's base node to match this 'parent' plug.
#  Ends up with child_baseplug directly on top of parent_plug.
static func mate(parent_plug : BuildotPlug, child_baseplug : BuildotPlug) -> void:
	# Look up the source module that we want to move
	var child_mod : Node3D = child_baseplug.get_parent()
	
	var t = parent_plug.global_transform # we start at the parent
	t = t*child_baseplug.transform.affine_inverse() # back out from our child plug orientation
	child_mod.global_transform = t # apply that transform
