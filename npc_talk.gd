extends CharacterBody3D

@export var npc_name: String = "таксист"

@export var dialogues: Array[String] = [
	"Какой-то диалог 1",
	"Какой-то диалог 2"
]

var player_in_range := false
var dialog_index := 0
var is_talking := false

@onready var interaction_area = $Area3D
@onready var dialog_ui = $CanvasLayer
@onready var panel = $CanvasLayer/Control/Panel
@onready var text_label = $CanvasLayer/Control/Panel/RichTextLabel

func _ready() -> void:
	panel.visible = false
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if not is_talking:
			start_talking()
		else:
			_next_index_dialog()
		
func start_talking():
	is_talking = true
	dialog_index = 0
	panel.visible = true
	_show_current_dialog()
	
func _show_current_dialog():
	text_label.text = dialogues[dialog_index]

func _next_index_dialog():
	dialog_index += 1
	if dialogues.size() <= dialog_index:
		print(dialogues.size())
		print(dialog_index)
		_end_dialog()
	else:
		_show_current_dialog()
	
func _end_dialog():
	is_talking = false
	dialog_index = 0
	panel.visible = false
	
