extends Control

@onready var level: TextureButton = $HBoxContainer/Level


func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")



func _on_level_selected() -> void:
	get_tree().change_scene_to_file("res://Scene/game_scene.tscn")
