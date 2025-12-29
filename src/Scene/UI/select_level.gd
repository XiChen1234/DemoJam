extends Control

@export var level_data: Array[LevelData]


func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")


func _on_level_select(level_index: int) -> void:
	GameManager.selected_level = level_data[level_index]
	get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")
