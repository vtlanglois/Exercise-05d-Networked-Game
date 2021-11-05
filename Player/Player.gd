extends KinematicBody

onready var camera = $Pivot/Camera

var speed = 5
var gravity = -8.0
var direction = Vector3()
var mouse_sensitivity = 0.002
var mouse_range = 1.2
var velocity = Vector2.ZERO

remote func _set_position(pos):
	global_transform.origin = pos

func _ready():
	if is_network_master():
		camera.current = true
	if Global.which_player == 1:
		$MeshInstance.get_surface_material(0).albedo_color = Color8(34,139,230)
	else:
		$MeshInstance.get_surface_material(0).albedo_color = Color8(250,82,82)

func _physics_process(_delta):
	velocity = get_input()*speed
	velocity.y += gravity
	if is_on_floor():
		velocity.y = 0

	if velocity != Vector3.ZERO:
		if is_network_master():
			velocity = move_and_slide(velocity, Vector3.UP)
		rpc_unreliable("_set_position", global_transform.origin)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -mouse_range, mouse_range)

func die():
	queue_free()

func get_input():
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
