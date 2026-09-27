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

# The daybed's kilim: the product photo (kilim-texture.png at the repo root), mapped once over the cloth (top + front face).
const KILIM_TEXTURE := "res://assets/kilim.png"

# Wallpapers (key 0 cycles none, a, b, c), top to bottom, on the wall behind the daybed (WALLPAPER_ACCENT_WALL) only.
# Every other wall becomes a plain flat beige (WALLPAPER_PLAIN_COLOR, no grain, no roughness variation) at the same time, so
# the accent wall reads as the one papered wall. "None" puts every wall back to the ordinary roughcast plaster.
# Each WALLPAPERS entry is the file letter and how many metres one repeat of the tile covers on the wall (width, height).
const WALLPAPER_ACCENT_WALL := "Wall_Left"          # the wall the daybed stands against
const WALLPAPER_PLAIN_COLOR := Color("ded2b8")
const WALLPAPERS := [
	["a", Vector2(0.8, 1.422)],
	["b", Vector2(0.8, 1.422)],
	["c", Vector2(0.85, 1.702)],
]

@onready var room: Node3D = $Room
@onready var lights: Node3D = $ElectricLights

var _shared: Dictionary = {}
var _facade_mats: Array = []
var _lighting := preload("res://lighting_modes.gd").new()
var _mode_label: Label
var _wall_accent_surfaces: Array = []   # [mesh node, surface index] of WALLPAPER_ACCENT_WALL's surfaces
var _wall_other_surfaces: Array = []    # every other wall surface
var _wallpaper_mats: Array = []         # one accent-wall material per WALLPAPERS entry
var _wallpaper_plain: Material          # the flat beige used on every other wall once a wallpaper is picked
var _wallpaper := -1                    # -1 = none (all walls plain plaster), otherwise an index into WALLPAPERS


func _ready() -> void:
	_build_shared_materials()
	_build_rug()
	_build_kilim()
	_build_wallpapers()
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
	# Lighting modes: 1 = day (as authored above), 2 = sunset, 3 = night. Captures the day look, so call it last.
	_lighting.setup(self, _facade_mats)
	_mode_label = Label.new()
	_mode_label.position = Vector2(24, 18)
	_mode_label.add_theme_font_size_override("font_size", 22)
	_mode_label.modulate.a = 0.0
	$Screen.add_child(_mode_label)


## Used by tools/bake_gi.gd, which bakes one GI file per mode.
func lighting() -> RefCounted:
	return _lighting


func _set_mode(m: String) -> void:
	_lighting.apply(m)
	_flash_label(_lighting.LABELS[m])
	_refresh_reflection_probe()


## The reflection probe only bakes once (GPU cost, see PROJECT.md), so nudge it to re-bake after anything that actually
## changes what it should be reflecting. One extra probe render, not a per-frame cost.
func _refresh_reflection_probe() -> void:
	var rp := $ReflectionProbe as ReflectionProbe
	rp.update_mode = ReflectionProbe.UPDATE_ALWAYS
	await get_tree().process_frame
	rp.update_mode = ReflectionProbe.UPDATE_ONCE


func _flash_label(text: String) -> void:
	_mode_label.text = text
	_mode_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(_mode_label, "modulate:a", 0.0, 0.6)


## Key 0: none -> a -> b -> c -> none. "None" puts every wall back to the plain plaster; a/b/c paper the accent wall and
## turn every other wall a flat beige.
func _cycle_wallpaper() -> void:
	_wallpaper += 1
	if _wallpaper >= _wallpaper_mats.size():
		_wallpaper = -1
	var accent: Material = _shared["Wall"] if _wallpaper < 0 else _wallpaper_mats[_wallpaper]
	var other: Material = _shared["Wall"] if _wallpaper < 0 else _wallpaper_plain
	for w in _wall_accent_surfaces:
		(w[0] as MeshInstance3D).set_surface_override_material(w[1], accent)
	for w in _wall_other_surfaces:
		(w[0] as MeshInstance3D).set_surface_override_material(w[1], other)
	_flash_label("Wallpaper: none" if _wallpaper < 0 else "Wallpaper: " + String(WALLPAPERS[_wallpaper][0]))
	_refresh_reflection_probe()


func _build_wallpapers() -> void:
	var plain := StandardMaterial3D.new()
	plain.albedo_color = WALLPAPER_PLAIN_COLOR
	plain.roughness = 1.0                    # flat paint, no gloss and no per-pixel roughness variation
	_wallpaper_plain = plain
	# Loaded as raw images (mipmaps, no editor import needed), like the rug and kilim.
	for w in WALLPAPERS:
		var path := "res://assets/wallpaper_%s.jpg" % w[0]
		if not FileAccess.file_exists(path):
			continue
		var img := Image.load_from_file(path)
		img.generate_mipmaps()
		_wallpaper_mats.append(_shader_mat("res://shaders/wallpaper.gdshader", {
			"albedo_tex": ImageTexture.create_from_image(img),
			"tile_size": w[1],
		}))


