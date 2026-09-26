extends RefCounted
## Lighting modes for the room, switched with the keys 1, 2 and 3 (see main.gd):
##   day    the look the scene is authored with (late-afternoon sun, cool sky fill, electric lights off)
##   sunset an early, golden pre-evening: a low warm sun, a peach horizon, warm haze. Not red, lights still off
##   night  dark outside, no sun and no sky fill: only the three ceiling downlights, a few lit windows across the street
## "day" is captured from the scene when setup() runs, so it always matches whatever main.tscn says. The other modes
## are overrides on top of it. Each mode has its own baked VoxelGI (see tools/bake_gi.gd), swapped in with the mode.

const MODES := ["day", "sunset", "night"]
const LABELS := {"day": "Day", "sunset": "Sunset", "night": "Night"}

const ENV_PROPS := [
	"ambient_light_energy", "fog_light_color", "fog_density", "fog_sky_affect", "volumetric_fog_density",
	"volumetric_fog_albedo", "glow_intensity", "glow_hdr_threshold", "adjustment_saturation",
]
const SKY_PROPS := ["sky_top_color", "sky_horizon_color", "sky_curve", "ground_bottom_color", "ground_horizon_color"]

const PRESETS := {
	"sunset": {
		"env": {
			"ambient_light_energy": 0.55,
			"fog_light_color": Color(0.95, 0.76, 0.6),
			"fog_density": 0.006,
			"fog_sky_affect": 0.35,
			"volumetric_fog_density": 0.010,
			"volumetric_fog_albedo": Color(1.0, 0.86, 0.7),
			"glow_intensity": 0.7,
			"adjustment_saturation": 1.1,
		},
		"sky": {
			"sky_top_color": Color(0.35, 0.5, 0.78),
			"sky_horizon_color": Color(0.98, 0.74, 0.55),
			"sky_curve": 0.25,
			"ground_bottom_color": Color(0.28, 0.24, 0.22),
			"ground_horizon_color": Color(0.75, 0.55, 0.42),
		},
		# About 13 degrees up (the day sun is about 33), golden and not red, a bit stronger in the haze so the beams glow.
		"sun": {"color": Color(1.0, 0.76, 0.48), "energy": 1.9, "fog": 2.4, "from": Vector3(3.0, 4.6, -20.0)},
		"fill": {"color": Color(0.9, 0.86, 0.95), "scale": 0.6},
		"lights": false,
		"night": 0.0,
	},
	"night": {
		"env": {
			"ambient_light_energy": 0.35,
			"fog_light_color": Color(0.05, 0.06, 0.1),
			"fog_density": 0.004,
			"fog_sky_affect": 0.0,
			"volumetric_fog_density": 0.004,
			"volumetric_fog_albedo": Color(0.9, 0.85, 0.8),
			"glow_intensity": 0.9,
			"glow_hdr_threshold": 0.9,
			"adjustment_saturation": 1.0,
		},
		"sky": {
			"sky_top_color": Color(0.012, 0.02, 0.05),
			"sky_horizon_color": Color(0.05, 0.065, 0.11),
			"sky_curve": 0.15,
			"ground_bottom_color": Color(0.01, 0.01, 0.015),
			"ground_horizon_color": Color(0.05, 0.055, 0.08),
		},
		"sun_off": true,
		"fill_off": true,
		"lights": true,
		"night": 1.0,
	},
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
	_day_sun = {
		"color": _sun.light_color, "energy": _sun.light_energy,
		"fog": _sun.light_volumetric_fog_energy, "xform": _sun.global_transform,
	}
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
	var p: Dictionary = PRESETS.get(m, {})

	# 1. back to the authored day look
	for k in _day_env:
		_env.set(k, _day_env[k])
	for k in _day_sky:
		_sky.set(k, _day_sky[k])
	_sun.visible = true
	_sun.light_color = _day_sun["color"]
	_sun.light_energy = _day_sun["energy"]
	_sun.light_volumetric_fog_energy = _day_sun["fog"]
	_sun.global_transform = _day_sun["xform"]
	for i in _fill.size():
		_fill[i].visible = true
		_fill[i].light_color = _day_fill[i]["color"]
		_fill[i].light_energy = _day_fill[i]["energy"]

	# 2. this mode's overrides
	for k in p.get("env", {}):
		_env.set(k, p["env"][k])
	for k in p.get("sky", {}):
		_sky.set(k, p["sky"][k])
	if p.has("sun"):
		var s: Dictionary = p["sun"]
		_sun.light_color = s["color"]
		_sun.light_energy = s["energy"]
		_sun.light_volumetric_fog_energy = s["fog"]
		_sun.look_at_from_position(s["from"], Vector3.ZERO)
	if p.get("sun_off", false):
		_sun.visible = false
	if p.has("fill"):
		for i in _fill.size():
			_fill[i].light_color = p["fill"]["color"]
			_fill[i].light_energy = _day_fill[i]["energy"] * p["fill"]["scale"]
	if p.get("fill_off", false):
		for f in _fill:
			f.visible = false

	_lights.visible = p.get("lights", false)
	for f in _facades:
		f.set_shader_parameter("night", p.get("night", 0.0))
	for l in _lamps:
		(l as MeshInstance3D).material_override = _lamp_glow if m == "night" else null

	# 3. the baked bounce light that belongs to this mode, if it has been baked
	var path := gi_path(m)
	if ResourceLoader.exists(path):
		_gi.data = load(path)
