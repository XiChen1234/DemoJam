extends Control
class_name PauseLayer

@onready var restart_button: TextureButton = $VBoxContainer/RestartButton
@onready var continue_button: TextureButton = $VBoxContainer/ContinueButton
@onready var home_button: TextureButton = $VBoxContainer/HomeButton

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()

func _on_restart() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")


func _on_continue() -> void:
	pause()


func _on_home() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")


"""暂停逻辑"""
func pause() -> void:
	visible = not visible
	get_tree().paused = not get_tree().paused
