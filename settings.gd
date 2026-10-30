extends CanvasLayer

@onready var settings = $settings
@onready var settings_button = $pauseMenu/settingsButton
@onready var display = $settings/display

var display_option = [
	Vector2i(640, 480),
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport()
	$settings/scaleText.text = str($settings/HSlider.value)
	
	for i in display_option:
		display.add_item(str(i.x) + "x" + str(i.y))
		
	var current_display = DisplayServer.window_get_size()
	
	for i in display_option.size():
		if display_option[i] == current_display:
			display.select(i)
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# пауза
	if Input.is_action_just_pressed("pause_game"):
		if get_tree().paused == false:
			get_tree().paused = true
			visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif get_tree().paused == true && settings_button.visible == true:
			get_tree().paused = false
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif get_tree().paused == true && settings_button.visible == false:
			settings_button.visible = true
			settings.visible = false

func _on_settings_button_pressed() -> void:
	settings_button.visible = false
	settings.visible = true


func _on_display_item_selected(index: int) -> void:
	var new_display = display_option[index]
	
	#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	DisplayServer.window_set_size(new_display)


func _on_h_slider_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value
	$settings/scaleText.text = str(get_viewport().scaling_3d_scale)


func _on_one_fsr_box_pressed() -> void:
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	get_viewport().scaling_3d_scale = 0.75
	$settings/scaleText.text = str(get_viewport().scaling_3d_scale)
	$settings/HSlider.value = get_viewport().scaling_3d_scale
	

func _on_two_fsr_box_pressed() -> void:
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
	get_viewport().scaling_3d_scale = 0.75
	$settings/scaleText.text = str(get_viewport().scaling_3d_scale)
	$settings/HSlider.value = get_viewport().scaling_3d_scale

func _on_native_box_pressed() -> void:
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	get_viewport().scaling_3d_scale = 1.0
	$settings/scaleText.text = str(get_viewport().scaling_3d_scale)
	$settings/HSlider.value = get_viewport().scaling_3d_scale
