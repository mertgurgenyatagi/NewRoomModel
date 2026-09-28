extends CanvasLayer
## Live in-game tuning panel for the ceiling downlights - press F1 to toggle it while playing (main.gd handles
## the key and forces the lights visible / frees the mouse while it's open). Drag the sliders to change all
## three downlights at once and see the result immediately - no editing main.tscn, no relaunching.
## When it looks right, press "Copy values" - it copies the exact lines to paste into each SpotLight3D block
## under ElectricLights in main.tscn (or just read them off the panel and tell Claude the numbers).

const PARAMS := [
	# [label, property, min, max, step]
	["Energy", "light_energy", 0.0, 8.0, 0.05],
	["Range (m)", "spot_range", 1.0, 12.0, 0.1],
	["Cone angle (deg)", "spot_angle", 5.0, 89.0, 0.5],
	["Edge softness", "spot_angle_attenuation", 0.05, 5.0, 0.05],
	["Warmth", "warmth", 0.0, 1.0, 0.01],
]
const COOL := Color(1, 1, 1)
const WARM := Color(1, 0.72, 0.5)

var _lights: Array = []
var _sliders: Dictionary = {}
var _value_labels: Dictionary = {}
var _warmth := 0.35


## lights: the three downlight SpotLight3D nodes, kept in sync with each other.
func setup(lights: Array) -> void:
	_lights = lights
	layer = 20
	_warmth = _warmth_from_color(lights[0].light_color) if not lights.is_empty() else 0.35
	_build_ui()
	_read_from_light()
	visible = false


func _warmth_from_color(c: Color) -> float:
	# Inverse of COOL.lerp(WARM, t) on the green channel (the channel that changes most between the two).
	return clampf(inverse_lerp(COOL.g, WARM.g, c.g), 0.0, 1.0)


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -340
	panel.offset_right = -16
	panel.offset_top = 16
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.72)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Downlight tuner (F1 to hide)"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	for p in PARAMS:
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		vbox.add_child(row)

		var header := HBoxContainer.new()
		row.add_child(header)
		var name_label := Label.new()
		name_label.text = p[0]
		name_label.custom_minimum_size = Vector2(150, 0)
		header.add_child(name_label)
		var value_label := Label.new()
		value_label.custom_minimum_size = Vector2(60, 0)
		header.add_child(value_label)
		_value_labels[p[1]] = value_label

		var slider := HSlider.new()
		slider.min_value = p[2]
		slider.max_value = p[3]
		slider.step = p[4]
		slider.custom_minimum_size = Vector2(300, 0)
		slider.value_changed.connect(_on_slider_changed.bind(p[1], value_label))
		row.add_child(slider)
		_sliders[p[1]] = slider

	var copy_btn := Button.new()
	copy_btn.text = "Copy values"
	copy_btn.pressed.connect(_copy_values)
	vbox.add_child(copy_btn)

	var copied_label := Label.new()
	copied_label.name = "CopiedLabel"
	copied_label.modulate.a = 0.0
	vbox.add_child(copied_label)


func _on_slider_changed(value: float, prop: String, value_label: Label) -> void:
	value_label.text = "%.2f" % value
	if prop == "warmth":
		_warmth = value
		var color: Color = COOL.lerp(WARM, value)
		for l in _lights:
			l.light_color = color
	else:
		for l in _lights:
			l.set(prop, value)


func _read_from_light() -> void:
	if _lights.is_empty():
		return
	var l0: SpotLight3D = _lights[0]
	for p in PARAMS:
		var prop: String = p[1]
		var v: float = _warmth if prop == "warmth" else l0.get(prop)
		_sliders[prop].value = v
		_value_labels[prop].text = "%.2f" % v


func _copy_values() -> void:
	if _lights.is_empty():
		return
	var l0: SpotLight3D = _lights[0]
	var text := "light_color = Color(%.2f, %.2f, %.2f, 1)\nlight_energy = %.2f\nspot_range = %.2f\nspot_angle = %.1f\nspot_angle_attenuation = %.2f" % [
		l0.light_color.r, l0.light_color.g, l0.light_color.b,
		l0.light_energy, l0.spot_range, l0.spot_angle, l0.spot_angle_attenuation,
	]
	DisplayServer.clipboard_set(text)
	print(text)
	var copied_label := find_child("CopiedLabel") as Label
	copied_label.text = "Copied - paste it somewhere, or read it from here"
	copied_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.5)
	tw.tween_property(copied_label, "modulate:a", 0.0, 0.6)
