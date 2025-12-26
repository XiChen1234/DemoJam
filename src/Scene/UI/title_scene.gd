extends Control

@onready var main_button: VBoxContainer = $MarginContainer/VBoxContainer/MainButton
@onready var option_button: VBoxContainer = $MarginContainer/VBoxContainer/OptionButton
@onready var back: Button = $Back

func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")


func _on_options() -> void:
	main_button.visible = false
	option_button.visible = true
	back.visible = true


func _on_quit() -> void:
	get_tree().quit()


func _on_back() -> void:
	main_button.visible = true
	option_button.visible = false
	back.visible = false
