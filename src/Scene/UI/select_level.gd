extends Control

@onready var level: TextureButton = $HBoxContainer/Level

var level_array: Array = []


func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")
