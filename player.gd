extends CharacterBody3D

@onready var camera_3d = $Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENS = 0.003 

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"): get_tree().quit()
	
	if event is InputEventMouseMotion:
		# Поворот тела (влево-вправо)
		rotate_y(-event.relative.x * CAMERA_SENS)
		
		# Поворот камеры (вверх-вниз)
		camera_3d.rotate_x(-event.relative.y * CAMERA_SENS)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# дефолтный код для ходьбы
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed = SPEED
	#Бег
	if Input.is_action_pressed("sprint"):
		currentSpeed = SPEED * 2
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			# Направление от игрока к мячу
			var push_dir = (collider.global_position - global_position).normalized()
			push_dir.y = 0.3          # небольшой подъём вверх, чтобы мяч подпрыгивал
			push_dir = push_dir.normalized()
			
			# Сила удара
			var push_strength = 0.5
			
			collider.apply_central_impulse(push_dir * push_strength)
