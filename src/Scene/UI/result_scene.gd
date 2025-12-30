extends Control


func _on_next() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
