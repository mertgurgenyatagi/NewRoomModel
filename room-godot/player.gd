extends CharacterBody3D
## First-person walker: WASD move, mouse look, Shift sprint, Esc frees the mouse.

const WALK_SPEED := 1.6
const SPRINT_SPEED := 3.0
const MOUSE_SENS := 0.0022
const GRAVITY := 9.8

@onready var head: Node3D = $Head


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _down(key: Key) -> bool:
	return Input.is_physical_key_pressed(key) or Input.is_key_pressed(key)


func _physics_process(delta: float) -> void:
	var x := int(_down(KEY_D)) - int(_down(KEY_A))
	var z := int(_down(KEY_S)) - int(_down(KEY_W))
	var dir := (transform.basis * Vector3(x, 0, z)).normalized()
	var speed := SPRINT_SPEED if _down(KEY_SHIFT) else WALK_SPEED
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
	move_and_slide()
