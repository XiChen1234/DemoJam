extends Control


func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")
