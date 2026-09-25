extends Node3D
## Builds collision for the imported room and wires up the floor tiles and the electric lights (toggle with L).

const TILE := 0.75
const NO_COLLISION_PREFIXES := ["Far_", "Opp_", "Street_", "Ground_", "Window_Glass", "Blind_"]

@onready var room: Node3D = $Room
@onready var lights: Node3D = $ElectricLights


func _ready() -> void:
	var floor_mat := ShaderMaterial.new()
	floor_mat.shader = load("res://floor_tiles.gdshader")
	for n in room.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := n as MeshInstance3D
		if mesh_node.name.begins_with("Floor_"):
			mesh_node.material_override = floor_mat
		if not _skip_collision(mesh_node.name):
			mesh_node.create_trimesh_collision()
	lights.visible = false
	# Afternoon sun about 40 degrees up, coming in from the window side (the window faces west-southwest, toward -Z).
	$Sun.look_at_from_position(Vector3(2.0, 17.0, -20.0), Vector3.ZERO)


func _skip_collision(node_name: String) -> bool:
	for p in NO_COLLISION_PREFIXES:
		if node_name.begins_with(p):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_L:
		lights.visible = not lights.visible
