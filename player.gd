extends CharacterBody3D

@onready var camera_3d = $Camera3D
@onready var progres_bar = $TextureProgressBar
@onready var vhs_effect = $Camera3D/CanvasLayer/ColorRect
@onready var pause_menu = $pauseMenu

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENS = 0.0012
const regen_delay = 1.0

# стамина
var max_stamina = 100
var stamina = 100
var regen_points = 15.0
var regen_timer = 0.0
# шейдеры
var current_exhaustion = 0.0  # Для плавного переход эффекта затемнения
# здоровье
var max_hp = 100.0
var hp = 100.0
var is_dead = false


func take_damage(amount: float) -> void:
	if is_dead:
		return
		
	hp = max(hp - amount, 0.0)
	print("HP: ", hp)
	
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		take_damage(15.0)
	
	#if event.is_action_pressed("quit"): get_tree().quit()
	
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

	# прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		stamina -= 500 * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# дефолтный код для ходьбы
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = SPEED
	
	# бег
	if Input.is_action_pressed("sprint") and stamina > 0:
		current_speed = SPEED * 2
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			stamina -= 20 * delta
			regen_timer = 0.0
	else:
		regen_timer += delta
		if regen_timer >= regen_delay:
			stamina = min(stamina + regen_points * delta ,max_stamina)
	#print(stamina)
	progres_bar.value = stamina
	
	#Усиление эффекта шейдеров при усталости
	# --- Расчет целевого эффекта усталости ---
	var target_exhaustion = 0.0

	# Начинаем с 75 стамины (можно поставить 80 или 70)
	if stamina < 75.0:
		# От 75 → 0  эффект идёт от 0 → 1
		target_exhaustion = 1.0 - (stamina / 75.0)
	
	# Когда очень мало стамины — принудительно максимальный эффект
	if stamina <= 15.0:
		target_exhaustion = 1.0

	# При спринте ниже 60% усиливаем
	if Input.is_action_pressed("sprint") and stamina < 60.0:
		target_exhaustion = max(target_exhaustion, 0.75)
	
	# --- Плавное сглаживание ---
	# 1.2 — это скорость сглаживания. 
	# Чем больше число, тем быстрее эффект появляется/исчезает. 
	current_exhaustion = lerp(current_exhaustion, target_exhaustion, 1.2 * delta)
	
	# Передаем сглаженное значение в шейдер
	vhs_effect.material.set_shader_parameter("exhaustion", clamp(current_exhaustion, 0.0, 1.0))
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
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
