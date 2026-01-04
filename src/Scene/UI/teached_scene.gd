extends Control


func _ready() -> void:
	GameManager.player_config.is_teached = true
	GameManager.save_config()

func _on_skip() -> void:
	GameManager.play_button_sound()
	get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")
