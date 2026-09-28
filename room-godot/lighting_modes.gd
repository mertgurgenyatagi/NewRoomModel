extends RefCounted
## Two lighting modes, switched with keys 1 and 2 (see main.gd):
##   day   the midday look main.tscn is authored with (sun ~47 degrees up, cool sky fill, downlights off)
##   night dark outside, no sun and no sky fill: only the three ceiling downlights, plus a few lit windows
##         across the street and glowing street-lamp heads
## "day" is captured from the scene when setup() runs, so it always matches whatever main.tscn says. "night"
## is an override on top of it. Each mode has its own baked VoxelGI (see tools/bake_gi.gd), swapped in with
## the mode.

const MODES := ["day", "night"]
const LABELS := {"day": "Day", "night": "Night"}

const ENV_PROPS := [
	"ambient_light_energy", "fog_light_color", "fog_density", "fog_sky_affect",
	"glow_intensity", "glow_hdr_threshold", "adjustment_saturation",
]
const SKY_PROPS := ["sky_top_color", "sky_horizon_color", "sky_curve", "ground_bottom_color", "ground_horizon_color"]

const NIGHT := {
	"env": {
		"ambient_light_energy": 0.12,
		"fog_light_color": Color(0.04, 0.05, 0.09),
		"fog_density": 0.003,
		"fog_sky_affect": 0.0,
		"glow_intensity": 0.55,
		"glow_hdr_threshold": 0.9,
		"adjustment_saturation": 1.0,
	},
	"sky": {
		"sky_top_color": Color(0.012, 0.016, 0.036),
		"sky_horizon_color": Color(0.04, 0.05, 0.09),
		"sky_curve": 0.15,
		"ground_bottom_color": Color(0.01, 0.01, 0.015),
		"ground_horizon_color": Color(0.03, 0.035, 0.05),
	},
	"sun_off": true,
	"fill_off": true,
	"lights": true,
}

var mode := "day"

var _env: Environment
var _sky: ProceduralSkyMaterial
var _sun: DirectionalLight3D
var _fill: Array = []
var _lights: Node3D
var _gi: VoxelGI
var _facades: Array = []
var _lamps: Array = []
var _lamp_glow: StandardMaterial3D

var _day_env := {}
var _day_sky := {}
var _day_sun := {}
var _day_fill: Array = []


## Call at the end of main's _ready(), after the sun is placed and the facade materials exist.
func setup(main: Node3D, facade_materials: Array) -> void:
	_env = (main.get_node("WorldEnvironment") as WorldEnvironment).environment
	_sky = _env.sky.sky_material as ProceduralSkyMaterial
	_sun = main.get_node("Sun")
	_lights = main.get_node("ElectricLights")
	_gi = main.get_node("VoxelGI")
	_facades = facade_materials
	for c in main.get_node("SkyFill").get_children():
		_fill.append(c)
	for k in ENV_PROPS:
		_day_env[k] = _env.get(k)
	for k in SKY_PROPS:
		_day_sky[k] = _sky.get(k)
	_day_sun = {"color": _sun.light_color, "energy": _sun.light_energy, "xform": _sun.global_transform}
	for f in _fill:
		_day_fill.append({"color": f.light_color, "energy": f.light_energy})
	# The lamp heads on the far street glow at night.
	_lamps = main.find_children("D_LampHead*", "MeshInstance3D", true, false)
	_lamp_glow = StandardMaterial3D.new()
	_lamp_glow.albedo_color = Color(0.2, 0.2, 0.2)
	_lamp_glow.emission_enabled = true
	_lamp_glow.emission = Color(1.0, 0.82, 0.5)
	_lamp_glow.emission_energy_multiplier = 3.0


func gi_path(m: String) -> String:
	return "res://lighting/voxel_gi.res" if m == "day" else "res://lighting/voxel_gi_%s.res" % m


func apply(m: String) -> void:
	if not MODES.has(m):
		return
	mode = m

	# 1. back to the authored day look
	for k in _day_env:
		_env.set(k, _day_env[k])
	for k in _day_sky:
		_sky.set(k, _day_sky[k])
	_sun.visible = true
	_sun.light_color = _day_sun["color"]
	_sun.light_energy = _day_sun["energy"]
	_sun.global_transform = _day_sun["xform"]
	for i in _fill.size():
		_fill[i].visible = true
		_fill[i].light_color = _day_fill[i]["color"]
		_fill[i].light_energy = _day_fill[i]["energy"]

	# 2. night overrides
	if m == "night":
		for k in NIGHT.get("env", {}):
			_env.set(k, NIGHT["env"][k])
		for k in NIGHT.get("sky", {}):
			_sky.set(k, NIGHT["sky"][k])
		if NIGHT.get("sun_off", false):
			_sun.visible = false
		if NIGHT.get("fill_off", false):
			for f in _fill:
				f.visible = false

	_lights.visible = (m == "night")
	for f in _facades:
		f.set_shader_parameter("night", 1.0 if m == "night" else 0.0)
	for l in _lamps:
		(l as MeshInstance3D).material_override = _lamp_glow if m == "night" else null

	# 3. the baked bounce light that belongs to this mode, if it has been baked
	var path := gi_path(m)
	if ResourceLoader.exists(path):
		_gi.data = load(path)
