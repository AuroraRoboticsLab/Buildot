# Shows how to mate two plugs
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BuildotPlug.mate($"../L_truss/plugs/next", $"../L_truss2_curve/base" )
	BuildotPlug.mate($"../L_truss2_curve/plugs/next", $"../L_truss3_straight/base" )
