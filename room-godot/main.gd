extends Node3D
## Builds collision for the imported room, replaces the flat glTF colours with world-position shaders
## (plaster, striped door, speckled worktop, facades, floor tiles) and wires up the electric lights (toggle with L).

const NO_COLLISION_PREFIXES := ["Far_", "Opp_", "Street_", "Ground_", "Window_Glass", "Blind_", "D_Tree", "D_Lamp", "D_Car", "D_Curtain"]

# Facade look per glTF material: wall colour, trim colour, window pitch (m), window size (m).
const FACADES := {
	"Fac_Cream": [Color("e2d3b0"), Color("f2ead6"), Vector2(2.0, 3.0), Vector2(1.0, 2.0)],
	"Fac_Orange": [Color("c9622a"), Color("d98a55"), Vector2(1.7, 3.0), Vector2(1.6, 1.3)],
	"Fac_Beige": [Color("d9c3a3"), Color("ece0cc"), Vector2(1.8, 3.0), Vector2(0.9, 1.4)],
	"Fac_White": [Color("e8e4dc"), Color("f6f3ee"), Vector2(2.0, 3.0), Vector2(1.2, 1.7)],
	"Fac_Pink": [Color("c98f78"), Color("e3b9a5"), Vector2(2.2, 3.0), Vector2(1.1, 1.8)],
}

@onready var room: Node3D = $Room
@onready var lights: Node3D = $ElectricLights

var _shared: Dictionary = {}


func _ready() -> void:
	_build_shared_materials()
	for n in room.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := n as MeshInstance3D
		_apply_materials(mesh_node)
		if mesh_node.name == "Window_Glass" or mesh_node.name.begins_with("Blind_"):
			mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF  # transparent, must not block the sun
		if not _skip_collision(mesh_node.name):
			mesh_node.create_trimesh_collision()
	lights.visible = false
	# Afternoon sun about 40 degrees up, coming in from the window side (the window faces west-southwest, toward -Z).
	$Sun.look_at_from_position(Vector3(2.0, 17.0, -20.0), Vector3.ZERO)


func _shader_mat(path: String, params: Dictionary) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load(path)
	for k in params:
		m.set_shader_parameter(k, params[k])
	return m


func _build_shared_materials() -> void:
	var plaster := "res://shaders/plaster.gdshader"
	_shared["Wall"] = _shader_mat(plaster, {"base_color": Color("a7a3a2")})
	_shared["Ceiling"] = _shader_mat(plaster, {"base_color": Color("c7c3bd"), "grain_contrast": 0.12, "bump_strength": 0.002})
	_shared["Soffit"] = _shared["Ceiling"]
	_shared["Door"] = _shader_mat("res://shaders/door.gdshader", {})
	_shared["CounterTop"] = _shader_mat("res://shaders/counter_top.gdshader", {})
	_shared["Floor"] = _shader_mat("res://floor_tiles.gdshader", {})


func _apply_materials(mesh_node: MeshInstance3D) -> void:
	var mesh := mesh_node.mesh
	if mesh == null:
		return
	for s in mesh.get_surface_count():
		var src := mesh.surface_get_material(s)
		if src == null:
			continue
		var key := src.resource_name
		if _shared.has(key):
			mesh_node.set_surface_override_material(s, _shared[key])
		elif FACADES.has(key) and not mesh_node.name.contains("ledge"):
			mesh_node.set_surface_override_material(s, _facade_material(mesh_node, FACADES[key]))


func _facade_material(mesh_node: MeshInstance3D, cfg: Array) -> ShaderMaterial:
	var box := mesh_node.global_transform * mesh_node.get_aabb()
	return _shader_mat("res://shaders/facade.gdshader", {
		"wall_color": cfg[0],
		"trim_color": cfg[1],
		"pitch": cfg[2],
		"win_size": cfg[3],
		"x_min": box.position.x,
		"x_max": box.end.x,
		"top_y": box.end.y,
	})


func _skip_collision(node_name: String) -> bool:
	for p in NO_COLLISION_PREFIXES:
		if node_name.begins_with(p):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_L:
		lights.visible = not lights.visible