func _shader_mat(path: String, params: Dictionary) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load(path)
	for k in params:
		m.set_shader_parameter(k, params[k])
	return m


func _build_shared_materials() -> void:
	var plaster := "res://shaders/plaster.gdshader"
	_shared["Wall"] = _shader_mat(plaster, {"base_color": Color("a7a3a2")})
	_shared["Ceiling"] = _shader_mat(plaster, {"base_color": Color("aa6a1c"), "grain_contrast": 0.12, "bump_strength": 0.0007})
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
	# Daybed: mattress ticking and the frame wood. The kilim is built in _build_kilim().
	_shared["Mattress"] = _shader_mat(satin, {"albedo": Color("ddd7c9"), "roughness": 0.92, "rough_var": 0.05, "sheen": 0.18, "weave": 0.3, "bump_strength": 0.0004, "specular": 0.15})
	# Back-support blocks (beige) and scatter pillows (sage): woven cloth
	_shared["CushionBeige"] = _shader_mat("res://shaders/fabric.gdshader", {"albedo": Color("c0b198"), "roughness": 0.95, "sheen": 0.09, "slub": 0.08, "thread": 0.02})
	_shared["CushionSage"] = _shader_mat("res://shaders/fabric.gdshader", {"albedo": Color("78876c"), "roughness": 0.95, "sheen": 0.12, "slub": 0.08, "thread": 0.02})
	# Arm boxes: only the plinth is still real wood; the body, corners, lid and seam band are a beige bouclé slipcover
	_shared["ArmBoxOak"] = _shader_mat(satin, {"albedo": Color("c8975f"), "roughness": 0.55, "rough_var": 0.14, "clearcoat": 0.08, "bump_strength": 0.0004})
	_shared["ArmBoxFabric"] = _shader_mat("res://shaders/fabric.gdshader", {"albedo": Color("c9bda0"), "roughness": 0.97, "sheen": 0.07, "slub": 0.12, "thread": 0.01})
	_shared["BedFrameWhite"] =_shader_mat(satin, {"albedo": Color("e6e4de"), "roughness": 0.45, "rough_var": 0.1, "clearcoat": 0.12})


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


func _build_kilim() -> void:
	var top := room.find_child("S_Kilim_Top", true, false) as MeshInstance3D
	var front := room.find_child("S_Kilim_Front", true, false) as MeshInstance3D
	if top == null or front == null or not FileAccess.file_exists(KILIM_TEXTURE):
		return
	# Measure the cloth so the photo follows the bed if it is moved in Blender.
	var t := top.global_transform * top.get_aabb()
	var f := front.global_transform * front.get_aabb()
	var img := Image.load_from_file(KILIM_TEXTURE)  # raw image, so it gets mipmaps and needs no editor import
	img.generate_mipmaps()
	_shared["Kilim"] = _shader_mat("res://shaders/kilim.gdshader", {
		"albedo_tex": ImageTexture.create_from_image(img),
		"bed_x0": t.position.x,
		"top_y": t.end.y,
		"top_w": t.size.x,
		"sheet_w": t.size.x + (t.end.y - f.position.y),
		"z_min": t.position.z,
		"bed_len": t.size.z,
	})


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
			if key == "Wall":
				if mesh_node.name == WALLPAPER_ACCENT_WALL:
					_wall_accent_surfaces.append([mesh_node, s])
				else:
					_wall_other_surfaces.append([mesh_node, s])
		elif FACADES.has(key) and not mesh_node.name.contains("ledge"):
			mesh_node.set_surface_override_material(s, _facade_material(mesh_node, FACADES[key]))


func _facade_material(mesh_node: MeshInstance3D, cfg: Array) -> ShaderMaterial:
	var box := mesh_node.global_transform * mesh_node.get_aabb()
	var mat := _shader_mat("res://shaders/facade.gdshader", {
		"wall_color": cfg[0],
		"trim_color": cfg[1],
		"pitch": cfg[2],
		"win_size": cfg[3],
		"x_min": box.position.x,
		"x_max": box.end.x,
		"top_y": box.end.y,
	})
	_facade_mats.append(mat)  # the lighting modes light some windows at night
	return mat


func _skip_collision(node_name: String) -> bool:
	for p in NO_COLLISION_PREFIXES:
		if node_name.begins_with(p):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_L:
				lights.visible = not lights.visible
			KEY_1:
				_set_mode("day")
			KEY_2:
				_set_mode("sunset")
			KEY_3:
				_set_mode("night")
			KEY_0:
				_cycle_wallpaper()
