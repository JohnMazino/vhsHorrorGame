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
		else:
			get_tree().paused = false
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_button_pressed() -> void:
	settings_button.visible = false
	settings.visible = true


func _on_display_item_selected(index: int) -> void:
	var new_display = display_option[index]
	
	#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	DisplayServer.window_set_size(new_display)
