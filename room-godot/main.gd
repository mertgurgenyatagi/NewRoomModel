extends Node3D
## Builds collision for the imported room, replaces the flat glTF colours with world-position shaders
## (plaster, striped door, speckled worktop, facades, floor tiles) and wires up the electric lights (toggle with L).

const GI_DATA := "res://lighting/voxel_gi.res"
const NO_COLLISION_PREFIXES := ["Far_", "Opp_", "Street_", "Ground_", "Window_Glass", "Blind_", "D_Tree", "D_Lamp", "D_Car", "D_Curtain"]

# Facade look per glTF material: wall colour, trim colour, window pitch (m), window size (m).
const FACADES := {
	"Fac_Cream": [Color("e2d3b0"), Color("f2ead6"), Vector2(2.0, 3.0), Vector2(1.0, 2.0)],
	"Fac_Orange": [Color("c9622a"), Color("d98a55"), Vector2(1.7, 3.0), Vector2(1.6, 1.3)],
	"Fac_Beige": [Color("d9c3a3"), Color("ece0cc"), Vector2(1.8, 3.0), Vector2(0.9, 1.4)],
	"Fac_White": [Color("e8e4dc"), Color("f6f3ee"), Vector2(2.0, 3.0), Vector2(1.2, 1.7)],
	"Fac_Pink": [Color("c98f78"), Color("e3b9a5"), Vector2(2.2, 3.0), Vector2(1.1, 1.8)],
}

# The rug: a round 120 cm braided-look rug (product photo in RUG_TEXTURE), centre on the floor in Godot X, Z, in metres.
# It sits in the open floor in front of the counter. The earlier striped rectangle used assets/rug.png at 1.165 x 1.7 m.
const RUG_TEXTURE := "res://assets/rug_round.png"
const RUG_CENTER := Vector2(1.6, -4.05)
const RUG_DIAMETER := 1.2
const RUG_THICKNESS := 0.008
const RUG_RING_PITCH := 0.007 # metres between the concentric ridges

@onready var room: Node3D = $Room
@onready var lights: Node3D = $ElectricLights

var _shared: Dictionary = {}


func _ready() -> void:
	_build_shared_materials()
	_build_rug()
	for n in room.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := n as MeshInstance3D
		_apply_materials(mesh_node)
		if mesh_node.name == "Window_Glass" or mesh_node.name.begins_with("Blind_"):
			mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF  # transparent, must not block the sun
		if not _skip_collision(mesh_node.name):
			mesh_node.create_trimesh_collision()
	lights.visible = false
	# Late-afternoon sun about 33 degrees up, coming in from the window side (the window faces west-southwest, toward -Z).
	$Sun.look_at_from_position(Vector3(2.0, 13.0, -20.0), Vector3.ZERO)
	# Baked indirect light, produced by tools/bake_gi.gd. The room still looks fine without it.
	if ResourceLoader.exists(GI_DATA):
		$VoxelGI.data = load(GI_DATA)


func _shader_mat(path: String, params: Dictionary) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load(path)
	for k in params:
		m.set_shader_parameter(k, params[k])
	return m


func _build_shared_materials() -> void:
	var plaster := "res://shaders/plaster.gdshader"
	_shared["Wall"] = _shader_mat(plaster, {"base_color": Color("a7a3a2")})
	_shared["Ceiling"] = _shader_mat(plaster, {"base_color": Color("c7c3bd"), "grain_contrast": 0.12, "bump_strength": 0.0007})
	_shared["Soffit"] = _shared["Ceiling"]
	_shared["Door"] = _shader_mat("res://shaders/door.gdshader", {})
	_shared["CounterTop"] = _shader_mat("res://shaders/counter_top.gdshader", {})
	# Rolled oak-print vinyl laid over the old tile. The tile shader is kept in floor_tiles.gdshader for comparison.
	_shared["Floor"] = _shader_mat("res://shaders/vinyl_wood.gdshader", {})

	var satin := "res://shaders/satin.gdshader"
	# Painted / enamelled / lacquered surfaces (colour, roughness, smudge variation, clearcoat)
	_shared["CounterWhite"] = _shader_mat(satin, {"albedo": Color("dcdcd6"), "roughness": 0.36, "rough_var": 0.1, "clearcoat": 0.35})
	_shared["CounterFront"] = _shader_mat(satin, {"albedo": Color("e3e2dc"), "roughness": 0.32, "rough_var": 0.1, "clearcoat": 0.45})
	_shared["Radiator"] = _shader_mat(satin, {"albedo": Color("ecebe6"), "roughness": 0.3, "rough_var": 0.08, "clearcoat": 0.5})
	_shared["Skirting"] = _shader_mat(satin, {"albedo": Color("d8d4cd"), "roughness": 0.5, "rough_var": 0.12})
	_shared["SocketPlate"] = _shader_mat(satin, {"albedo": Color("efeee9"), "roughness": 0.35, "rough_var": 0.05, "clearcoat": 0.3})
	_shared["BlackPlastic"] = _shader_mat(satin, {"albedo": Color("1a1a1a"), "roughness": 0.42, "rough_var": 0.1})
	_shared["DownlightRim"] = _shader_mat(satin, {"albedo": Color("e8e8e2"), "roughness": 0.4, "rough_var": 0.05})
	# Metals
	_shared["Steel"] = _shader_mat(satin, {"albedo": Color("c4c7ca"), "roughness": 0.3, "rough_var": 0.1, "metallic": 0.85, "brushed": 1.0})
	_shared["DarkSteel"] = _shader_mat(satin, {"albedo": Color("8b8f94"), "roughness": 0.34, "rough_var": 0.1, "metallic": 0.8, "brushed": 1.0})
	_shared["Frame"] = _shader_mat(satin, {"albedo": Color("26272a"), "roughness": 0.38, "rough_var": 0.08, "metallic": 0.55})
	# Fabric
	_shared["Curtain"] = _shader_mat(satin, {"albedo": Color("4a3225"), "roughness": 0.95, "rough_var": 0.05, "sheen": 0.22, "weave": 0.3, "bump_strength": 0.0006, "specular": 0.15})


func _build_rug() -> void:
	if not FileAccess.file_exists(RUG_TEXTURE):
		return
	# Loaded as a raw image so it gets mipmaps (no shimmer at a distance) and needs no editor import.
	var img := Image.load_from_file(RUG_TEXTURE)
	img.generate_mipmaps()
	var disc := CylinderMesh.new()
	disc.top_radius = RUG_DIAMETER * 0.5
	disc.bottom_radius = RUG_DIAMETER * 0.5
	disc.height = RUG_THICKNESS
	disc.radial_segments = 96
	disc.rings = 1
	var rug := MeshInstance3D.new()
	rug.name = "Rug"
	rug.mesh = disc
	rug.material_override = _shader_mat("res://shaders/rug.gdshader", {
		"albedo_tex": ImageTexture.create_from_image(img),
		"rug_center": RUG_CENTER,
		"rug_size": Vector2(RUG_DIAMETER, RUG_DIAMETER),
		"ring_pitch": RUG_RING_PITCH,
	})
	rug.position = Vector3(RUG_CENTER.x, RUG_THICKNESS * 0.5, RUG_CENTER.y)
	rug.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rug)


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
