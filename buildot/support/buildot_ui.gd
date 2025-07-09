# User interface handling for row of icons and other plug handling for Buildot
extends Node

# Module icons and scenes are loaded from this directory:
@export var module_dir := "res://buildot/modules"

# Module icons are added to this UI HBox
@onready var module_icons : HBoxContainer = $"%ModuleIcons"


# The currently selected plug, where the next module will be added
@export var active_plug : BuildotPlug = null


# The camera we should move to look at the new UI elements (or null to not move)
@export var camera : Camera3D = null

# Offset vector from the active plug to the camera (global coords)
@export var camera_offset : Vector3 = Vector3(3,5,5)

# Fraction of new camera position to blend in per second
@export var camera_blend_rate : float = 0.5

# Current camera look target
@export var camera_target : Vector3 = Vector3(0,0,0)


func _ready():
	load_module_icons()

# Make this the new active plug, updating UI elements
func set_active_plug(plug):
	# Deactivate the previously active plug
	active_plug.visible = false
	active_plug = plug
	active_plug.visible = true
	load_module_icons()

# Read active_plug and create matching module build icons
func load_module_icons():
	var dirlist := ResourceLoader.list_directory(module_dir) 
	if not dirlist:
		push_error("Failed to open directory: %s" % module_dir)
		return
	
	# Remove the old children
	for n in module_icons.get_children():
		module_icons.remove_child(n)
		n.queue_free()
	
	# Add an icon for each module
	for file_name in dirlist: 
		if file_name.ends_with(".tscn"):
			var base : String = file_name.get_basename()
			
			# FIXME: before adding a button, check if active_plug mates to this module's base plug
			
			var button := Button.new()
			button.tooltip_text = base
			
			var png_path = module_dir + "/" + base + ".png"
			var png_texture: Texture = load(png_path)
			if png_texture:
				button.icon = png_texture

			button.pressed.connect(_on_button_pressed.bind(module_dir + "/" + file_name))
			module_icons.add_child(button)

# Callback when a module icon is pressed
func _on_button_pressed(module_path: String):
	var module_res : Resource = load(module_path)
	if not module_res:
		push_error("Failed to load module scene: %s" % module_res)
		return
	var module : Node3D = module_res.instantiate()
	get_tree().current_scene.add_child(module)
	
	var base_plug = module.get_node("base")
	BuildotPlug.mate(active_plug,base_plug)
	base_plug.visible = false # once mated, no point in showing onscreen
	
	for next in module.get_node("plugs").get_children():
		set_active_plug(next)

# Animate camera to look at the active plug (if both exist)
func _process(delta : float):
	if camera == null or active_plug == null:
		return
	
	var target : Vector3 = active_plug.global_position
	var cur : Vector3 = camera.global_position
	var next : Vector3 = target + camera_offset
	var rate : float = exp(-delta * camera_blend_rate)
	var blend : Vector3 = cur*(rate) + next*(1.0-rate)
	camera_target = camera_target*(rate) + target*(1.0-rate)
	camera.look_at_from_position(blend,camera_target)
